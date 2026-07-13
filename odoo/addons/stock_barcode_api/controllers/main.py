# Copyright 2026 Ledo (https://ledoweb.com)
# License AGPL-3.0 or later (https://www.gnu.org/licenses/agpl).
import json

from odoo import http
from odoo.exceptions import UserError, ValidationError
from odoo.http import request

API_PREFIX = "/scanner/v1"


class ScannerApiController(http.Controller):
    """Versioned REST façade for mobile barcode scanner clients.

    Plain HTTP + JSON (no JSON-RPC envelope), authenticated with standard
    Odoo API keys via ``Authorization: Bearer``. Endpoints are deliberately
    coarse: one round-trip pulls the whole working set for offline mirrors.
    """

    def _json(self, data, status=200):
        return request.make_json_response(data, status=status)

    def _error(self, message, status):
        return self._json({"error": message}, status=status)

    @http.route(f"{API_PREFIX}/ping", type="http", auth="api_key", methods=["GET"])
    def ping(self):
        env = request.env
        return self._json(
            {
                "server_version": env["ir.module.module"]
                .sudo()
                .search([("name", "=", "base")], limit=1)
                .latest_version,
                "api_version": 1,
                "uid": env.uid,
                "user_name": env.user.name,
            }
        )

    @http.route(f"{API_PREFIX}/pickings", type="http", auth="api_key", methods=["GET"])
    def pickings(self, picking_type_code="incoming"):
        env = request.env
        pickings = env["stock.picking"].search(
            [
                ("state", "in", ["assigned", "confirmed"]),
                ("picking_type_code", "=", picking_type_code),
            ],
            order="scheduled_date asc, id asc",
        )
        move_lines = pickings.move_line_ids
        products = move_lines.product_id
        return self._json(
            {
                "pickings": [
                    {
                        "id": p.id,
                        "name": p.name,
                        "state": p.state,
                        "picking_type_code": p.picking_type_code,
                        "partner_name": p.partner_id.name or "",
                        "scheduled_date": p.scheduled_date
                        and p.scheduled_date.isoformat(),
                    }
                    for p in pickings
                ],
                "move_lines": [
                    {
                        "id": line.id,
                        "picking_id": line.picking_id.id,
                        "product_id": line.product_id.id,
                        "product_name": line.product_id.display_name,
                        "quantity": line.quantity,
                        "picked": line.picked,
                    }
                    for line in move_lines
                ],
                "products": [
                    {
                        "id": product.id,
                        "name": product.display_name,
                        "barcode": product.barcode or None,
                    }
                    for product in products
                ],
            }
        )

    @http.route(
        f"{API_PREFIX}/product",
        type="http",
        auth="api_key",
        methods=["GET"],
    )
    def product_by_barcode(self, barcode):
        product = request.env["product.product"].search(
            [("barcode", "=", barcode)], limit=1
        )
        if not product:
            return self._error(f"No product with barcode {barcode}", 404)
        return self._json(
            {
                "id": product.id,
                "name": product.display_name,
                "barcode": product.barcode,
            }
        )

    @http.route(
        f"{API_PREFIX}/op",
        type="http",
        auth="api_key",
        methods=["POST"],
        csrf=False,
    )
    def apply_op(self):
        try:
            body = json.loads(request.httprequest.get_data(as_text=True))
        except json.JSONDecodeError:
            return self._error("Invalid JSON body", 400)
        missing = [key for key in ("uuid", "kind", "payload") if key not in body]
        if missing:
            return self._error(f"Missing fields: {', '.join(missing)}", 400)
        try:
            outcome = request.env["scanner.remote.op"].apply_idempotent(
                body["uuid"], body["kind"], body["payload"]
            )
        except (UserError, ValidationError) as exc:
            # 409: the client should reload the record and let the operator
            # re-scan against fresh state (offline-first conflict rule).
            return self._error(str(exc), 409)
        return self._json(outcome)
