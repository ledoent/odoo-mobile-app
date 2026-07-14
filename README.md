# Odoo Mobile

[![flutter](https://github.com/ledoent/odoo-mobile-app/actions/workflows/flutter.yml/badge.svg)](https://github.com/ledoent/odoo-mobile-app/actions/workflows/flutter.yml)
[![odoo](https://github.com/ledoent/odoo-mobile-app/actions/workflows/odoo.yml/badge.svg)](https://github.com/ledoent/odoo-mobile-app/actions/workflows/odoo.yml)

An open-source, **Android-first, offline-first** mobile app for Odoo,
organized by role:

- **Warehouse** — barcode receiving (camera, Zebra DataWedge, keyboard
  wedge); a FOSS alternative to Ventor Pro
- **CRM** — my pipeline: leads by stage, stage moves, notes, quick-add
- **Sales** — my quotations: review lines, confirm orders

Every module runs on the same offline core: a local Drift mirror plus an
idempotent op queue, so all roles work with no signal and sync when it
returns. A thin, OCA-candidate REST module gives the warehouse flows a
stable, versioned server contract.

See [PLAN.md](PLAN.md) for the full architecture and roadmap (§11 covers the
multi-role layout).

## Monorepo layout

| Path | What | License |
| ---- | ---- | ------- |
| [`app/`](app/) | Flutter app (`odoo_scanner`) — Riverpod, Drift offline mirrors + op queue, role modules (warehouse / CRM / sales), `mobile_scanner`, Zebra DataWedge | [MIT](app/LICENSE) |
| [`odoo/addons/stock_barcode_api/`](odoo/addons/stock_barcode_api/) | Odoo 18 addon: `/scanner/v1/` REST endpoints, Bearer API-key auth, idempotent ops | [AGPL-3](odoo/LICENSE) |

The two halves are deliberately decoupled: the app speaks raw JSON-RPC out of
the box (no server module required), and upgrades to the `stock_barcode_api`
endpoints when they're installed. The addon follows OCA conventions
(manifest, readme fragments, oca-ci test workflow) so it can be proposed to
[OCA](https://github.com/OCA) — likely `stock-logistics-barcode` — with a
straight copy of the module directory.

## App quick start

```sh
cd app
flutter pub get
dart run build_runner build   # drift + auto_route codegen
flutter test
flutter run                   # on an Android device/emulator
```

On first launch, enter your server URL, database, login, and an API key
(Odoo → Preferences → Account Security → API Keys). The password never
leaves Odoo; the key is stored in the Android keystore.

**Scanning inputs** (all active at once on the picking screen):

- Camera (MLKit via `mobile_scanner`)
- Zebra DataWedge — configure a DataWedge profile for the app with Intent
  output, action `com.ledoweb.odoo_scanner.SCAN`, delivery *Broadcast intent*
- Keyboard-wedge scanners — scan into the barcode field

**Offline-first:** every mutation is appended to a local op queue (Drift) and
applied optimistically; the sync engine drains the queue when connectivity
returns. Server rejections are surfaced as conflicts for re-scan, never
silently overwritten. See `app/lib/data/sync/`.

## Addon quick start

```sh
# add odoo/addons to your addons_path, then
odoo -d yourdb -i stock_barcode_api
curl -H "Authorization: Bearer <api key>" https://your-odoo/scanner/v1/ping
```

Endpoint reference: [`readme/USAGE.md`](odoo/addons/stock_barcode_api/readme/USAGE.md).

## Development

- **Flutter CI** (`.github/workflows/flutter.yml`): format, committed-codegen
  check, analyze, tests with coverage, release APK artifact.
- **Odoo CI** (`.github/workflows/odoo.yml`): pre-commit (ruff +
  OCA odoo-module checks), then install + test against Odoo 18 in the
  official [oca-ci](https://github.com/OCA/oca-ci) container — the same job
  OCA repos run, so upstream CI holds no surprises.
- Pre-commit locally: `pipx install pre-commit && pre-commit run --all-files`.

## Status

Alpha — MVP flow is "receive a purchase order": list open receipts, scan
product barcodes to count, validate (with backorder). Lots/serials, packages,
and other operation types are on the [roadmap](PLAN.md#5-phased-roadmap).
