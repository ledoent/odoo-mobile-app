Versioned REST endpoints (`/scanner/v1/`) for mobile barcode scanner
applications, designed for **offline-first** clients:

- **Bearer API-key authentication** — devices authenticate with standard Odoo
  API keys (`Authorization: Bearer <key>`), so no password ever leaves the
  device and keys can be revoked per device.
- **Working-set pull** — one round-trip returns the open pickings of an
  operation type together with their move lines and product barcodes, ready
  to mirror into a local database.
- **Idempotent operations** — every mutating call carries a client-generated
  UUID. Replays (e.g. a retry after a dropped response) return the recorded
  result instead of double-applying, which makes aggressive offline retry
  loops safe.
- **Conflict signalling** — operations that can no longer apply (record
  deleted, picking already validated) return HTTP 409 so the client reloads
  and lets the operator re-scan instead of blindly overwriting.

The reference client is the
[Odoo Warehouse Scanner](https://github.com/ledoent/odoo-mobile-app) Flutter
app (FOSS, Android-first, Zebra DataWedge support), but the endpoints are
client-agnostic.
