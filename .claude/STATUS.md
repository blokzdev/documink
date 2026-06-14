# DocuMink — Working Status

_Working memory for Claude Code sessions. Scope lives in docs/roadmap.md; history in git.
Update at each phase boundary (e.g. via `/phase-audit`)._

## Current phase
**V1 Phase 4 (input handlers) — ✅ COMPLETE.** Camera scan, image import, PDF import (text-layer +
scanned-page OCR), inbound share-sheet intent, and encrypted original-document retention + biometric
reveal all shipped (PRs #50, #51, #52, #53, #54, #55) + this audit/polish pass.
**Next (candidates):** work the `VERIFICATION.md` device checklist on a real device, **or** start
**V1 Phase 12 — Mink conversational layer + typed memory** (high-stakes; the big one). Earlier V1
phases already merged: 1 (vault/keys), 2 (detection T1–3 scaffolding), 3 (operators), 5 (UI + i18n
scaffold), 6 (custom entities), 7 (export core), 8 (sync crypto core), 9 (profiler + signed
manifest), 12a–c (memory core), 15a (audit log). See README "Build status".

## Done / verified this pass (Phase 4 audit + polish, PR-1)
- New `/phase-audit` command (`.claude/commands/phase-audit.md`) — reusable end-of-phase loop.
- Fixed a real bug: `ShareIntentCoordinator` now guards all async paths (a failed/failed-OCR share
  is dropped, never an unhandled async crash) + tests.
- Added the missing `blueprint.md` §15 #30 (the `--force-jit` rule) so existing citations resolve.
- Recorded device-correctness checks (EXIF/orientation, HEIC, shared-image `content://` path,
  large-image OCR memory) in `VERIFICATION.md`.
- Gate evidence (2026-06-14, Flutter 3.38.6 / Dart 3.10.7): `flutter analyze --fatal-infos
  --fatal-warnings` clean; `flutter test` green; license/analytics scanners pass. apk-size-check
  runs in CI (no Android SDK here).

## Open decisions awaiting human input
- _(none)_ — Phase 12 vs device-verification sequencing is the maintainer's call when ready.

## Known issues / deferrals
- **PR-2 (queued):** app-wide i18n completion (document_detail/settings/viewer + keep-original hint),
  `InputSourceKind.sharedText` naming fix, and extract duplicated test fakes → `test/support/`.
- **Device-verify before coding** (VERIFICATION.md): EXIF-rotation OCR, HEIC decode, shared-image
  `content://`→`fromFilePath` readability, large-image OCR memory. Only add code (EXIF rotate,
  content-URI copy, downscale) if a real device shows a gap — avoid speculative plugins.
- **Shared-image original retention** — the share coordinator path doesn't yet set a
  `pendingOriginal`; only CaptureScreen paths do (tracked follow-up).
- **JVM-target band-aid:** `kotlin.jvm.target.validation.mode=warning` (for `receive_sharing_intent`);
  revisit with a proper alignment or `share_handler` migration when CI-verifiable.
- **pdfrx consolidation** (CLAUDE.md "Deferred opportunities") — blocked on Flutter ≥ 3.41.
- Carried NTH nits: `check_licenses.dart` `${delayMs}` literal log; `test/placeholder_test.dart`
  tautology; stale gradle TODO `android/app/build.gradle.kts`.
- **Upstream watch:** dart-lang/build#4343 (`--force-jit`). Re-check each phase boundary; propose
  simplification only if resolved.

## Next-phase entry criteria (if Phase 12 — Mink)
- Re-read memory.md (§3 PII-safe refs, §5 router), blueprint §5 (Mink), models.md (Tier-4),
  roadmap Phase 12. High-stakes (memory/PII) — extra caution + fuller DECISIONS logging.
- Build behind seams (LlmBackend) per CLAUDE.md; the Tier-4 runtime is device-verified.
