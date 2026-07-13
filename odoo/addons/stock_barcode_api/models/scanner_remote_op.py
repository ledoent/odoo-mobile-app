# Copyright 2026 Ledo (https://ledoweb.com)
# License AGPL-3.0 or later (https://www.gnu.org/licenses/agpl).
import json

from odoo import fields, models
from odoo.exceptions import UserError, ValidationError


class ScannerRemoteOp(models.Model):
    """Idempotency ledger for scanner operations.

    Offline-first clients retry aggressively: a request whose response was
    lost must be safe to send again. Every mutating call carries a client
    UUID; the first application records its result here and any replay
    returns that stored result without touching stock again.
    """

    _name = "scanner.remote.op"
    _description = "Applied scanner operation (idempotency ledger)"
    _order = "id desc"

    uuid = fields.Char(required=True, index=True)
    kind = fields.Char(required=True)
    payload = fields.Text(required=True)
    result = fields.Text(readonly=True)
    user_id = fields.Many2one("res.users", required=True, readonly=True)

    _sql_constraints = [
        ("uuid_uniq", "unique(uuid)", "Operation UUID must be unique."),
    ]

    def _apply(self, kind, payload):
        """Dispatch one op. Returns a JSON-serializable result dict."""
        handler = getattr(self, f"_apply_{kind}", None)
        if handler is None:
            raise ValidationError(self.env._("Unknown operation kind: %s", kind))
        return handler(payload)

    def apply_idempotent(self, uuid, kind, payload):
        """Apply an op exactly once; replays return the recorded result."""
        existing = self.search([("uuid", "=", uuid)], limit=1)
        if existing:
            return {
                "replayed": True,
                "result": json.loads(existing.result or "{}"),
            }
        result = self._apply(kind, payload)
        self.create(
            {
                "uuid": uuid,
                "kind": kind,
                "payload": json.dumps(payload),
                "result": json.dumps(result),
                "user_id": self.env.uid,
            }
        )
        return {"replayed": False, "result": result}

    # ---- op handlers (Odoo 17+ semantics: quantity + picked) ----

    def _apply_set_quantity(self, payload):
        line = self.env["stock.move.line"].browse(int(payload["move_line_id"]))
        if not line.exists():
            raise UserError(
                self.env._("Move line %s no longer exists.", payload["move_line_id"])
            )
        line.write({"quantity": payload["quantity"], "picked": True})
        return {"move_line_id": line.id, "quantity": line.quantity}

    def _apply_add_product_line(self, payload):
        picking = self.env["stock.picking"].browse(int(payload["picking_id"]))
        if not picking.exists() or picking.state in ("done", "cancel"):
            raise UserError(
                self.env._("Picking %s is not open.", payload["picking_id"])
            )
        line = self.env["stock.move.line"].create(
            {
                "picking_id": picking.id,
                "product_id": int(payload["product_id"]),
                "quantity": payload["quantity"],
                "picked": True,
            }
        )
        return {"move_line_id": line.id, "quantity": line.quantity}

    def _apply_validate_picking(self, payload):
        picking = self.env["stock.picking"].browse(int(payload["picking_id"]))
        if not picking.exists() or picking.state in ("done", "cancel"):
            raise UserError(
                self.env._("Picking %s is not open.", payload["picking_id"])
            )
        create_backorder = payload.get("create_backorder", True)
        res = picking.button_validate()
        if (
            isinstance(res, dict)
            and res.get("res_model") == "stock.backorder.confirmation"
        ):
            wizard = (
                self.env["stock.backorder.confirmation"]
                .with_context(**res.get("context", {}))
                .create({})
            )
            if create_backorder:
                wizard.process()
            else:
                wizard.process_cancel_backorder()
        return {"picking_id": picking.id, "state": picking.state}
