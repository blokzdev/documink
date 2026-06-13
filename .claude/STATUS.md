# DocuMink — Working Status

_Working memory for Claude Code sessions. Scope lives in docs/roadmap.md; history in git.
Update at each phase boundary._

## Current phase
**V0 COMPLETE** — Phase 3 ADRs (ADR-001…ADR-017 + index) committed under `docs/adr/`.
**Next:** V1 Phase 1 (Core data layer & vault) — not started. High-stakes phase (vault/keys).

## Done / verified this phase (V0 Phase 3 — ADRs)
- `docs/adr/README.md` (index + template/conventions) + `docs/adr/ADR-001.md`…`ADR-017.md`.
- ADR-016 defers to `memory.md`, ADR-017 defers to `models.md` (authoritative); all others cite specs.
- README "Build status" refreshed to V0-complete (prior staleness resolved).
- Gate evidence (2026-06-13, Flutter 3.38.6 / Dart 3.10.7; docs-only change):
  - `flutter analyze --fatal-infos --fatal-warnings` → No issues found!
  - `flutter test` → All tests passed! (1 test)
  - code gates (license/analytics/model-hash/codegen-freshness/apk) unaffected by docs; verified in CI on the PR.

## Open decisions awaiting human input
- _(none)_

## Known issues / deferrals
- **Dangling spec ref:** `blueprint.md` §15 ends at #29, but `CLAUDE.md`, `README.md` (line ~36),
  and `pubspec.yaml` cite "blueprint.md §15 #30" for the `--force-jit` rule. The rule lives in
  `.agents/rules/dart-toolchain.md`. Reconcile in a dedicated docs fix (out of scope for V0 P3).
- NTH-1 `check_licenses.dart:142` literal `${delayMs}` log bug — deferred.
- NTH-2 `test/placeholder_test.dart` is a tautology; add a real smoke test (carry into V1 P1).
- NTH-3 stale TODO `android/app/build.gradle.kts:23` (applicationId already set).
- NTH-5 pre-commit hook needs `git config core.hooksPath .githooks` on fresh local clones
  (web sessions handle it via the SessionStart hook).
- **Upstream watch:** dart-lang/build#4343 (`--force-jit`). Re-check at each phase boundary; propose simplification if resolved.

## Next-phase entry criteria (V1 Phase 1)
- Re-read blueprint §8 (key hierarchy), §3.1 (core schema), ADR-003/005/006/007; memory.md §3.
- V1 P1 is high-stakes (vault/keys/crypto) — extra caution, more frequent stops per CLAUDE.md.
