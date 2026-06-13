# DocuMink — Working Status

_Working memory for Claude Code sessions. Scope lives in docs/roadmap.md; history in git.
Update at each phase boundary._

## Current phase
V0 bootstrap complete; V0 Phase 2 (CI/CD) hardened. **Next:** V0 Phase 3 (ADRs) — not started.

## Done / verified this phase
- Bootstrap: CLAUDE.md, this STATUS file, web-session setup hook added.
- Phase-2 hardening: SF-1…SF-4 applied (see git).
- Gate evidence (run 2026-06-13 in web container, Flutter 3.38.6 / Dart 3.10.7):
  - `flutter analyze --fatal-infos --fatal-warnings` → No issues found!
  - `flutter test` → All tests passed! (1 test)
  - `check_licenses.dart` → 76 hosted packages, all compliant.
  - `check_analytics_sdks.dart` → passed. `verify_model_hashes.dart` → no bundled models (placeholder).
  - `build_runner build --force-jit --delete-conflicting-outputs` → 27 outputs; `git diff` over `*.g.dart` clean → committed `app_database.g.dart` is current.
  - `flutter build apk` → NOT RUN here (no Android SDK in container); apk-vs-150MB ceiling verified only in CI.

## Open decisions awaiting human input
- _(none — bootstrap decisions resolved 2026-06-13)_

## Known issues / deferrals
- NTH-1 `check_licenses.dart:142` literal `${delayMs}` log bug — deferred.
- NTH-2 `test/placeholder_test.dart` is a tautology; add real smoke test by V0 P3.
- NTH-3 stale TODO `android/app/build.gradle.kts:23` (applicationId already set).
- NTH-5 pre-commit hook needs `git config core.hooksPath .githooks` (now run by setup hook in web sessions; still manual on fresh local clones).
- README "Build status" lags actual phase — refresh on next doc-touch.
- **Upstream watch:** dart-lang/build#4343 (`--force-jit`). Re-check at each phase boundary; propose simplification if resolved.

## Next-phase entry criteria
- All gates green on the branch (or in CI) before starting V0 Phase 3.
