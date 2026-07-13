Create an API key in Odoo (Preferences → Account Security → API Keys) for a
user with *Inventory / User* rights, then call the endpoints with a Bearer
header:

    curl -H "Authorization: Bearer <api key>" \
        https://your-odoo/scanner/v1/ping

Endpoints (all JSON):

| Method | Route | Purpose |
| ------ | ----- | ------- |
| GET | `/scanner/v1/ping` | Auth check; returns server + user info |
| GET | `/scanner/v1/pickings?picking_type_code=incoming` | Working set: open pickings, move lines, product barcodes |
| GET | `/scanner/v1/product?barcode=<code>` | Product lookup by barcode |
| POST | `/scanner/v1/op` | Apply an operation idempotently |

`POST /scanner/v1/op` body:

    {
      "uuid": "<client-generated, unique per operation>",
      "kind": "set_quantity" | "add_product_line" | "validate_picking",
      "payload": { ... }
    }

Payloads:

- `set_quantity`: `{"move_line_id": 42, "quantity": 3}`
- `add_product_line`: `{"picking_id": 7, "product_id": 100, "quantity": 1}`
- `validate_picking`: `{"picking_id": 7, "create_backorder": true}`

Responses carry `{"replayed": false, "result": {...}}`; sending the same
`uuid` twice returns `"replayed": true` with the original result and does not
re-apply the operation. A `409` response means the operation no longer
applies (e.g. the picking was validated elsewhere) — reload the working set
and re-scan.
