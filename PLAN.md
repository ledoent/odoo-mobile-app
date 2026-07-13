# Odoo Warehouse Scanner — Project Plan

An open-source, **Android-first** warehouse/inventory scanning app for Odoo (a FOSS
alternative to Ventor Pro), backed by a thin **OCA-candidate REST module**.

Status: planning. Target Odoo: 18 (works back to 16 via the API module).

---

## 1. Framework decision — Flutter

| | Flutter (chosen) | React Native |
|---|---|---|
| 2026 state | Impeller 2.0 renderer; hot reload gold-standard | New Architecture (Fabric/JSI/TurboModules) default & production-ready |
| Perf for CRUD/ops UI | ✅ indistinguishable at this workload | ✅ indistinguishable |
| Barcode ecosystem | ✅ more complete out-of-box (`mobile_scanner`) | concise but view-overlay limits |
| Offline DB | ✅ **Drift** (typed SQLite) | WatermelonDB / op-sqlite |
| **Your leverage** | ✅✅ immich = a working Flutter + Drift + Riverpod + auto_route + mobile_scanner reference you just learned | JS talent pool / web code-share |

**Rationale:** performance is a wash in 2026, so the tiebreaker is that you already
have a real, working reference codebase (immich) for every hard part of this app —
offline SQLite via Drift, Riverpod state, `mobile_scanner`, auto_route. Pick RN only
if sharing code with a JS web app becomes a priority.

---

## 2. Architecture — two repos

```
┌──────────────────────────────┐         JSON over HTTPS          ┌───────────────────────────┐
│  odoo-scanner (Flutter/Android)│ ───────────────────────────────▶ │  Odoo 18 server            │
│  • Riverpod state              │   API key auth (Odoo 14+)        │  ┌──────────────────────┐ │
│  • Drift local mirror + queue  │ ◀─────────────────────────────── │  │ stock_barcode_api    │ │  ← OCA-candidate module
│  • mobile_scanner + DataWedge  │      REST (base_rest)            │  │ (base_rest endpoints)│ │     (propose upstream)
│  • flutter_secure_storage      │                                  │  └──────────────────────┘ │
└──────────────────────────────┘                                    └───────────────────────────┘
```

- **App repo** (this folder, public, MIT/Apache) — moves fast, yours.
- **Backend module** (`stock_barcode_api`) — a Python addon on OCA `base_rest`. The
  reusable/community-valuable half; **propose to OCA** (fits their maintainer base;
  a mobile app does not — see §8).
- Talk to a **typed REST façade**, not raw `call_kw`. It keeps the client sane and
  hides Odoo model churn behind versioned endpoints.

---

## 3. Stack (Flutter)

| Concern | Choice | Notes |
|---|---|---|
| Language/UI | Flutter + Dart 3 | Android-only build target to start |
| State | `riverpod` / `hooks_riverpod` | same as immich |
| Local DB | `drift` | offline mirror + outbound op queue (you know this now) |
| HTTP | `dio` | interceptors for auth + retry |
| Odoo client | thin JSON-RPC client **or** `odoo_rpc` pub pkg | *verify pkg maintenance first*; a 100-line JSON-RPC client is fine and dependency-light |
| Camera scan | `mobile_scanner` | MLKit, same as immich |
| HW scanners | DataWedge via `MethodChannel`/`BroadcastReceiver` (Zebra) + hidden-field keyboard-wedge fallback | this is the enterprise differentiator |
| Secure store | `flutter_secure_storage` | store the Odoo API key, never a password |
| Routing | `auto_route` | same as immich |
| Connectivity | `connectivity_plus` | drives the sync trigger |
| Codegen | `build_runner` + `drift_dev` | drift schema/migrations |

Auth model: user pastes **server URL + creates an API key** in Odoo (Preferences →
Account Security → API Keys). App stores the key in `flutter_secure_storage`. No
password ever leaves the device.

---

## 4. MVP scope (v0.1 — "receive a PO")

Prove the whole vertical slice on one flow before generalizing:

1. **Onboarding:** enter server URL, validate, paste API key, pick warehouse.
2. **Pick an operation:** list open `stock.picking` for a chosen operation type
   (start with *Receipts*).
3. **Scan flow:** open a picking → scan a product barcode → increments the matching
   `stock.move.line.qty_done` (or creates a line) → visual confirm → scan next.
4. **Validate:** button posts the picking (`button_validate`), handles the
   immediate-transfer / backorder wizard, shows result.
5. **Offline:** every mutation goes through the local queue; works with no signal and
   syncs when back online (§6).

Explicitly **out of scope for v0.1:** lots/serials, package handling, putaway,
multi-step routes, iOS. Add after the slice works.

---

## 5. Phased roadmap

- **Phase 0 — Skeleton (1–2 days):** `flutter create`, wire Riverpod + auto_route +
  Drift, settings screen, RPC auth, read & display one `stock.picking` **online only**.
- **Phase 1 — Scan online (2–4 days):** `mobile_scanner`, barcode→product lookup,
  write `qty_done`, `button_validate` + backorder wizard. Real device, real Odoo test DB.
- **Phase 2 — Offline-first (the hard part, 1–2 wks):** Drift mirror of the working
  set (open pickings, their move lines, product barcodes) + outbound op queue + sync
  engine (§6).
- **Phase 3 — Hardware + UX (1 wk):** DataWedge intent channel, keyboard-wedge
  fallback, big-touch ops UI, error/undo, sounds/haptics.
- **Phase 4 — Breadth (ongoing):** deliveries, internal transfers, lots/serials,
  packages; signed release + F-Droid / internal APK distribution.

---

## 6. Offline-first sync strategy (design up front — it's the make-or-break)

- **Local mirror (read):** on sync, pull the *working set* only — open pickings for
  the selected op type + their move lines + the product/barcode rows they reference —
  into Drift. Not the whole DB.
- **Outbound queue (write):** never write to Odoo directly from the UI. Append a typed
  *operation* to a Drift `op_queue` table (e.g. `SetQtyDone{moveLineId, qty}`,
  `ValidatePicking{id}`), and optimistically update the local mirror so the UI is instant.
- **Sync engine:** on connectivity (`connectivity_plus`) drain the queue in order,
  each op → one REST call. On success, mark done + refresh that record. On conflict
  (server changed underneath), reload the record and surface it for re-scan rather than
  blindly overwriting — mirrors the fail-safe you built into the metadata-dedup server.
- **Idempotency:** give each op a client UUID so a retry after a dropped response can't
  double-apply. (Have the API module dedupe on that UUID.)
- **Conflict rule of thumb:** quantities are additive/last-writer-wins is dangerous;
  prefer "reload + let the operator confirm" for validation-level actions.

This is the one area to prototype early with flaky-network testing — everything else is CRUD.

---

## 7. Repo layout (app)

```
odoo-scanner/
├─ PLAN.md                     ← this file
├─ pubspec.yaml
├─ lib/
│  ├─ main.dart
│  ├─ core/            (config, theme, router)
│  ├─ data/
│  │  ├─ odoo/         (JSON-RPC/REST client, models, api-key auth)
│  │  ├─ local/        (drift db, tables: pickings, move_lines, products, op_queue)
│  │  └─ sync/         (sync engine, connectivity)
│  ├─ features/
│  │  ├─ onboarding/   (server url + api key + warehouse)
│  │  ├─ pickings/     (list, detail)
│  │  └─ scan/         (scanner, move-line increment, validate)
│  └─ platform/        (datawedge MethodChannel)
├─ android/            (DataWedge BroadcastReceiver in MainActivity)
└─ test/               (sync-engine tests with a fake Odoo)
```

Backend module lives in a **separate** repo/dir (your OCA fork), e.g.
`stock_barcode_api/` on `base_rest`.

---

## 8. The OCA path

- OCA hosts **Odoo addons**, not mobile apps, and its maintainers are Python devs —
  so proposing "an OCA Android app" would stall on maintainership.
- **Do** propose the **`stock_barcode_api`** module (base_rest endpoints for the flows
  above) — that fits OCA perfectly and gives the app a stable, versioned contract.
- Process: open a **GitHub Discussion** on the relevant OCA repo (or the mailing list)
  describing the module + endpoints, gauge interest, then PR it (run it through your
  `oca-candidate` / `oca-contrib` workflow). Reference VentorTech's precedent: their
  Odoo modules are open (e.g. `stock_move_location`), the app is proprietary — the FOSS
  app niche is genuinely open.
- Keep the app repo independent (your org), MIT/Apache, linking to the OCA module as
  its required server dependency.

---

## 9. First commands

```bash
cd /Users/dkendall/projects/odoo-scanner
flutter create --org com.donkendall --platforms=android --project-name odoo_scanner .
flutter pub add riverpod hooks_riverpod flutter_hooks dio drift drift_flutter \
  mobile_scanner flutter_secure_storage auto_route connectivity_plus
flutter pub add --dev build_runner drift_dev auto_route_generator
# then: lib/ scaffolding per §7, and a throwaway Odoo 18 test DB with an API key
```

Backend (separate):
```bash
# in your odoo custom addons, on OCA rest-framework (base_rest + base_rest_datamodel)
#   scaffold module stock_barcode_api with a /scanner/v1/ endpoint set
```

---

## 10. Open decisions to make before Phase 0

- [ ] **RPC vs REST for v0.1:** ship raw JSON-RPC first (zero backend work, fastest to a
      demo) and introduce `stock_barcode_api` in Phase 2? *(Recommended — don't block the
      app on the module.)*
- [ ] **`odoo_rpc` pub package vs hand-rolled client** — check the package's last-updated
      date & Odoo-18 compatibility; if stale, hand-roll (~100 lines).
- [ ] **Target scanner hardware** — Zebra (DataWedge) vs Honeywell vs camera-only? Drives §3.
- [ ] **Repo/org name + license** (MIT vs AGPL — AGPL keeps derivatives open, fits the
      "FOSS Ventor" framing).
- [ ] **Distribution** — Play Store, internal APK, or F-Droid?

---

*Verdict recap: Flutter, Android-first, thin app over a REST façade; propose the façade
to OCA, keep the app independent. Start with raw JSON-RPC to reach a working scan demo
in days, then invest in the offline sync engine — that's the part that makes or breaks it.*
