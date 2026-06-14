# Decisions log

Running record of **key decisions the specs did not fully determine**, made autonomously under
the Option-C continuous-loop autonomy contract (see `CLAUDE.md`). Each entry lists the options
considered, the choice, and the rationale, for later human review. Genuine spec conflicts and
security-sensitive resolutions are flagged **⚠ review**.

Format: newest first. A decision that later graduates into a spec/ADR notes the ADR id.

---

## 2026-06-14 — V1 Phase 4d: inbound share-sheet intent (completes Phase 4 input)

- **Scope:** other apps share text/images INTO DocuMink (`ACTION_SEND`). Last Phase 4 input handler;
  done before the high-stakes Phase 4c (maintainer-chosen order).
- **Plugin:** `receive_sharing_intent ^1.8.1` (**Apache-2.0**, license-clean; resolves on the pinned
  toolchain — dry-run verified; scanner green). Chosen over `share_handler` (MIT) as the more
  established option; both were pre-vetted. Exposes `getInitialMedia()` (cold start) +
  `getMediaStream()` (warm/singleTop) + `reset()`.
- **Reuse:** received text → the editor's existing `initialText` seam; received image → the existing
  `_ingestImage` OCR path (new `ingestSharedText`/`ingestSharedImage` on `InputIngestionService`).
  `InputSourceKind.sharedText` already existed.
- **Held-until-unlocked (privacy + correctness):** the editor needs the unlocked vault and PII must
  not route into a locked app, so `ShareIntentCoordinator` holds a share received while locked and
  flushes it on the `appUnlockedProvider` locked→unlocked transition. The coordinator is pure-Dart
  and unit-tested (navigation injected as a callback, not the GoRouter; unlock state injected).
- **Route both text & image to the editor** (images OCR'd first) rather than a separate shared-image
  "recognized text review" screen — consistent + minimal for V1; richer review can come later.
- **Root wiring:** `DocuMinkApp` became a `ConsumerStatefulWidget` to own the coordinator lifecycle
  (start after first frame; `ref.listenManual(appUnlockedProvider)` to flush; dispose the stream sub).
- **V1 takes the first shared item;** `SEND_MULTIPLE` batch beyond the first is V3.
- **Build fix:** `receive_sharing_intent` 1.8.1's Android module compiles Java at 1.8 but Kotlin at
  17; AGP 8 + Kotlin 2.x fail that intra-module mismatch. Set
  `kotlin.jvm.target.validation.mode=warning` in `android/gradle.properties` (our own modules stay
  uniformly 17). The mixed target is benign on minSdk 26 (D8 desugars); revisit when the plugin aligns.

## 2026-06-14 — Design intent: encrypted original-document retention + reveal (Phase 4c) ⚠ review

- **Context (maintainer-requested):** while discussing the rasterized-page temp file, the maintainer
  asked whether originals could be kept encrypted and the original PII revealed via passcode/biometric.
  Findings: (1) the rasterized OCR PNG is throwaway scaffolding (delete-after-use is right); (2)
  "reveal original PII via biometric" **already exists for text** (reversible tokens → AES-256-GCM in
  `tokens`, biometric-gated reveal in `reveal_service.dart` / `document_detail_screen.dart`, audited
  `document_reveal`); (3) the **original source document itself is NOT stored** — only a
  non-recoverable SHA-256 `sourceHash`. So "keep + reveal the whole original" is a genuine new feature.
- **Scope decision (maintainer-chosen):** ship the temp-file hardening now; **design + roadmap** the
  feature now (this note + roadmap Phase 4c); **build it as its own dedicated, security-reviewed PR.**
  Not folded into the hardening change (it touches vault schema + crypto + a new reveal surface).
- **Deviation note:** this extends beyond PRD §4.6 (entity-level decode) to document-level retention.
  Surfaced per deviation-protocol; proceeding because it's user-directed and consistent with the
  privacy-first reversible model. Flagged ⚠ for the maintainer + `security-review` at build time.
- **Design (to implement next):**
  - **Storage:** new `document_originals` table `(id, documentId FK, mime, ciphertext BLOB, createdAt)`
    — keeps `documents` lean, allows lazy load. **First drift migration** (schemaVersion 1→2,
    `onUpgrade` → `m.createTable`); `app_database.dart` currently has `onCreate`-only at version 1.
  - **Crypto:** reuse `TokenCrypto.encrypt/decrypt` (AES-256-GCM, AAD = documentId) via
    `VaultService.tokenCrypto` + the unlocked DEK. No new key material.
  - **Retain:** carry the original source bytes through ingestion/save (opt-in; default off for
    storage growth). The OCR scaffold is never stored — only the user's actual file.
  - **Reveal:** "View original · biometric" mirroring `RevealService` → `Authenticator` → decrypt →
    transient secure viewer (`Image.memory` / PDF render), **FLAG_SECURE**, audited
    (`document_original_revealed`); plaintext never persisted/logged.
  - **Invariants:** encrypted at rest under the DEK; never synced in plaintext (SyncEnvelope seals
    deltas); biometric-gated; audited. High-stakes per CLAUDE.md → fuller logging at build time.

## 2026-06-14 — V1 Phase 4 hardening: delete rasterized PDF page-images after OCR

- **Context:** post-merge web research on the 4a/4b pipeline. `PdfxPageRasterizer` writes each
  scanned page to a PNG in `getTemporaryDirectory()` (app-private cache, not auto-backed-up) to feed
  OCR — but **never deleted** it. For a privacy-first app, those PII-laden page-images must not
  linger in cache until the OS evicts them.
- **Options:** (A) delete-after-use (try/finally); (B) in-memory `InputImage.fromBytes` so nothing
  touches disk; (C) leave as-is (rely on OS cache eviction).
- **Choice:** **A.** New `TempFileDisposer` seam (default real `IoTempFileDisposer`, best-effort
  delete; recording fake in tests); `importPdf()` disposes each rasterized page in a `finally` so it
  goes even if OCR throws. Tested (incl. the throw path). **(B) rejected** — ML Kit `fromBytes` wants
  NV21/YUV and our `OcrRecognizer` seam is path-based; the RGBA→NV21 marshaling isn't worth it.
  Scope: only files **we** create (rasterized pages); we don't delete `image_picker`/camera files.
- **Also (marginal):** capped raster resolution (longest edge ≤ 2400 px) to bound memory on huge
  pages; added explicit `-keep …text.latin.**` beside the `-dontwarn` (ML Kit plugin ships no
  consumer R8 rules — flutter-ml/google_ml_kit_flutter#744, so `-dontwarn` stays).
- **Logged, not actioned — `pdfrx` consolidation:** one pdfium lib could replace
  flutter_pdf_text + pdfx (~5–9 MB lighter), but `pdfrx` needs Flutter ≥ 3.41.0 vs. our pinned
  3.38.6. Deferred to the next toolchain bump (CLAUDE.md "Deferred opportunities").

## 2026-06-14 — V1 Phase 4b: PDF import + input-flow polish

- **Scope (maintainer-chosen split):** complete **PDF import** now (text-layer + per-page OCR
  fallback); **inbound share-sheet intent is the next PR** (a separate native surface). All four
  surfaced polish items folded in: localize capture + paste-editor strings, source badge +
  multi-page/scanned warnings, "Choose from gallery" in scan mode, a11y `Semantics`.
- **PDF package choices (license-clean; verified by dry-run resolve + the CI license scanner):**
  - **`flutter_pdf_text` ^0.9.0** (MIT; Apache PDFBox on Android) — text-layer extraction per page.
  - **`pdfx` ^2.9.2** (MIT) — rasterizes scanned/text-less pages to a temp PNG.
  - **`file_selector` ^1.1.0** (BSD-3, Flutter team) — PDF picking. **Chose over `file_picker`:**
    `file_picker` only resolved to a stale `3.0.4` (latest 11.x) on the pinned toolchain — a
    constraint conflict pinned it back — whereas `file_selector` resolved to current versions.
  - **Rejected:** `syncfusion_flutter_pdf` (commercial) and `doc_text_extractor` (depends on it) —
    deny-list per `.agents/rules/license-policy.md`.
- **Reuse, not a new OCR seam:** the rasterizer writes a page to a temp image file and the
  orchestrator feeds that path to the **existing** `OcrRecognizer.recognizeImage` — a scanned PDF
  page reuses the exact ML Kit OCR pipeline as a captured photo. Decision logic: per page, use the
  text layer if non-empty, else rasterize → OCR; concatenate with `--- Page N ---` markers for
  multi-page; warnings name the OCR'd pages and flag fully-empty extraction.
- **Friendly errors:** added an `InputUnavailableException` marker so the capture UI shows our
  authored seam messages verbatim but masks unexpected raw errors (e.g. native `PlatformException`)
  behind a generic fallback.
- **Localization scope (honest):** localized the **widget-layer** strings (titles, buttons, hints,
  labels, source badges, operator names). Strings generated in the pure-Dart service/controller
  (PDF warnings with interpolated page numbers, the operator-error message) stay English for now —
  localizing them properly means structuring them as typed codes, tracked as a follow-up. V1 is
  English-only regardless; this advances the i18n scaffolding for V3.
- **No AndroidManifest change:** `file_selector` uses the Storage Access Framework (no storage
  permission) and pdfx/PDFBox need no permissions.

## 2026-06-14 — Workflow: build device-bound phases behind seams (no phase-boundary stop)

- **Context:** native/UI/model phases (4 input, 7 render, 8 transport, 10–14 Mink/LLM, 16 a11y)
  were previously framed as "defer to a device session." That stalls the autonomous roadmap loop
  at every native phase, even though most of each phase is pure-Dart orchestration that **is**
  headless-testable (the codebase already proves this: Authenticator→`local_auth`, ML Kit
  annotator, device-signal collector, sync transport — all seam + fake + real-adapter).
- **Options:** (A) keep deferring whole native phases to device sessions; (B) **build each native
  phase here behind seams** — pure-Dart orchestrator + safe-default seam + compile-only real
  adapter + fake-driven tests — and **batch the un-runnable native checks into `VERIFICATION.md`**.
- **Choice:** **B** (maintainer-directed, 2026-06-14). Codified in **CLAUDE.md → "Device-bound
  phases: build behind seams now, batch verification."** Loop continues through native phases;
  never claim a deferred device check passed; un-buildable remainders (e.g. needing a vetted
  plugin) ship as tracked follow-ups rather than blocking.
- **Rationale:** maximizes headless-verifiable progress, keeps the loop moving, preserves honesty
  (the seam pattern already deny-by-defaults the un-wired native path).

## 2026-06-14 — Roadmap completeness: capture deferred Mink/AI vision

- **Context:** maintainer asked to ensure the rich Mink vision + envisioned features are all on the
  roadmap so they're tackled at an optimal point. Gap audit (PRD/blueprint §5 vs roadmap) found
  features deferred in the PRD but **absent from the roadmap**.
- **Findings → additions:**
  - **Voice I/O, extended multimodal I/O, background agents** (PRD §5.2/§14 "deferred to V3+") were
    not on the roadmap → added **V3 Phase 10 "Mink interaction expansion"** (independent of Teams;
    depends only on the V1 Tier-4 runtime; sequenced after V3 inference work). Each mode preserves
    the V1 invariants (on-device, reactive default, biometric gate, audit) and defaults off.
  - **In-app "report AI output" mechanism** (PRD §9.1, Play AI-Generated-Content policy) was not on
    the roadmap → added to **V1 Phase 12 chat UI** (flags locally, audit-logged, nothing leaves the
    device — consistent with zero-telemetry).
- **Already covered (no change):** chat/sessions/tools/streaming/model-indicator/token-ref masking,
  proactive suggestions (P13), typed memory + memory UI (P12), domain inference (P14), merge
  projects/teams (V3), community templates/WAN dispatch/e-sign (V4), multilingual/formats/LAN (V3).
- **Choice:** additive only — no resequencing of existing phases. Logged for review.

## 2026-06-14 — V1 Phase 4a: input (camera scan + image import → OCR → redact)

- **Branch hygiene:** the session branch `claude/documink-bootstrap-audit-6ml8o2` was stale (its one
  commit was the already-squash-merged "Enablement" work; 12 commits behind `main`). Reset it to
  `main` before building — verified the Enablement content (build-apk/release workflows, SETUP.md,
  VERIFICATION.md, gradle signing) is already on `main`.
- **Scope (this PR):** the scan/image→OCR→redact vertical slice (PRD §7.2). New `lib/features/input/`:
  `IngestedText`/`InputSourceKind`, `OcrRecognizer` + `ImageInputSource` seams (fail-loud
  `Unavailable*` defaults — never silently return empty, which would read as "no PII"), the pure-Dart
  `InputIngestionService`, `CaptureController`/`CaptureScreen` (scan & import modes), providers, and
  real adapters `MlKitTextRecognizer` / `SystemImageSource`. The paste editor gained an `initialText`
  seam so any source feeds the existing detection/redaction/save flow (one redaction surface).
- **Plugins:** `google_mlkit_text_recognition ^0.15.0` + `image_picker ^1.1.2` — both resolve on the
  pinned toolchain (dry-run checked); both Apache-2.0/BSD (license-clean). AndroidManifest adds CAMERA
  + bundles the ML Kit Latin OCR model (`com.google.mlkit.vision.DEPENDENCIES=ocr`) for offline OCR.
- **Deferred (tracked follow-ups, not this PR):**
  - **PDF import** (text-layer extraction + per-page OCR fallback). Held because the obvious PDF text
    packages need a **license check** — Syncfusion is commercial (deny-list), so a license-cleared
    (Apache/MIT/BSD) extractor must be vetted first per `.agents/rules/license-policy.md`.
    Shipping the seam-less core would be premature; logged instead of rushed.
  - **Inbound share-sheet intent** (receive shared text/images from other apps) — a separate native
    surface (`receive_sharing_intent`-class), best done alongside Phase 7's outbound share.
- **Headless tests:** `InputIngestionService` (success/cancel/empty/error/unwired), `CaptureController`
  state machine, `CaptureScreen` widget (affordance/recognized-text/warning/error), paste-editor
  `initialText` auto-detect. Device checks batched into `VERIFICATION.md`.

## 2026-06-14 — V1 Phase 7: export (headless core)

- `ExportService` (pure) builds two artifacts from a redacted document: the **redacted text** and a
  **JSON metadata sidecar** (versioned; name/type/status/createdAt + entity type/operator/offsets +
  redactedText). **No PII** — only de-identified metadata + the already-redacted text.
- Detail screen **Export** action → bottom sheet (copy text / copy JSON) → Clipboard + a
  `document_exported` audit entry. Clipboard is wrapped in try/catch so the audit/feedback never
  block on the platform channel (absent in headless tests).
- **Native share-sheet / file-save deferred** to a device task (the genuinely native part);
  VERIFICATION.md tracks it. The content-generation core is what's headless-testable, and it's
  fully unit-tested.
- Export widget test asserts the sheet wiring (deterministic); fire-and-forget audit timing isn't
  asserted in the widget test (covered by `AuditLogRepository` tests + the ExportService unit test).

## 2026-06-14 — V1 Phase 6: custom entity types UI

- List/add/edit/delete screens over the existing repo + `CustomEntityValidator` + `RegexSandbox`
  (ReDoS-safe isolate live preview). `customEntitiesProvider` (auto-dispose) lists scope.
- **Saved entities feed detection**: the editor's `detect()` composes Tier-1 recognizers +
  `CustomEntityRecognizer(savedDefs)` into the pipeline (was Tier-1 only) — define a pattern, it gets
  detected. Headless tests confirm (`TKT-\d+` → `TICKET` span).
- **Workspace FK**: `custom_entity_types.workspace_id` FKs `workspaces`, so the form (and tests)
  call `DocumentRepository.ensureDefaultWorkspace()` before saving. (Single-tenant V1 default — a
  proper unlock-time bootstrap can replace these ad-hoc calls when projects land.)
- Default-operator choices exclude FPE (same rationale as the editor).

## 2026-06-14 — V1 Phase 5: i18n scaffolding (closes Phase 5)

- `flutter_localizations` (sdk) + `intl ^0.20.2` + `gen_l10n` (`generate: true`, `l10n.yaml`).
- **Generated localizations are committed** (`output-dir: lib/l10n/gen`) so `analyze`/`flutter test`
  need no separate generation step; `synthetic-package` key dropped (deprecated/no-effect in 3.38).
- `MaterialApp.router` wired with `AppLocalizations.localizationsDelegates` + `supportedLocales` +
  `onGenerateTitle`. **Representative** strings localized (app title, Home tagline/subtitle) — this is
  *scaffolding*: the structure is ready and English-only for V1; remaining strings migrate
  incrementally (not churned now to avoid breaking text-based widget tests).
- Only `HomeScreen` consumes `AppLocalizations`, and it's only pumped via `DocuMinkApp` (which has the
  delegates) — other screen tests using a bare `MaterialApp` are unaffected.

## 2026-06-14 — V1 UI elevation L6: resilience & polish

Maintainer asked to keep polishing blind with confident, headless-safe refinements (and to record
the L1–L6 arc in `roadmap.md`). L6:

- **`AppErrorState`** (icon + message + Retry) replaces plain error text on the three async screens;
  Retry invalidates the relevant provider (`documentsListProvider` / `auditEntriesProvider` /
  `documentByIdProvider`) to refetch — a real resilience win, fully widget-testable.
- **Pull-to-refresh** (`RefreshIndicator`) on the vault browser + audit list.
- **Inline Detect progress** on the editor button (spinner + "Detecting…").
- **a11y**: semantic labels on `EntityChip` ("LABEL, n found") and `StatusBadge` ("Status: …");
  `SectionHeader` already `header: true`.
- The L1–L6 design-elevation sub-arc is now documented in `roadmap.md` under Phase 5; **i18n
  scaffolding remains to close Phase 5** (next).

## 2026-06-14 — V1 UI elevation L5: Settings & Audit + motion/a11y (closes the arc)

- Settings rows grouped into `_SettingsGroup` cards under `SectionHeader`s, centred under
  `maxContentWidth`. Audit entries get a per-event-type icon in a tinted avatar (success/fail tint).
- App-wide `pageTransitionsTheme` (Zoom on Android, Cupertino on iOS) for cohesive navigation motion.
- a11y: `SectionHeader` marked `Semantics(header: true)`; icon buttons already carry tooltips;
  buttons ≥48 dp via the L1 theme. Full TalkBack/dynamic-type/contrast review remains device-verified
  (VERIFICATION.md).
- The 5-PR design-elevation arc (L1–L5) is complete; all 261 tests stay green throughout.

## 2026-06-14 — V1 UI elevation L4: vault browser + document detail

- `StatusBadge` (colour-coded pill) + a tiny `formatTimestamp` (no `intl`) in `lib/core/`.
- Vault browser: document **cards** (type icon by `doc.type`, name, date, status), centred under
  `maxContentWidth`.
- Detail: header row (StatusBadge + type + date), monospace content card, and an `AnimatedSwitcher`
  reveal of original values. Revealed rows kept as `Text` (not `SelectableText`) so the existing
  `find.textContaining` reveal tests still match; the `revealed-values` key moved onto the animated
  child.

## 2026-06-14 — V1 UI elevation L3: editor

- `EntityChip` renders each detected type as a colour-coded pill (hue dot + label + count) via
  `AppColors.entityColor`; foreground tone-mapped per brightness for contrast.
- Redacted preview now uses `AppTypography.mono` on a tonal surface with a copy-to-clipboard action —
  reads like "output", and surrogates/redaction markers are legible.
- Existing editor tests still pass (`find.textContaining('EMAIL')` matches the chip's "EMAIL · n").

## 2026-06-14 — V1 UI elevation L2: shared UI kit + Home/Unlock

- Extracted reusable widgets — `AppEmptyState`, `SectionHeader`, richer `PrimaryActionCard` — and
  refactored vault-browser/audit empty-states + settings section headers onto them (consistency, less
  duplication). Section labels are **uppercased** (small accented caps) — tests updated accordingly.
- **Home**: brand lockup + tagline header, elevated cards, centred under `maxContentWidth` for large
  screens. AppBar title dropped (brand lives in the body) → home test asserts the `DocuMink`
  *semantics* label, not a Text.
- **Unlock**: brandmark replaces the generic lock icon.
- Visual result device-verified (VERIFICATION.md); structure widget-tested.

## 2026-06-14 — V1 UI elevation L1: design-system foundation

Maintainer-directed "world-class UX" pass; design direction confirmed via questions.

- **Ink Indigo** palette (primary `#4F46E5`, teal `#0D9488` secondary, slate neutrals), light + dark
  via `ColorScheme.fromSeed(...).copyWith(secondary: accent)`. Dark mode first-class.
- **Refined platform-font** type scale (no font assets → offline; privacy/offline-friendly) + a
  monospace style for redaction output. Custom font was offered and declined for reliability.
- **Centralized component themes** in `app_theme.dart` (`_themeFor(scheme)`) so every screen inherits
  the look with zero per-screen change — using the Flutter-3.38 `…ThemeData` names (`CardThemeData`,
  `DialogThemeData`, etc.).
- **Entity colour system** (`AppColors.entityColor`): 13 PII labels → ~8 semantic hues for chips;
  unknown/custom → slate. Contrast handled by the (L2) chip, so hues are mid-tone for both modes.
- **In-app vector brandmark** (`BrandMark`/`BrandLockup`, CustomPaint — a redaction-bar glyph); the
  adaptive launcher icon stays deferred (device/asset task).
- **Honest constraint:** pixels aren't rendered here — structure is widget-tested; aesthetics are
  device-verified via the Build APK artifact (visual-review items in VERIFICATION.md). Existing 250
  screen tests stay green (they assert text/keys, not pixels).

## 2026-06-14 — V1 Phase 5k: audit log viewer

- Read-only Settings → Audit log over the existing `AuditLogRepository.query`; `auditEntriesProvider`
  (auto-dispose, newest-first, limit 200). Shows event type / timestamp / success / biometric result
  — IDs + metadata only, **never PII** (invariant #7). CSV export already exists in the repo; an
  export button is a small later add. Enabled the previously-placeholder Settings row.

## 2026-06-14 — V1 Phase 5j: delete documents

- **Manual cascade in one transaction** (tokens → entities → document) since the schema FKs don't
  declare `ON DELETE CASCADE` (drift default RESTRICT). Audited as `document_deleted`.
- **`Navigator.maybePop`** (not go_router `context.pop`) after delete so the detail screen works both
  in the app and in plain widget tests; the vault list is invalidated to refresh.
- Confirm dialog before deleting (destructive action).

## 2026-06-14 — V1 Phase 5i: biometric-gated token reveal (HIGH-STAKES — fuller logging)

The reveal (decode) feature exposes plaintext PII after auth — the payoff of the reversible-token
system, and a privacy-sensitive surface. Decisions:

- **Deny-by-default `Authenticator` seam.** The default `authenticatorProvider` is
  `DenyingAuthenticator` (always false) so a reveal can **never** bypass auth if the real impl wasn't
  wired. Bootstrap overrides it with `LocalAuthAuthenticator` (`local_auth`); tests inject a fake.
  Any platform error (no enrollment, cancel, unavailable) is treated as **denial** — never reveal on
  an ambiguous result.
- **Every attempt is audited** (`document_reveal`, `success` + `biometricResult`), success or denial,
  before returning — privacy invariant #7. Audit metadata is counts only; **no plaintext** in the
  audit row, logs, or persisted state.
- **Plaintext is transient:** returned to the widget for display only, held in screen state, never
  written back to the DB or any store. Decryption uses the unlocked vault's `TokenCrypto` (AES-GCM
  with the surrogate as AAD — a relabelled token fails authentication).
- **`local_auth` (BSD-3) added**; the real biometric prompt is device-only → VERIFICATION.md. The
  decrypt-after-auth path is fully headless-tested via a fake authenticator + in-memory vault.

## 2026-06-14 — V1 Phase 5h: vault browser + document detail

- **Read providers** `documentsListProvider` (auto-dispose, refetches on open) and
  `documentByIdProvider` (family) over the vault-backed `DocumentRepository`.
- **Detail is read-only** for now: shows the stored `redactedText`. **Revealing** reversible tokens
  is biometric-gated and native — deferred (tracked in VERIFICATION.md); keeping it out here avoids
  putting any decrypt path in the browser before the biometric gate exists.
- Added a `My documents` Home action + `/vault` and `/document/:id` routes.

## 2026-06-14 — V1 Phase 5g: persist anonymized documents

- **`AnonymizationOutcome.tokensBySpan`** added (non-breaking) so persistence can link each `tokens`
  row to its owning `entities` row — the flat `tokens` list had no span association. Small, contained
  Phase-3 enhancement.
- **Save persists the exact previewed outcome** (the editor retains `_lastOutcome`), so Token-Random's
  random surrogates in the preview match the stored `tokens.token_value` and remain reversible.
- **Single default workspace (`ws_default`) for V1.** The vault is single-tenant until the
  projects/multi-workspace UI lands; `DocumentRepository.ensureDefaultWorkspace()` creates it lazily
  (idempotent). Avoids touching the high-stakes `VaultService.initialize` path. Revisit when projects
  UI arrives.
- **Whole save is one transaction** (document + entities + tokens + `document_saved` audit), so a
  partial failure leaves no orphan rows. Audit metadata carries counts only — **no PII** (invariant #7).
- **`redactedText` stored in `documents.metadata_json`** for text docs (it's de-identified output, not
  PII); file artifacts will use `redacted_artifact_path` in the export phase.
- Simple injectable id generator (`lib/data/id_generator.dart`); full ULID still deferred (schema only
  needs a unique TEXT PK).

## 2026-06-14 — V1 Phase 5f: reversible operators in the editor

- **Token-Random + Encrypt added; FPE held back.** FF1 requires a minimum numeric domain and throws
  on arbitrary text, so offering it per-label generically would crash on non-numeric entities. FPE
  belongs with per-type applicability (numeric labels only) — deferred to a later chunk. Token-Random
  and Encrypt handle arbitrary strings safely.
- **Preview-only; tokens not persisted.** Computing the preview mints `TokenRecord`s (random
  surrogate + ciphertext) but does **not** write them to the `tokens` table — persistence (required
  for later decode/reversal) happens at save/export, a later phase. Documented so reviewers know the
  preview's surrogates aren't yet reversible-from-storage.
- **Editor is always behind the unlock gate** (Phase 5e), so routing the preview through the
  vault-backed `AnonymizationService` is safe; a failed anonymize keeps the prior preview and surfaces
  a generic error rather than crashing.
- **Picker → wrapping `ChoiceChip`s** (was `SegmentedButton`) because five options overflow a row;
  chips wrap and stay tappable/accessible.
- **Shared `test/support/test_vault.dart`** provides an unlocked in-memory vault (Phase-1c seam:
  fake `SecureKeyStore` + plain `NativeDatabase`) so the editor's vault-backed path is fully
  headless-tested.

## 2026-06-14 — V1 Phase 5e: vault unlock UX (HIGH-STAKES — fuller logging)

The passphrase gate is the UI over the Phase-1 `VaultService`; no new crypto, no change to key
handling. Security-relevant decisions:

- **No secret material in UI state.** The screen only holds the passphrase in `TextEditingController`s
  (obscured) and passes them straight to `VaultService.initialize/unlock`; it reads only
  `VaultState`/`appUnlockedProvider` (key-free, per the existing `VaultState` contract). Keys/DEK never
  enter widget state. On a wrong passphrase the catch shows a generic "Incorrect passphrase." — no
  detail about why (no oracle).
- **Gate via a derived `appUnlockedProvider`** (`bool` from `vaultServiceProvider.isUnlocked`) rather
  than reading vault internals in the router. Lets widget tests bypass the gate with a plain
  `overrideWithValue` without constructing the vault stack, and keeps the router free of key material.
- **Router redirect** sends locked → `/unlock` and unlocked away from `/unlock`; refreshed via a
  `ValueNotifier` bumped on `appUnlockedProvider` changes (`ref.listen` in the router provider).
- **Create-vault UX guard:** min passphrase length (8) + confirm match are *UX* checks only; the real
  strength is Argon2id (unchanged). Documented as non-authoritative.
- **Auto-lock** keeps the existing 120 s default in `VaultService`; the timer is exercised in unit
  tests with a fake. The biometric fast-path (ADR-005/020) stays deferred.
- **Headless testing of the real path:** widget tests drive an actual `VaultService` with the
  in-memory `SecureKeyStore` fake + plain `NativeDatabase` executor (the Phase-1c test seam), so
  create→unlock and wrong-passphrase rejection run for real without the SQLCipher native build. The
  encrypted-build open stays the gated `vault_service_test` integration case (VERIFICATION.md).

## 2026-06-14 — V1 Phase 5d: settings persistence

- **`SettingsStore` interface + in-memory default + `shared_preferences` impl at bootstrap** — the
  same injectable-seam pattern as `SecureKeyStore`/`DeviceSignalCollector`, so headless tests run
  without platform channels and the persistent store is device-verified (VERIFICATION.md).
- **Non-sensitive prefs only** in `shared_preferences` (theme mode). Privacy invariant #4: **no PII**
  here — sensitive state stays in the encrypted vault. Theme mode is not PII.
- `shared_preferences` (BSD-3, allowlisted) added; replaces the deferred-deps comment in pubspec.
- `themeModeProvider.build()` reads the persisted value synchronously (the store is loaded at
  bootstrap before `runApp`), so theme applies pre-first-frame without a flash.

## 2026-06-14 — V1 Phase 5b: paste-and-redact editor

- **Irreversible operators only** (Redact / Mask / Replace) in this chunk: they run through the
  pure synchronous `Anonymizer` with **no unlocked vault**, so the whole flow is headless-testable.
  Reversible operators (Token-Random / FPE / Encrypt) need the vault-unlock UX + crypto and land in
  a later chunk (`editorOperators` enforces this; all are `!isReversible`).
- **Operator selection per label (entity type), not per span.** Matches the policy engine's
  label→operator model (`AnonymizationPolicy.operatorFor(label)`) and keeps the `Anonymizer`
  unmodified. Per-span granularity is a possible later refinement.
- **Default = redact** for every detected label (privacy-safe default), overridable in the UI.
- Editor state is a `Notifier<PasteEditorState>` that stores the computed `previewText`, so the
  screen just renders state and tests assert on it directly.

## 2026-06-14 — V1 Phase 5a: UI app-shell foundation

Spec doesn't dictate UI implementation details; recommended choices:

- **Runtime theming** via `themeModeProvider` (`Notifier<ThemeMode>`, default `system`, AppBar
  quick-toggle cycles system→light→dark). **In-memory for now**; persistence lands with the Settings
  screen (Phase 5e) — no need to introduce a settings store yet.
- **Router as a provider** (`routerProvider` + `createRouter()` factory) instead of a single global
  `GoRouter`, so widget tests get an isolated router (no navigation state leaking between tests).
  `Routes` centralizes path constants.
- **Placeholder destinations** for routes whose full screens land in later chunks (Phase 4 native
  input, 5b editor, 5e settings, etc.) — keeps navigation real and widget-testable now without
  faking. Each placeholder names the phase that will replace it.
- **`context.push`** (not `go`) for Home actions so there's a back stack.
- Widget tests run headless; **visual correctness, FLAG_SECURE, and a11y remain device-verified**
  (VERIFICATION.md).

## 2026-06-14 — Enablement: testable APK, Play Store signing, verification/setup governance

Maintainer-directed (the specs don't cover build/release plumbing). Decisions:

- **Sideloadable test APK via a separate manual workflow.** New
  `.github/workflows/build-apk.yml` is **`workflow_dispatch`-only** so it doesn't burn Action
  minutes on every PR (maintainer's call). It uploads the debug-signed `app-prod-release.apk`
  as an artifact. `ci.yml`'s `apk-size-check` is untouched (stays the per-PR size gate, no upload).
- **Play App Signing + upload key** for Play Store (recommended path). `build.gradle.kts` gains a
  `release` signingConfig that reads `android/key.properties` (local) or `ANDROID_*` env/secrets
  (CI), **falling back to debug signing when absent** so secret-less builds (apk-size-check, fork
  PRs) still compile. New `release.yml` builds a signed AAB on `v*` tags. The agent **never creates
  or commits keystores/passwords** — the maintainer generates and holds them on their Windows box;
  `SETUP.md` is the runbook (exact PowerShell). ⚠ review (security-adjacent: signing/secrets) — no
  invariant weakened; no secret material in the repo (gitignored).
- **`VERIFICATION.md` introduced** as the running on-device/native verification checklist, seeded
  from the deferred-items audit; **`SETUP.md`** as the maintainer runbook. `CLAUDE.md` gains a
  standing rule to append to VERIFICATION.md whenever a phase defers a device check and to keep
  SETUP.md current. Clarifies that widget tests run headless (UI phases partially gated here).
- **Phase 4 ↔ 5 execution-order swap.** Build UI/UX scaffolding (Phase 5) before native input
  handlers (Phase 4): the UI is widget-testable headless and is the scaffold inputs plug into;
  Phase 4 is mostly native. **Phase numbers kept stable** (avoid breaking "Phase 5 bootstrap"
  cross-references); documented as a note in `roadmap.md`.

---

## 2026-06-13 — Governance: self-merge autonomous loop (Option C)

- **Context:** Maintainer instruction to run the roadmap end-to-end: drive CI green, self-merge
  on green, plan-in-chat + self-approve, execute, loop — and to pick the recommended option for
  undetermined decisions (logging them here) rather than stopping.
- **Options:** (A) keep Option-B human-merge + stop-at-phase-boundary; (B) adopt the continuous
  self-merge loop with a decisions log. 
- **Choice:** **B.** Updated `CLAUDE.md` autonomy contract to Option C; created this log.
- **Rationale:** Explicit standing maintainer instruction. Deviation-protocol still binds for
  spec conflicts / security-invariant risks (resolve-and-log-prominently instead of block).

## 2026-06-14 — V1: Project manifest + tool-permission enforcement (§5/§6)

- **Deny-by-default.** `ProjectPermissions.level()` returns `denied` for absent/unknown keys, and
  `ToolPermissionRegistry.evaluate()` denies unknown tools — the safe default for the project-isolation
  invariant. Permission values parse as bool (`granted`/`denied`) or `requires_biometric`.
- **Single source of truth for tool→permission** (the §5 table) in `ToolPermissionRegistry.tools`;
  biometric is forced when either the tool is flagged biometric (e.g. `decode_token`) **or** the
  permission level is `requires_biometric` (e.g. `decode`). This is the enforcement point the Mink
  ToolRegistry dispatch (a later, LLM-runtime phase) will call before executing any tool.
- **Manifest custom-entity seeds kept raw** (`List<Map>`) rather than parsed into
  `CustomEntityDefinition`, because manifests use validators like `luhn_npi` outside the current
  `CustomValidator` set and ids/workspace are assigned at project-creation time. `default_policy`
  bridges to `AnonymizationPolicy` for direct use.
- Pure Dart; the Project-creation flow + Settings UI are UI-phase tasks.

## 2026-06-14 — V1 P8b: CRDT conflict resolution (§9.4)

- **Auto-resolution primitives** match the spec: `lwwWinner` (LWW on scalars, newer `updatedAt` wins,
  ties broken by lexicographically-greater `deviceId` so all replicas converge regardless of merge
  order) and `setUnion` (collection merge). cr-sqlite applies column LWW at runtime; these model the
  same semantics for app-level merges/tests.
- **Hard-conflict detection** is the genuine app-level value: `SyncConflictDetector` flags the §9.4
  case cr-sqlite would silently resolve — two devices independently creating the same custom-entity
  *identity* (`workspace_id, project_id, label`) with diverging definition (regex/validator/operator).
  Same record id ⇒ CRDT handles; identical definition ⇒ benign duplicate; divergent ⇒ surfaced to
  Settings → Sync Conflicts. Pure Dart, fully tested; the conflict-resolution UI is a UI-phase task.

## 2026-06-14 — V1 P8a: sync delta envelope crypto (HIGH-STAKES — fuller logging)

- **Scope.** Only the encryption envelope for CRDT deltas — the headless-testable, security-relevant
  slice of Phase 8. The native transport (cr-sqlite delta generation, BYOC Google Drive, mDNS +
  WebSocket/TLS) is deferred to a device session.
- **Faithful to spec, no new crypto.** §9.1/§9.2 mandate "never sync plaintext" + "AES-GCM-encrypted
  CRDT deltas" under MK-derived transport keys. `SyncEnvelope` uses **AES-256-GCM** (the same blessed
  primitive as the vault) under the existing **`syncKey`** (KeyService HKDF `documink:sync:v1`,
  previously reserved). Reuses the `cryptography` package — no new dependency, no invented scheme.
- **Decisions the spec didn't pin (logged):** (1) wire format `version(1)‖nonce(12)‖ct‖mac(16)` with a
  version byte for forward-compat; (2) **AAD binds `(deltaId, deviceId)`** (0x00-delimited, injective)
  so a delta blob can't be relabelled to another `<ulid>` filename, replayed, or re-attributed to a
  different origin device without failing authentication. This strengthens the no-plaintext-sync
  invariant; it does not weaken any existing one, so proceeding under the autonomy contract (logged
  here + called out in the PR).
- **Payload opacity.** The delta bytes are treated as opaque (cr-sqlite's CBOR delta at runtime); the
  envelope neither parses nor depends on their structure.

## 2026-06-14 — V1 P15a: audit log repository + CSV export

- **Append-only** `record(...)` (plain `insert`, never update/delete) over the existing `audit_log`
  table; `AuditEventType` constants cover the roadmap §15 / schema event set.
- **No raw PII in audit rows** (privacy-invariants #7): the repository stores IDs/token-refs/metadata
  as given; the *caller* keeps plaintext out of `metadata`. Documented on `AuditEntry` (kept the
  contract simple rather than re-scanning every audit write).
- **Query**: newest-first, filter by event type(s) + `[since, until)` time range, `limit`/`offset`
  pagination — matches the Settings → Audit Log UI needs (UI itself is a UI-phase task).
- **CSV export** is a pure static function with RFC-4180 quoting (fields with comma/quote/newline are
  quoted, internal quotes doubled) — testable headless; ships in V1 (Pro-gate flag is V1.1).

## 2026-06-14 — V1 P12c: deterministic memory router (completes Phase 12 active-V1)

- **Deterministic dispatch (no LLM)** per memory.md §4.1: a `switch` over tool names
  (`remember`/`recall_core`/`recall_episodic`/`forget`) → `MemoryRepository`. Mink emits the tool
  call; routing is plain code.
- **Rejected writes surface as failures, not exceptions.** A `MemoryPiiLeakError` from the guard is
  caught and returned as a failed `MemoryToolResult` so Mink can react ("I can't store that as-is").
- **Injectable id/clock.** The router takes an id generator + clock (defaults: time+random id,
  `DateTime.now`) so tests are deterministic. No ULID util existed; a real one can replace the default
  later without API change.
- **Scope param.** `remember` honors `scope: 'global'|'project'` to attach/omit the projectId.

## 2026-06-14 — V1 P12b: MemoryRepository (Core + Episodic, guarded)

- **Active-V1 types only.** Implemented Core + Episodic (memory.md §2.1/§2.2); Knowledge Vault is the
  existing `tokens` table; Semantic/Procedural/Resource are schema-only until V1.2 activation (§2.4-2.6).
- **Every write passes `MemoryWriteGuard.assertNoPlaintext`** before insert (Core scans the `value`;
  Episodic scans `{summary, details}`), so 12a's invariant is enforced at the persistence boundary.
- **Scope-aware recall** (current Project + workspace globals) mirrors the §6.7 isolation pattern used
  for custom entities; Episodic recall adds `since`/`episodeType`/`limit`, newest-first (§2.2).
- Values stored as JSON (`value_json`/`details_json`/`token_refs_json`); domain entries decode them.
  `forget{Core,Episodic}` for deletion. Router (tool-call dispatch) is 12c.

## 2026-06-14 — V1 P12a: Mink memory PII-safe write guard (HIGH-STAKES — fuller logging)

- **The invariant.** memory.md §3 requires raw PII/PHI plaintext to *never* enter memory tables.
  12a implements the §3.3 write-path enforcement: `MemoryWriteGuard.assertNoPlaintext` →
  `MemoryPiiScanner` runs the **shared detection pipeline** over content and rejects any detected PII
  that isn't already a token reference (`MemoryPiiLeakError` with structured violations).
- **Token-ref accounting.** Form A (`{"type":"token_ref",…}` maps) is skipped wholesale; Form B
  (`<<tok_…>>` inline markers) is stripped before scanning. Form C (canonical fingerprint) is a BLOB,
  carries no plaintext, so inherently safe. The scanner walks arbitrary JSON (Map/List/String) and
  reports violations with a JSON-path location.
- **Detection coverage caveat.** The guard is exactly as strong as the registered recognizers. With
  only Tier 1 active (headless), structured PII (SSN/email/phone/CC/MRN/…) is caught; PERSON/ADDRESS
  rely on Tier 2/3 (gated). Once Tier 2 (ML Kit) / Tier 3 (GLiNER) are wired at app bootstrap the same
  guard covers names/addresses with no code change. Logged so this dependency is explicit.
- **Scope.** 12a is the security choke point only. `MemoryRepository` (Core + Episodic active-V1
  tables) and the deterministic recall router are 12b; Semantic/Procedural/Resource are V1.2-activation
  per memory.md §2.

## 2026-06-14 — V1 P6b: ReDoS-safe regex preview sandbox (completes Phase 6)

- **Isolate + kill-on-timeout.** Dart's `RegExp` has no interruptible timeout, so the live preview
  runs the untrusted pattern in a **disposable isolate** (`Isolate.spawn`) and the result future is
  raced against a deadline; on `TimeoutException` the isolate is `kill`ed immediately. This is the
  only robust way to neutralize catastrophic backtracking (ReDoS) without hanging the UI thread.
- **Defense in depth:** the sample is truncated to `maxSampleLength` (default 10k) before matching,
  bounding work regardless of the timeout.
- Result is a typed `RegexPreviewResult` (ok+matches / error+message / timedOut). Tested incl. an
  actual exponential pattern `(a+)+$` that reliably trips the timeout path.

## 2026-06-14 — V1 P6a: custom entity types core

- **Naming.** drift already generates a `CustomEntityType` data class for the table; the domain model
  is `CustomEntityDefinition` to avoid collision (validator/operator as enums, examples as a list;
  the repository maps to/from the string/JSON drift row).
- **Validators.** roadmap §6 specifies `luhn` | `none`; implemented both (blueprint §4 also mentions
  `luhn_npi` — deferred until a concrete NPI rule is needed; `CustomValidator` is extensible).
- **Form validation** also checks that provided **examples match the pattern and pass the validator**
  (catches author mistakes early) — beyond the bare roadmap list.
- **Recognizer priority** default 5 (above raw Tier 1 structured but below contextual tiers); tunable.
  Zero-width matches are skipped (would violate the `DetectedSpan` end>start invariant).
- **ReDoS safety deferred to 6b.** 6a compiles patterns vetted by the validator; the *live preview*
  sandbox with isolate timeout (untrusted pattern × adversarial input) is its own chunk. Pipeline
  execution of stored patterns runs in the detection isolate.

## 2026-06-14 — V1 P9c: profiler persistence + orchestration (completes Phase 9)

- **Persistence shape (decision).** §4.7 lists several `llm_*` `vault_meta` fields. Stored as a
  **single JSON document** under `llm:profiler_state` (one atomic row) rather than one row per field —
  simpler, atomic updates, no partial-write states. The JSON keys keep the spec's `llm_*` names.
- **Native collection deferred.** `DeviceSignalCollector` is an interface; the Android
  (ActivityManager/StatFs/…) and Windows (GlobalMemoryStatusEx/DXGI/…) adapters are platform code
  wired at Phase-5 bootstrap (same pattern as the ML Kit Tier 2 adapter). `deviceSignalCollectorProvider`
  throws until overridden, so the pure core stays headless-testable (fake collector in tests).
- **`ProfilerService`** takes the **already-verified** manifest (9b) as a parameter — it never parses
  raw manifest bytes itself; selection + persistence only.
- **User preference ±1 tier shift** (desktop onboarding, §4.7) is **persisted** here but applied in the
  onboarding UI (Phase 5); 9c keeps to selection + persistence.

## 2026-06-14 — V1 P9b: Ed25519-signed manifest verification (HIGH-STAKES — fuller logging)

- **Signing scheme (decision).** The blueprint sketch shows a `signature` field *inside* the manifest
  JSON, which would require canonical JSON re-serialization to verify (fragile). Instead the signed
  artifact (`manifest.signed.json`) embeds the manifest **body as an exact string** and the Ed25519
  signature covers that string's UTF-8 bytes. Verification is byte-exact and serialization-independent.
  Logged as a deviation from the §4.7 sketch (the security property is identical/stronger).
- **Pinned public key.** `ManifestVerifier` verifies against a **pinned** key (constant in code),
  ignoring any key embedded in the file — otherwise an attacker could swap both. On any failure
  (tampered body/signature, wrong key, bad alg, unparseable) it **throws and never returns an
  unverified manifest** (§4.7/§6.4: "never falls back to unsigned"). Tests cover all five rejection
  paths incl. a body forged under a different key.
- **Dev/review key.** The committed key is a **development** Ed25519 key (deterministic from a fixed
  seed in `tool/scripts/sign_manifest.dart`, clearly marked DEV-ONLY). The production private key is
  held in external secure key management and never committed; the pinned public key is swapped at
  release (key rotation = app update, models.md §5). The dev private key is NOT committed.
- **Tier 3 unblocked (ADR-022).** The manifest carries `detection_models` (GLiNER PII: bundled
  `tier3_baseline_bundled` + `tier3_upgrade` variants with `min_score` gates) alongside the Tier 4
  `tiers`. This is the data layer the deferred Tier 3 hybrid delivery needs.
- **Dev placeholder SHA-256.** Manifest `sha256` fields are zero placeholders (no multi-GB model
  files downloaded here); CI's `verify-model-hashes` checks `tool/model_hashes.json` (bundled
  models), not this manifest, so placeholders don't break CI. `ModelHashVerifier` is tested against
  real computed hashes. Real hashes are filled when models are actually hosted (models.md §5 step 2).

## 2026-06-13 — V1 P9a: Device Capability Profiler core (HIGH-STAKES phase — fuller logging)

- **Sequencing (user-approved).** With Phase 3 done, the strict next phase (4: input handlers) is
  native camera/OCR/PDF and untestable in this headless sandbox. Maintainer chose "headless-testable
  cores first," so Phase 9's pure-Dart core runs now — it also **unblocks the deferred Tier 3 model
  delivery** (ADR-022). Native/UI phases (4–8) move to a device session.
- **Phase 9 chunking.** 9a = pure-Dart score + selection core (this PR); 9b = Ed25519-signed manifest
  loading + SHA-256 verification (security-critical; unblocks Tier 3); 9c = `vault_meta` persistence
  + providers + native signal-collector interface (gated).
- **Unit system (decision).** Capabilities stored canonically in **bytes**; all conversions use
  **decimal** units (1 GB = 1e9, 1 MB = 1e6) so the §4.7 score formula and the manifest's
  `size_bytes` / `min_ram_mb` share one consistent system. Avoids binary/decimal mix-ups in the
  storage-headroom and RAM gates. (Spec is unit-loose; logged for review.)
- **selectTier** implements §4.7 verbatim: score ≥ `min_score`, hard `requires` gate, and
  `freeStorageBytes ≥ largestVariantBytes × 1.2` (20% headroom); highest non-opt-in tier wins,
  always defaults to the **Balanced** variant, opt-in tiers surfaced separately. Device-agnostic with
  **no upper ceiling** (verified by a synthetic far-future-device fixture).
- **FloorReason** (added beyond the spec's `floorReason` String): a typed diagnosis
  (insufficientScore / insufficientRam / insufficientStorage / noQualifyingTier) against the
  easiest-to-qualify auto tier, to drive the §4.7 floor UX copy. No security surface.
- **No manifest parsing in 9a.** Selection runs on an in-memory `TierCatalog` (built programmatically
  in tests). JSON parsing is deferred to 9b so the app **never acts on an unverified manifest** —
  parsing and Ed25519 verification land together.

## 2026-06-13 — V1 P3c: FF1 format-preserving encryption

- **FF1 only** (NIST SP 800-38G), hand-rolled on pointycastle (MIT) AES per §2.5/§7.1; **FF3/FF3-1
  forbidden** (NIST withdrawal, §15). Implementation **verified against the NIST FF1 sample
  vectors** (AES-128, radix 10, with/without tweak) — committed as KATs. The radix>10 path is
  covered by a round-trip test only (couldn't authoritatively confirm the radix-36 sample's
  tweak/output from memory; radix 10 is what DocuMink uses for digit FPE).
- **Key = vault DEK** (AES-256) — avoids expanding the 1b key hierarchy with a dedicated FPE
  subkey; FF1 with AES-256 is valid. **Tweak = SHA-256(entity_type ‖ 0x00 ‖ workspace_id)** (the
  0x00 separator makes the encoding injective) — realizes §7.1's "entity_type + workspace_id hash".
- **Card keep-last-4**: CREDIT_CARD FPE leaves the last 4 digits clear (§7.1); separators preserved.
  FPE is **stateless + deterministic** (no token row); reversible via `fpeReverse` with the same
  (label, workspaceId, keepClear).
- `AnonymizationService.anonymize` gained an optional `workspaceId` (default '') for the FPE tweak;
  the pipeline supplies the real workspace id. crypto (BSD-3) added for sync SHA-256.

## 2026-06-13 — V1 P3b: reversible operators (Token-Random + inline Encrypt)

- **Async-vs-sync seam.** 3a's `Anonymizer.apply` is sync; reversible ops need async crypto/DB. Kept
  3a's API and added `AnonymizationService` that **precomputes** surrogates (async) into a map, then
  calls `apply` with a sync resolver. No change to the merged 3a.
- **Token-Random** mints `<LABEL_6base62>` (CSPRNG) and encrypts plaintext with **AAD = surrogate**
  via `TokenCrypto`; returns a `TokenRecord` (surrogate, ciphertext, fingerprint) for the pipeline
  to persist as a `tokens` row. **Intra-document dedup** (same plaintext → same surrogate via
  fingerprint match) is the pipeline's job at persistence; this layer mints fresh per call.
- **Encrypt (inline, stateless).** `<ENC:base64(nonce‖ct‖mac)>`, AAD = fixed domain string
  `documink:inline-encrypt:v1`, **no vault row** (§7.1 "stateless reversal"). Reversible whenever the
  vault (DEK) is unlocked.
- **FPE deferred to 3c:** a policy mapping a label to `fpe` throws `UnsupportedError` until FF1 lands
  (no silent mishandling).

## 2026-06-13 — V1 P3a: anonymizer framework + operator output formats

- **Phase 3 chunking.** 3a = operator framework + policy engine + irreversible ops
  (Redact/Mask/Replace); 3b = vault-backed reversible ops (Token-Random + AES-GCM Encrypt, on
  1c's TokenCrypto); 3c = hand-rolled FF1 FPE + NIST SP 800-38G vectors (FF1 only; FF3 forbidden
  per §15/§7.1). Splits the security-sensitive FF1 crypto into its own reviewable PR.
- **Operator output formats (not precisely spec'd for V1 — chosen, refinable):** redact →
  `[REDACTED]`; mask → `•`×len (length-preserving, full mask by default); replace → `<LABEL>`
  (entity-type tag). Constants on `Anonymizer`.
- **Policy as YAML asset** (`assets/policy/default_policy.yaml`, matches §4.6) via the `yaml`
  package (BSD-3); parser takes a string so it's headless-testable, production loads via
  `rootBundle`. `DEFAULT:` key sets the fallback (redact). Overrides layer via `policy.override(...)`.
- **Reversible ops delegated.** `Anonymizer.apply` routes Token-Random/FPE/Encrypt to an injected
  `ReversibleSurrogate`; absent ⇒ `StateError` (3a has no vault). Keeps 3a pure-Dart + testable.

## 2026-06-13 — V1 P2 Tier 3: hybrid detection-model delivery + sequencing (user-confirmed)

Research (knowledgator GLiNER-PII family, Apache-2.0): edge F1 75.5% (~100 MB INT8), small 76.8%,
base 81.0% (UINT8 197 MB / FP16 330 MB), large 83.3%. The model is too big to bundle a high-accuracy
variant within the PRD's ≤250 MB install ceiling (Phase 12 also bundles ~80 MB MiniLM), and 8-bit
GLiNER quantization has a documented accuracy drop.

- **Delivery strategy.** Options: (A) tiered download + degradation; (B) bundle one small INT8;
  (C) hybrid: bundle smallest + optional downloaded base/large upgrade. **Chose C (maintainer).**
  Offline baseline + per-device accuracy; reuses the Phase 9 signed-manifest/download infra.
  Graduated to **ADR-022**; blueprint §4.3, roadmap Phase 2, models.md §3.4 updated.
- **Sequencing.** The downloaded-upgrade path depends on Phase 9 (profiler + manifest + download),
  so **Phase 3 (Anonymizer operators) is done next** and full Tier 3 lands with/after Phase 9.
  **Chose maintainer-confirmed.**
- **Follow-up flagged:** re-evaluate whether the clinical PHI model (`obi/deid_bert_i2b2`, ~110 MB,
  ADR-004) should also be download-on-demand vs bundled (bundling both NER models pressures 250 MB).

## 2026-06-13 — V1 P2e: minSdk 24 → 26 (spec conflict, user-confirmed) ⚠ review

- **Conflict.** blueprint §11 pinned **minSdk 24 (Android 7.0)**, but `com.google.mlkit:
  entity-extraction:16.0.0-beta6` (Tier 2) requires **minSdk 26**; the manifest merger failed the
  release build (caught by `apk-size-check`). Surfaced via deviation-protocol.
- **Options.** (A) raise minSdk to 26; (B) keep 24 + force-merge ML Kit's manifest
  (`tools:overrideLibrary`) and gate Tier 2 to API ≥26 at runtime; (C) drop ML Kit (Tier 2).
- **Choice: A — raise minSdk to 26 (maintainer-confirmed).** Android 8.0 (2017) covers effectively
  all active devices in 2026; (B) adds an override + runtime guard and disables Tier 2 on 24–25;
  (C) loses Tier 2. `android/app/build.gradle.kts` set `minSdk = 26`; blueprint §11 corrected.

## 2026-06-13 — V1 P2e: Tier 2 ML Kit integration

- **Plugin-agnostic seam.** `MlKitEntityRecognizer` consumes an injectable
  `TextAnnotator` over a local `TextAnnotation` type (not the plugin's `EntityAnnotation`), so the
  type→label mapping is fully unit-tested without platform channels. The plugin-coupled adapter
  (`mlkit_annotator.dart`) is device-only and not exercised in headless CI (like the gated
  SQLCipher test).
- **Not added to the default `piiRecognizersProvider`.** Tier 2/3 need native runtimes / a
  downloaded model, so they are composed into the pipeline at **Phase 5 bootstrap** on capable
  devices; the default provider stays pure-Dart and headless-testable. ML Kit model
  download/lifecycle is a bootstrap concern.
- **Type mapping.** email→EMAIL, phone→PHONE, iban→IBAN, paymentCard→CREDIT_CARD, url→URL,
  address→LOCATION, dateTime→DATE; isbn/money/flightNumber/trackingNumber/unknown dropped (not PII).
  Tier 2 priority (20) > Tier 1 (10) so context-aware detections win overlap ties.

## 2026-06-13 — V1 P2d: phone recognizer

- **Package.** `phone_numbers_parser` 9.0.23 (MIT, pure Dart — the maintained libphonenumber port).
  Its built-in text matcher (`TextParser.findPotentialPhoneNumbers`) is not exported and the public
  `findPotentialPhoneNumbers` drops offsets, so we use **our own candidate regex** (to keep span
  offsets) + the library's `PhoneNumber.parse(...).isValid()` for true pattern/length validation.
- **Default region `IsoCode.US`** for national-format numbers without a `+`. `+CC` numbers validate
  internationally regardless. This is a V1 English/US-leaning default; broader locale handling can
  follow in V3 multilingual. Verified: real US/GB numbers validate; SSN/ISO-date look-alikes are
  rejected by `isValid()`.

## 2026-06-13 — V1 P2c: heuristic Tier 1 recognizers; phone split to 2d

- **Keyword-anchoring for MRN & Passport.** Their formats overlap heavily with ordinary
  numbers/alphanumerics, so they only match when preceded by an `MRN`/`passport` keyword (via
  lookbehind, so the span is the identifier, not the label). Passport additionally requires ≥1
  digit (rejects letter-only words like "passport details"). Favors precision; un-prefixed cases
  are left to Tier 3 (GLiNER) context detection.
- **Date scored 0.8** and labelled generically `DATE` (DOB disambiguation needs context → Tier 3/4);
  ambiguous DD/MM vs MM/DD both accepted.
- **Phone deferred to 2d.** Robust phone detection in free text needs a libphonenumber port +
  candidate matcher (a dependency + nontrivial logic), so it gets its own PR rather than riding
  with the pure-regex heuristics here.

## 2026-06-13 — V1 P2b: split Tier 1 recognizers into two PRs

- **Chunking.** The original plan put all of §4.2's Tier 1 recognizers in one PR. Split into
  **2b** (structured / checksum-verifiable: Email, URL, IP, SSN, CreditCard-Luhn, IBAN-mod97 —
  deterministic, no new deps) and **2c** (heuristic / locale: Phone via libphonenumber, Date,
  MRN, Passport — false-positive-prone, locale-specific, adds a dep). Rationale: keeps each PR
  tight and reviewable, and isolates the fuzzier heuristics + the phone dependency from the
  high-confidence checksummed detectors. Downstream sub-PR numbering shifts (Tier 2 ML Kit = 2d,
  Tier 3 GLiNER = 2e).
- **Bare 9-digit SSNs not matched.** Only `-`/space-separated SSNs are detected, to avoid false
  positives against arbitrary 9-digit numbers; SSA structural validity is enforced.

## 2026-06-13 — V1 P2a: detection-core foundations

- **Phase 2 chunking.** Detection (Tiers 1–3) ships as sub-PRs: **2a** pure-Dart core
  (recognizer abstraction + normalize + overlap resolver + pipeline), **2b** Tier 1 regex/checksum
  recognizers, **2c** Tier 2 ML Kit, **2d** Tier 3 GLiNER ONNX. Native/asset-heavy tiers (2c/2d)
  are isolated so the pure-Dart core stays fully unit-testable and CI-light.
- **NFC normalization package.** Options: (A) `unorm_dart` (MIT, pure Dart `nfc()`); (B) implement
  NFC by hand; (C) defer NFC. **Chose A** — §4.1 mandates NFC and hand-rolling Unicode composition
  is error-prone; `unorm_dart` is MIT (license-scan passes) and pure Dart (no native dep).
- **Span offsets index into normalized text, not the original.** Normalization can change length
  (NFC, zero-width strip, line-join), so detector offsets are relative to the normalized string;
  mapping back to original-input coordinates (for rendering on the untouched source) is a
  Phase 4/5 concern and is documented on `DetectedSpan`/`TextNormalizer`.
- **Line-join scope.** Only hyphenated line breaks (`-\n`) are rejoined; other newlines are kept so
  paragraph structure (and unrelated adjacent lines) is preserved.

## 2026-06-13 — V1 P1d: BIP-39 recovery codec scope

- **BIP-39 path.** Options: (A) entropy path (`entropyToMnemonic`/`mnemonicToEntropy`) — exact MK
  round-trip; (B) PBKDF2 seed path (`mnemonicToSeed`) — one-way, cannot reproduce the MK. **Chose
  A** (mandatory for recovery). Graduated to **ADR-021**; §8.4 corrected.
- **Recover→reset-passphrase orchestration.** Options: (A) implement now in `RecoveryService`;
  (B) ship only the codec + validation now, defer the orchestration (open vault with restored MK,
  re-key to a new passphrase) to Phase 5 onboarding/UI. **Chose B** — keeps `RecoveryService`
  storage-free and the high-stakes re-key flow with the UI that drives it.
- **Package.** `bip39` 1.0.6 (BSD-3-Clause, allow-listed; license-scan passes).

## 2026-06-13 — V1 P1c: VaultService scope & wiring choices

Decisions made autonomously (recommended options), specs not fully determining them:

- **Vault file path injection.** Options: (A) inject via a `vaultFileProvider` that throws until
  overridden (prod wiring + `path_provider` deferred to Phase 5; temp file in tests); (B) add
  `path_provider` now and resolve the app-support dir. **Chose A** — there is no app bootstrap/UI
  yet (Phase 5), and §2.5 says packages enter when used; avoids a premature dependency and keeps
  `VaultService` unit-testable.
- **`appDatabaseProvider` source.** Options: (A) leave it throwing (1a placeholder); (B) derive it
  from `vaultServiceProvider` so it yields the unlocked DB and throws while locked. **Chose B** —
  fulfils the 1a TODO and gives a single source of truth for the live DB.
- **Auto-lock default duration.** PRD §4.6 specifies a 60–300 s range but no default. **Chose
  120 s**, injectable via the constructor (UI will make it user-configurable in Phase 5).
- **Token DB persistence depth.** Options: (A) ship only pure `TokenCrypto` now, defer all DB
  CRUD to the detection/redaction pipeline; (B) also ship a thin `TokensRepository` with a minimal
  FK fixture to prove the encrypted store→lookup→reveal round-trip end to end. **Chose B** — proves
  the privacy-critical at-rest path (AES-GCM AAD + keyed fingerprint + `idx_tokens_fingerprint`)
  now; pipeline-driven bulk CRUD still lands with the detection phases.
- **Gated SQLCipher integration test.** The encrypted native build is **not linked under
  `flutter test`** on the CI/web host (confirmed: `PRAGMA cipher_version` returns no rows), so the
  real-cipher test **honestly skips** there (`markTestSkipped`) rather than failing or faking a
  pass. Real encryption-at-rest is covered at build/device time (the `apk-size-check` build bundles
  sqlite3mc). Unit tests use a plain file-backed executor to exercise the full state machine + DEK
  unwrap + token crypto without the cipher. ⚠ review — flagged so it's visible that the encrypted
  open is not exercised in unit CI.

## 2026-06-13 — V1 P1b: Argon2id salt + biometric KEK location ⚠ review

- **Context:** blueprint §8.1 / ADR-005 said the Argon2id salt lives in `vault_meta`, but
  `vault_meta` is inside the encrypted DB and is unreadable before the DB key (which needs the
  salt) is derived — a bootstrap paradox.
- **Options:** (A) `flutter_secure_storage` (Keystore/DPAPI-backed, pre-unlock readable);
  (B) plaintext sidecar file; (C) keep in `vault_meta` / use SQLCipher's own header KDF.
- **Choice:** **A** (maintainer-confirmed at the time). Salt — and the future biometric-wrapped
  KEK — live in secure storage; `vault_meta` keeps only post-unlock material (wrapped DEK,
  `key_version`). Graduated to **ADR-020**; §8.1/§8.2 + ADR-005 corrected.
- **Rationale:** A salt is non-secret KDF input but must be pre-unlock readable; secure storage
  is strictly stronger than a plaintext file and keeps sensitive metadata (wrapped DEK) inside
  the encrypted DB. (C) is impossible without abandoning Argon2id-as-KDF (contradicts ADR-019).

## 2026-06-13 — V1 P1b: dedicated SQLCipher DB-key subkey

- **Context:** §8.1 lists three HKDF subkeys (KEK, fingerprint-HMAC, sync); §8.2 opens SQLCipher
  with "the derived key" without saying which.
- **Options:** (A) reuse the KEK as the DB key; (B) derive a dedicated DB-key subkey.
- **Choice:** **B** — HKDF info `documink:sqlcipher:v1`, distinct from the KEK. Captured in ADR-020.
- **Rationale:** DB encryption and DEK-wrapping should never share key material; domain
  separation is cheap and standard (RFC 5869).

## 2026-06-13 — V1 P1a: encrypted vault cipher source `sqlite3mc`

- **Context:** ADR-003 named `sqlcipher_flutter_libs`, which resolves to a no-op shim under
  `package:sqlite3` 3.x; the classic runtime recipe no longer exists in our stack.
- **Options:** (A) `source: sqlite3mc` (SQLite3 Multiple Ciphers, MIT, no OpenSSL);
  (B) `source: sqlcipher` (community build, links OpenSSL); (C) downgrade the DB stack.
- **Choice:** **A** (maintainer-confirmed). Graduated to **ADR-019**; blueprint §2.4 corrected.
- **Rationale:** Maintained Build-Hooks path, license-clean, OpenSSL-free, no dep downgrade
  (honors the `--force-jit` / no-pin hard rule).

## 2026-06-13 — V1 P1a: defer `mink_embeddings` vec0 table to V1.2

- **Context:** sqlite-vec cannot be cleanly bundled under SQLCipher on Flutter today.
- **Options:** (A) build the vec0 virtual table now; (B) build the 16 relational tables now,
  defer vec0 to V1.2 when its consumers (Semantic/Resource memory) activate.
- **Choice:** **B.** Captured in **ADR-018**.
- **Rationale:** blueprint §3.2 already marks those consumers "activation V1.2"; no published,
  arm64-prebuilt, SQLCipher-compatible binding exists on the frozen toolchain.
