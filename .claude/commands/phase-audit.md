---
description: End-of-phase audit + safe polish loop — sweep the finished phase for loose ends, run the gates, apply low-risk fixes, and refresh governance docs.
argument-hint: "<phase label or git range, e.g. 'V1 Phase 4' or main..HEAD>"
---

You are running DocuMink's **end-of-phase audit + polish** loop for: **$ARGUMENTS**
(if blank, infer the just-finished phase from `git log` + `docs/roadmap.md` + `.claude/STATUS.md`).

Authoritative context to (re)read first: `CLAUDE.md` (Definition of done, Device-bound phases,
Autonomy/commit-scope), `.agents/rules/*` (binding), `docs/roadmap.md` (phase scope),
`docs/blueprint.md` §15 "Don't do", and `.claude/STATUS.md`. **Precedence:** PRD→what,
blueprint→how, memory.md→memory, models.md→Tier-4. Surface conflicts, never silently reconcile
(`.agents/rules/deviation-protocol.md`).

## 1. Scope the diff
Determine the phase's commit range (e.g. `git log --oneline` since the last phase merge) and the
changed files. Focus the audit there; note cross-cutting consistency with prior phases.

## 2. Sweep for issues (report each with file:line, grouped Bug / Consistency / Test-gap / Refinement)
- **Correctness:** unhandled async/errors, fire-and-forget failures, missing null/empty/cancel
  paths, resource leaks (temp files, controllers, subscriptions, image cache).
- **Seam discipline (CLAUDE.md "Device-bound phases"):** every native capability behind a seam
  with a fail-loud safe default; pure-Dart orchestrator; real adapter wired at bootstrap; UI/logic
  fake-tested. Flag any native call not behind a seam.
- **Privacy invariants (`.agents/rules/privacy-invariants.md`):** no plaintext PII persisted/logged;
  decode/reveal biometric-gated + audited; nothing PII synced in plaintext; no 3rd-party analytics.
- **Consistency:** localization coverage (whole-screen, not half), naming, error-message style,
  spec citations that don't resolve, license-policy adherence for any new dep.
- **Test gaps:** which new behavior has no headless test (orchestrators, controllers, widgets with
  fakes); is every deferred device behavior in `VERIFICATION.md`?
- **Refinement:** duplication (e.g. test fakes → `test/support/`), dead code, stale TODOs.

## 3. (Optional) Web research
For anything uncertain (a plugin's required native setup, an OCR/crypto/Flutter best practice, an
upstream workaround's status), use WebSearch/WebFetch. Recheck documented upstream workarounds (e.g.
dart-lang/build#4343 `--force-jit`); if resolved, **propose** the simplification at this review —
never remove a workaround autonomously (CLAUDE.md "Known constraints").

## 4. Run the gates the phase touched (report real output; never fabricate)
- `flutter analyze --fatal-infos --fatal-warnings`
- `flutter test`
- If codegen sources changed: `dart run build_runner build --force-jit --delete-conflicting-outputs`
  then `git diff --exit-code -- '**/*.g.dart'` (codegen-freshness).
- Scanners as relevant: `dart run tool/scripts/check_licenses.dart`,
  `dart run tool/scripts/check_analytics_sdks.dart`, `dart run tool/scripts/verify_model_hashes.dart`.
- APK size (`apk-size-check`) runs in CI (no Android SDK here) — note it.
CI jobs mirrored: analyze, test, apk-size-check, license-scan, analytics-scan, verify-model-hashes,
codegen-freshness.

## 5. Apply SAFE polish only
Fix confident, low-risk findings (+ tests). For anything ambiguous, architectural, security-/
privacy-sensitive, or that would weaken an invariant: **STOP and ask the maintainer**
(`AskUserQuestion`) — log the decision in `docs/DECISIONS.md`. Keep commit scope tight: one concern
per PR (`.agents/rules/commit-hygiene.md`); split unrelated cleanup (e.g. legacy-wide i18n) into its
own PR rather than bundling.

## 6. Update governance/docs (same PR)
- **`VERIFICATION.md`** — one item per device-only behavior this phase deferred (what / where /
  device needed). Never claim a deferred check passed.
- **`docs/DECISIONS.md`** — newest-first entry for each underdetermined choice (options, choice,
  rationale); high-stakes phases (vault/keys, profiler/manifests, Mink memory) get fuller detail + ⚠.
- **`README.md`** "Build status" — reflect the phase.
- **`.claude/STATUS.md`** — refresh: current phase + gate evidence (date + `flutter --version`),
  open decisions, known issues/deferrals, next-phase entry criteria.

## 7. Output
A concise findings report (what was fixed vs tracked), the real gate output, and the doc updates.
Then follow the autonomy loop: open the PR ready-for-review, drive `documink-ci` green, squash-merge,
sync `main` — unless the phase was high-stakes and the maintainer asked to review first.
