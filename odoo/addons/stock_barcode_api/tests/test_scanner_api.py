# Copyright 2026 Ledo (https://ledoweb.com)
# License AGPL-3.0 or later (https://www.gnu.org/licenses/agpl).
import json
from datetime import datetime, timedelta

from odoo.exceptions import UserError
from odoo.tests import HttpCase, TransactionCase, tagged


class ScannerOpCase(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.warehouse = cls.env["stock.warehouse"].search(
            [("company_id", "=", cls.env.company.id)], limit=1
        )
        cls.product = cls.env["product.product"].create(
            {"name": "Scanner Widget", "is_storable": True, "barcode": "SCAN-001"}
        )
        cls.picking = cls.env["stock.picking"].create(
            {
                "picking_type_id": cls.warehouse.in_type_id.id,
                "location_id": cls.env.ref("stock.stock_location_suppliers").id,
                "location_dest_id": cls.warehouse.lot_stock_id.id,
                "move_ids": [
                    (
                        0,
                        0,
                        {
                            "name": "Scanner Widget",
                            "product_id": cls.product.id,
                            "product_uom_qty": 5,
                            "location_id": cls.env.ref(
                                "stock.stock_location_suppliers"
                            ).id,
                            "location_dest_id": cls.warehouse.lot_stock_id.id,
                        },
                    )
                ],
            }
        )
        cls.picking.action_confirm()
        cls.op_model = cls.env["scanner.remote.op"]

    def test_set_quantity(self):
        line = self.picking.move_line_ids[0]
        outcome = self.op_model.apply_idempotent(
            "uuid-1", "set_quantity", {"move_line_id": line.id, "quantity": 3}
        )
        self.assertFalse(outcome["replayed"])
        self.assertEqual(line.quantity, 3)
        self.assertTrue(line.picked)

    def test_replay_does_not_double_apply(self):
        line = self.picking.move_line_ids[0]
        first = self.op_model.apply_idempotent(
            "uuid-2", "set_quantity", {"move_line_id": line.id, "quantity": 2}
        )
        line.write({"quantity": 4})
        replay = self.op_model.apply_idempotent(
            "uuid-2", "set_quantity", {"move_line_id": line.id, "quantity": 2}
        )
        self.assertTrue(replay["replayed"])
        self.assertEqual(replay["result"], first["result"])
        # The replay must not have re-applied the write.
        self.assertEqual(line.quantity, 4)

    def test_add_product_line(self):
        other = self.env["product.product"].create(
            {"name": "Scanner Gadget", "is_storable": True, "barcode": "SCAN-002"}
        )
        outcome = self.op_model.apply_idempotent(
            "uuid-3",
            "add_product_line",
            {"picking_id": self.picking.id, "product_id": other.id, "quantity": 1},
        )
        line = self.env["stock.move.line"].browse(outcome["result"]["move_line_id"])
        self.assertEqual(line.picking_id, self.picking)
        self.assertEqual(line.product_id, other)

    def test_validate_picking_with_backorder(self):
        line = self.picking.move_line_ids[0]
        self.op_model.apply_idempotent(
            "uuid-4", "set_quantity", {"move_line_id": line.id, "quantity": 2}
        )
        self.op_model.apply_idempotent(
            "uuid-5",
            "validate_picking",
            {"picking_id": self.picking.id, "create_backorder": True},
        )
        self.assertEqual(self.picking.state, "done")
        backorder = self.env["stock.picking"].search(
            [("backorder_id", "=", self.picking.id)]
        )
        self.assertEqual(len(backorder), 1)

    def test_conflict_on_missing_record(self):
        with self.assertRaises(UserError):
            self.op_model._apply(
                "set_quantity", {"move_line_id": 99999999, "quantity": 1}
            )


@tagged("post_install", "-at_install")
class ScannerHttpCase(HttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.user = (
            cls.env["res.users"]
            .with_context(no_reset_password=True)
            .create(
                {
                    "name": "Scanner User",
                    "login": "scanner_user",
                    "email": "scanner@example.com",
                    "groups_id": [
                        (4, cls.env.ref("stock.group_stock_user").id),
                        (4, cls.env.ref("base.group_user").id),
                    ],
                }
            )
        )
        cls.api_key = (
            cls.env["res.users.apikeys"]
            .with_user(cls.user)
            ._generate("rpc", "scanner test key", datetime.now() + timedelta(days=1))
        )

    def _get(self, path):
        return self.url_open(path, headers={"Authorization": f"Bearer {self.api_key}"})

    def test_ping_authenticates_with_api_key(self):
        response = self._get("/scanner/v1/ping")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["api_version"], 1)
        self.assertEqual(data["user_name"], "Scanner User")

    def test_missing_key_is_unauthorized(self):
        response = self.url_open("/scanner/v1/ping")
        self.assertEqual(response.status_code, 401)

    def test_bad_key_is_unauthorized(self):
        response = self.url_open(
            "/scanner/v1/ping", headers={"Authorization": "Bearer not-a-key"}
        )
        self.assertEqual(response.status_code, 401)

    def test_pickings_working_set_shape(self):
        response = self._get("/scanner/v1/pickings?picking_type_code=incoming")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("pickings", data)
        self.assertIn("move_lines", data)
        self.assertIn("products", data)

    def test_op_endpoint_applies_and_replays(self):
        product = self.env["product.product"].create(
            {"name": "HTTP Widget", "is_storable": True, "barcode": "HTTP-001"}
        )
        warehouse = self.env["stock.warehouse"].search(
            [("company_id", "=", self.env.company.id)], limit=1
        )
        picking = self.env["stock.picking"].create(
            {
                "picking_type_id": warehouse.in_type_id.id,
                "location_id": self.env.ref("stock.stock_location_suppliers").id,
                "location_dest_id": warehouse.lot_stock_id.id,
                "move_ids": [
                    (
                        0,
                        0,
                        {
                            "name": "HTTP Widget",
                            "product_id": product.id,
                            "product_uom_qty": 2,
                            "location_id": self.env.ref(
                                "stock.stock_location_suppliers"
                            ).id,
                            "location_dest_id": warehouse.lot_stock_id.id,
                        },
                    )
                ],
            }
        )
        picking.action_confirm()
        self.env.cr.flush()
        line = picking.move_line_ids[0]
        body = {
            "uuid": "http-uuid-1",
            "kind": "set_quantity",
            "payload": {"move_line_id": line.id, "quantity": 2},
        }
        response = self.url_open(
            "/scanner/v1/op",
            data=json.dumps(body),
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            },
        )
        self.assertEqual(response.status_code, 200)
        self.assertFalse(response.json()["replayed"])
        replay = self.url_open(
            "/scanner/v1/op",
            data=json.dumps(body),
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            },
        )
        self.assertTrue(replay.json()["replayed"])
