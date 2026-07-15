# Odoo Mobile — Feature Plan & Status

*(Companion to [PLAN.md](PLAN.md), which holds the original warehouse-scanner
architecture (§1–§10) and the multi-role direction change (§11). This file is
the living feature plan: what the app does, what's next, and how it behaves
against customized servers.)*

## Product definition

One offline-first Android/iOS app, organized by **role modules** on a shared
core. Each module = a Drift mirror of that role's *working set* + typed,
idempotent ops in a shared outbound queue. The server is always the source of
truth; the app is a fast, offline-capable window onto it that never bypasses
server business logic.

## Status by area

### Core (shared) — ✅ working, hardening ongoing
| Feature | Status |
|---|---|
| API-key / password auth (JSON-RPC), secure storage | ✅ |
| Drift mirrors + outbound op queue | ✅ |
| Sync engine: ordered drain, offline retry, conflict + auth-failure surfacing | ✅ |
| Replay safety: quantity ops absolute-set; validate/confirm state-guarded; **creates are at-least-once over raw JSON-RPC** (true UUID dedup needs `stock_barcode_api`'s idempotency ledger) | ⚠️ partial |
| Conflict UX: badge + retry/discard sheet | ✅ (new) |
| Auth failures keep ops pending (never silently dropped) | ✅ (new) |
| Connectivity-triggered sync | ✅ |
| Sync status center (last sync time, per-module result) | ☐ |
| Background sync (WorkManager / BGTaskScheduler) | ☐ |
| Multi-account / multi-database profiles | ☐ |

### Warehouse — ✅ MVP (receipts), breadth pending
| Feature | Status |
|---|---|
| Open receipts list, move lines, scan-to-increment | ✅ |
| Camera (MLKit), Zebra DataWedge, keyboard-wedge input | ✅ |
| Validate + backorder handling | ✅ |
| Deliveries, internal transfers | ☐ (plan §5 Phase 4) |
| Lots/serials, packages, putaway | ☐ |
| Multi-warehouse / operation-type picker | ☐ |
| Undo last scan, quantity edit, sounds | ☐ |
| Switch transport to `stock_barcode_api` when installed | ☐ (server module shipped, client wiring pending) |

### CRM — ✅ v0
| Feature | Status |
|---|---|
| My pipeline grouped by stage | ✅ |
| Stage move, log note, quick-add lead (all offline-queued) | ✅ |
| Pending-sync affordance for local rows | ✅ (new) |
| Activities (schedule/done), calls log | ☐ |
| Search/filter, team pipelines | ☐ |
| Won/lost actions | ☐ |

### Sales — ✅ v0
| Feature | Status |
|---|---|
| My quotations, line detail, confirm (offline-queued) | ✅ |
| Quotation creation / line editing | ☐ |
| Customer lookup, price lists | ☐ |
| Delivery status from confirmed orders | ☐ |

### Server addon (`stock_barcode_api`) — ✅ v1 shipped, unused by app yet
Versioned `/scanner/v1` REST façade with Bearer auth + idempotency ledger.
Next: client transport switch, batched op drain, incremental (cursor) sync,
OCA proposal (Discussion → PR to `stock-logistics-barcode`).

### Quality gates — ✅ in CI
Unit tests (sync/services/client) · **UX widget tests** (screens over real
in-memory DB: grouping, navigation, dialogs, badges, error surfaces) · Odoo
addon tests in the official oca-ci container · release APK build. On-device
integration tests (patrol/integration_test) — ☐.

## How the app reacts to server customization

The app is a **fixed-contract thin client**, not a metadata-driven one. It
reads/writes a small set of stable, standard fields via the ORM. Consequences:

- **Added custom fields** (Studio or module): invisible to the app, zero
  breakage. Server defaults and automations still apply because every write
  goes through the ORM (`create`/`write`/`button_validate`), never raw SQL.
- **Server business logic** (computed fields, constraints, automated actions,
  approval flows): runs normally on every op. If a constraint rejects an op
  (e.g. a custom module requires a field the app didn't send), the op becomes
  a visible **sync issue** with the server's message — retry or discard. The
  app never bypasses or duplicates server rules.
- **Required-on-create customizations** are the main friction point (e.g.
  `crm.lead` gets a mandatory custom field → quick-add ops are rejected).
  Mitigations, in order: server-side defaults, or the `stock_barcode_api`
  façade absorbing the requirement server-side, or (future) a small
  app-config for extra fields.
- **Removed/renamed standard fields** (rare; mostly Odoo version churn, e.g.
  17's `qty_done`→`quantity`): the affected module's pull fails and is
  skipped — other modules keep syncing. The versioned REST façade is the
  long-term hedge: model churn gets absorbed server-side behind `/scanner/v1`.
- **Record rules / ACLs** apply as the logged-in user: the app only ever sees
  what that user may see (mirrors are per-user working sets by design).

Verified in practice: the same client works unmodified against Odoo 18
(production) and Odoo 19 (staging snapshot).

## Sequencing (proposed)

1. **Now**: UX-test suite green → merge PR #1 → field-test on staging-19.
2. Sync status center + undo-last-scan (operator trust features).
3. Warehouse breadth: deliveries + internal transfers (same op pattern).
4. Client transport switch to `stock_barcode_api`; OCA Discussion.
5. Lots/serials; sales order creation; CRM activities.
6. Distribution: signed release APK + TestFlight/F-Droid decision.
