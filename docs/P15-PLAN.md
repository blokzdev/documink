# Phase 15 — Audit log & transparency: Plan

> **Status:** core shipped (15a + 5k); this phase finishes the **transparency UI** layer.
> Plan-of-record per the per-phase convention (started P13).

## 1. Context — what & why

Privacy invariant #7 ("audit-log every privacy-relevant action") is already enforced: the append-only
**`AuditLogRepository`** records the full `AuditEventType` set and supports newest-first **`query`**
(filter by event type(s) + time range, `limit`/`offset` pagination) and RFC-4180 **`exportCsv`** —
all shipped in **15a** and unit-tested. A basic **read-only viewer** (Settings → Audit log) shipped
in **5k**.

The viewer, however, is the thin part. Today it:
- loads a flat **200-entry** list (`auditEntriesProvider`, `limit: 200`) — no pagination, no "load
  more";
- has **no filter UI** (event type / time range) even though the repository already supports both;
- has **no CSV-export action** wired in (the repo's `exportCsv` is unused by the UI);
- renders **raw event-type strings** (`document_saved`, `mink_tool_call`, …) with a 4-icon switch; and
- is **not localized** — every string is a hardcoded English literal, violating the CLAUDE.md
  "localize whole screens" rule.

Roadmap §15 asks for exactly this: "Settings → Audit Log (paginated, filterable by event type and
time range)" + "CSV export (shipped in V1 with an internal flag for Pro-gate activation in V1.1)".
Phase 15 closes that gap. It is **headless-friendly** (pure UI + repository already in place; no new
native capability), so it ships and verifies fully here.

## 2. Already shipped (reference)

| Slice | PR | What |
| --- | --- | --- |
| **15a** | (earlier) | `AuditLogRepository`: `record` (all event types) · `query` (event-type + time-range filters, `limit`/`offset`) · `exportCsv` (RFC-4180). Unit-tested. |
| **5k** | (earlier) | Settings → Audit log: a read-only newest-first list (IDs/metadata only, never PII). Widget-tested. |

All `AuditEventType` producers across the app already record (documents, decode/reveal, export,
sync, vault unlock, biometric, Mink tool calls + denials, suggestions, tier/variant/model/manifest,
projects, and — added in P14d — personal templates).

## 3. Plan — slices

### 15b-1 — Filterable, paginated, localized viewer ✅ (this PR)
- **Filter bar**: an event-type filter (multi-select chips or a bottom-sheet of grouped types) + a
  time-range selector (All / 24h / 7d / 30d, mapping to `sinceEpochMs`). Drive a new
  family/`StateProvider`-backed `auditEntriesProvider` that passes `eventTypes` + `sinceEpochMs` to
  `AuditLogRepository.query`.
  - **Shipped:** `AuditViewNotifier`/`auditViewProvider` (range + selected types + `limit`); the
    `auditEntriesProvider` is now a function of it. Range = a row of `ChoiceChip`s; types = a grouped
    multi-select bottom sheet (a `filter_list` button with a count badge). `auditRangeSince` maps the
    window. Pagination is a "Load more" footer growing `limit` by `auditPageSize` (50). Event labels
    come from a pure, unit-tested `prettifyAuditEvent` (event types are canonical data, shown the way
    raw PII labels already are). The whole screen is localized (`audit*` ARB keys).
- **Pagination**: replace the flat `limit: 200` with incremental paging (`limit`/`offset`) — a
  "Load more" footer or scroll-to-end trigger; keeps memory bounded for long histories.
- **Human-readable labels + grouping**: map each `AuditEventType` to a localized label + icon
  (extend the current 4-icon switch to the full set, grouped: documents / security / AI / projects /
  sync). A small pure mapper (`auditEventLabel(l10n, type)`), unit-testable.
- **Localize the whole screen** (CLAUDE.md hard rule): move every literal — title, empty/error
  states, filter labels, event labels — into `lib/l10n/app_en.arb` → regen `lib/l10n/gen/`.
- Tests: widget tests for filter application (type + range narrow the list), pagination ("load more"
  appends), empty/error states; a unit test for the label mapper.

### 15b-2 — CSV export action (V1 ships it; internal Pro-gate flag) ✅ (this PR)
- An **Export CSV** app-bar action that runs `AuditLogRepository.exportCsv(entries)` over the
  **current filter** and hands the text to the existing share/save path (reuse the Phase-7 share
  stack seam if available; otherwise copy-to-clipboard + a `VERIFICATION.md` item for the native
  file share, consistent with the Mink-memory export precedent).
  - **Shipped:** an `ios_share` app-bar action → a dialog with the CSV in a `SelectableText` + a
    **Copy** button (clipboard), built over the **active filter's** entries. No Phase-7 share stack
    exists yet, so the local clipboard path mirrors the Mink-memory export; the native **file share**
    is a `VERIFICATION.md` device item. Gated behind **`auditCsvExportEnabledProvider`** (a `Provider<bool>`
    defaulting **true** for V1; V1.1 flips it to a Pro check in one place). No self-audit event for
    exporting the log (a local read; an event referencing the log would be circular). Widget-tested
    (CSV content over the filter; action hidden when the flag is off).
- **Internal Pro-gate flag**: gate the action behind a single feature flag (default **on** for V1 per
  roadmap §15 "shipped in V1 with internal flag for Pro-gate activation in V1.1") — a `const` /
  settings-backed bool, logged in `docs/DECISIONS.md` so V1.1 can flip it to Pro-only without a
  code archaeology hunt.
- An **`audit_log_exported`-style** self-audit? **No** — exporting the audit log is a user-initiated
  local read; adding an event that references the log would be circular. Decision logged either way.
- Tests: widget test that the action produces CSV over the active filter; flag-off hides the action.

## 4. Privacy / invariants
- **IDs/metadata only, never PII** — unchanged; the repository already guarantees this and the CSV is
  built from the same `AuditEntry` fields. No raw values are ever surfaced or exported.
- **No egress** — CSV export is local (share/clipboard); consistent with the no-telemetry posture.
- **Read-only** — the viewer never mutates the append-only log.
- **Scope** — entries are workspace-scoped (`DocumentRepository.defaultWorkspaceId`); no cross-project
  leakage (the log is workspace-global transparency, by design — §15).

## 5. Verification
- **Headless (CI/here):** `flutter analyze --fatal-infos --fatal-warnings` clean; `flutter test`
  green (+ new viewer/mapper tests); `analytics-scan`/`license-scan` pass; **codegen-freshness** =
  only `lib/l10n/gen/` regenerated (no drift change).
- **Device (`VERIFICATION.md`):** native CSV **file share** (if routed through the share stack) on a
  real device; large-history scroll/pagination performance.

## 6. Out of scope (tracked)
- **Pro-gate enforcement** itself (flipping the flag to Pro-only) — V1.1.
- **Cross-project / cross-workspace** audit views — would need `AuditedCrossProjectAccess` (deferred
  with the memory work).
- Any new event types — the producer set is already complete.
