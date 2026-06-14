# CLAUDE.md — How to operate in the DocuMink repo

DocuMink is a privacy-first, local-first Flutter app (Android V1, Windows V2; iOS/macOS
deferred past V4) with an on-device AI assistant named **Mink**. No cloud inference, no
analytics, no plaintext PII ever leaves the device.

- **Platform targets:** Android (V1) → Windows (V2). iOS/macOS deferred past V4.
- **Stack floor (hard minimums):** Flutter ≥ 3.38, Dart ≥ 3.10, Riverpod ≥ 2.5,
  go_router ≥ 14, drift. Reference toolchain: Flutter 3.38.6 / Dart 3.10.7.

## Authoritative specs (read before touching related code)

Source of truth lives in `docs/`:
- `docs/PRD.md` — what & why (product, personas, tiers, perf/footprint ceilings).
- `docs/blueprint.md` — how (architecture, data model, pipeline). **§15 "Don't do" = 30 hard constraints.**
- `docs/memory.md` — Mink memory (six types, PII-safe token refs, single deterministic router).
- `docs/models.md` — Tier 4 LLM catalog, quantization, hosting, signing.
- `docs/roadmap.md` — V0→V5+ phases (**scope only**; live status lives in README "Build status").

**Precedence when specs disagree:** PRD defines *what*; blueprint defines *how*;
`memory.md` wins on memory behavior; `models.md` wins on Tier 4 detail.
**Surface conflicts — never silently reconcile** (`.agents/rules/deviation-protocol.md`).

## `.agents/rules/` is binding

The seven files in `.agents/rules/` were authored for another agent tool (AntiGravity),
but their **content is binding on Claude Code too**:
1. `privacy-invariants.md` — no cloud inference, no 3rd-party analytics, no plaintext sync,
   no raw PII/PHI in memory (token-refs / HMAC fingerprints only), project isolation, audit-log every tool call.
2. `architecture-invariants.md` — SQLite/SQLCipher only (no Postgres/extra DBs); single-agent
   deterministic Mink (no multi-agent); no silent model/tier swaps; Ed25519 verify every manifest; update `models.md` in the same PR as any Tier 4 change.
3. `license-policy.md` — allow Apache-2.0/MIT/BSD/ISC/Zlib/Unlicense/CC0; deny GPL/AGPL/CC-BY-NC*/
   Qwen-Research/Falcon-Research/Llama-Community; CI scanner enforces; no exceptions without explicit approval.
4. `commit-hygiene.md` — one feature/phase per PR; reference the roadmap phase in the message;
   update spec docs in the same PR when implementation reveals a spec issue; never commit secrets/sample-PII/build artifacts.
5. `dart-toolchain.md` — Dart 3.10 build_runner **must** use `--force-jit` (see Known constraints).
6. `workspace-context.md` — workspace overview, the spec precedence order above, and a pre-task checklist.
7. `deviation-protocol.md` — if a spec looks wrong/incomplete or a constraint blocks you: **STOP**,
   state what you tried, which spec conflicts, your proposed reading, and whether you'd change code or spec. Never work around silently.

## Known constraints

Each constraint names its upstream tracking issue and carries a standing instruction.
**Section standing instruction:** when a phase's work touches a documented workaround,
check whether its upstream issue is resolved; if it appears resolved, **propose** the
simplification at the phase-boundary review — **never remove a workaround autonomously.**

- **build_runner codegen on Dart 3.10 — `--force-jit` is mandatory.** Tracking:
  [dart-lang/build#4343](https://github.com/dart-lang/build/issues/4343).
  Always invoke: `dart run build_runner build --force-jit --delete-conflicting-outputs`
  (and `watch --force-jit`). Our dep tree pulls Build Hooks transitively (drift → sqlite3 →
  native_toolchain_c); without `--force-jit`, codegen fails with
  `'dart compile' does not support build hooks`. **Hard rule.** Do NOT downgrade deps, pin
  versions, or switch Dart/Flutter channels to dodge it. (blueprint.md §15 #30; `.agents/rules/dart-toolchain.md`.)

## Generated files

`*.g.dart` (e.g. `lib/data/app_database.g.dart`) **are committed** and must be kept current
with their source. `.gitignore` ignores `/build/` and `.dart_tool/` but not `*.g.dart` —
that is intentional. After editing a drift table / annotated source, regenerate with the
`--force-jit` command above and commit the regenerated file in the same change. CI enforces
currency (codegen-freshness job).

## Autonomy contract (Option C — continuous self-merge loop)

Supersedes the earlier "Option B" (human-merge, stop-at-every-phase-boundary) contract, by
explicit standing instruction from the maintainer (2026-06-13). The agent now drives the
roadmap end-to-end without stopping for human review at phase boundaries.

- You run **plan → implement → test → refine → document → ship AUTONOMOUSLY**, looping phase
  after phase **to the last phase in the roadmap**.
- **Per chunk/phase loop:**
  1. Drive the open PR's CI to **green** (fix failures, push, repeat).
  2. **Merge it yourself** on green (squash). Head branches auto-delete on GitHub; sync `main`.
  3. **Plan** the next chunk thoroughly and **output the concrete plan in chat** (in code mode —
     not plan mode), then **self-approve** it.
  4. Cut a fresh branch, **execute**, open the next PR. Repeat.
- **Branch / PR flow:** one branch per PR. The agent pushes its own feature branch, opens the
  PR **ready for review** (not draft), drives CI green, and **merges to `main` itself**.
- **Key decisions the specs don't determine:** pick the **recommended** option and proceed —
  do **not** block. **Log** every such decision (the options considered, the choice, and the
  rationale) in `docs/DECISIONS.md` for later human review.
- **Still STOP-and-surface (deviation-protocol):** a genuine **spec conflict**, a spec that
  looks wrong/incomplete, or anything that would weaken a **security/privacy invariant**
  (key/crypto/signature/PII handling that the specs don't already bless). Resolve with the
  recommended reading, log it prominently in `docs/DECISIONS.md`, and call it out in the PR —
  but never silently work around a constraint.
- **Commit-scope discipline:** one phase per commit/PR. Never bundle unrelated changes
  (formatting drift, doc-status edits, scratch files, process/governance edits) into a phase
  commit. Incidental cleanup or process changes are their own separate commit/PR.
- **High-stakes V1 phases — extra caution, fuller logging:** Phase 1 (vault/keys), Phase 9
  (device profiler / signed manifests), Phase 12 (Mink memory). Proceed autonomously, but log
  the security-relevant decisions in `docs/DECISIONS.md` with extra detail.

## Definition of done (every phase)

- `flutter analyze --fatal-infos --fatal-warnings` is clean.
- `flutter test` is green.
- The relevant CI jobs would pass locally (analyze, test, apk-size-check, license-scan,
  analytics-scan, verify-model-hashes, codegen-freshness — run the ones the phase touches).
- Docs updated **in the same phase** if implementation revealed a spec gap.
- README "Build status" updated to reflect the phase.

## Self-reporting honesty

Report what you **actually ran** and its **real output**. Never claim a gate passed without
running it. If a gate could not run (e.g. toolchain missing in this environment), say so
explicitly — do not infer or fabricate a result.

## Running gates in a web/remote session

This repo's gates need the Flutter toolchain. In Claude Code web sessions the container is
bare; `tool/setup_web_env.sh` (wired via the SessionStart hook in `.claude/settings.json`)
installs pinned Flutter 3.38.6. If it failed (e.g. network policy blocked the download),
gates cannot run — say so; run them on the Windows dev box or in CI instead.

**What runs headless here vs not:** `flutter analyze`, `flutter test` (**including widget
tests** — UI logic/structure/navigation is testable headless), and the CI scanners run in
this container. There is **no Android SDK, emulator, or device**, so anything needing native
platform channels, the encrypted-SQLite build, real rendering, models, or hardware (camera,
biometric, Keystore, ML Kit/ONNX, Tier-4 runtime, sync transport, signed APK/AAB build)
**cannot** be verified here.

## Device-bound phases: build behind seams now, batch verification (standing workflow)

A phase being "native" (camera/OCR, share/export rendering, sync transport, Tier-4 inference,
a11y) is **not** a reason to defer the whole phase to a device session. Build it **here**, the
same way the existing native features already are (Authenticator → `local_auth`; ML Kit
annotator; device-signal collector; sync transport): **do not stop at phase boundaries waiting
for a device.** Per phase:

1. **Model the native capability as a seam** — a small interface or typedef in pure Dart, with
   a *safe default* implementation (fails loudly / denies, never silently succeeds — see
   `DenyingAuthenticator`, `UnavailableOcrRecognizer`).
2. **Put the value in a pure-Dart orchestrator** (e.g. `InputIngestionService`) that depends
   only on the seams — this is the part worth testing and it is **fully headless-testable**.
3. **Write the real adapter** wrapping the plugin (e.g. `MlKitTextRecognizer`). It must
   **compile and analyze clean**; it is **not** exercised by `flutter test`. Compose it at
   bootstrap via a provider override.
4. **Test the orchestrator + UI with fakes** (success / cancel / empty / error paths). Widget
   tests cover screen structure and navigation.
5. **Batch the on-device checks into `VERIFICATION.md`** in the same PR — one item per native
   behavior you could not exercise here (capture, OCR accuracy, permission prompts, real
   rendering, transport, inference). **Never claim a deferred check passed.**

This keeps the autonomous roadmap loop moving through native phases while staying honest about
what is and isn't proven. Scope a native phase into headless-shippable slices; if part of it is
genuinely un-buildable here (e.g. it needs a license-cleared plugin you must first vet), ship
the buildable slice and log the remainder as a tracked follow-up (roadmap + `VERIFICATION.md` +
`docs/DECISIONS.md`) rather than blocking.

## Device verification & setup tracking

- **`VERIFICATION.md`** (repo root) is the running checklist of on-device/native checks the
  maintainer runs on the side. **Standing rule:** whenever a phase defers anything to a device
  (a gated/skipped test, a native adapter wired at bootstrap, rendering/a11y, models, signed
  builds), **add a checklist item to `VERIFICATION.md` in the same PR** — never claim a deferred
  check "passed". Keep items grouped by area with *what / where / device needed*.
- **`SETUP.md`** (repo root) is the maintainer-facing runbook for anything the agent needs the
  human to do (secrets/keys the agent must never hold: keystores, signing, Play Store, service
  accounts). **Keep it current** whenever build/release/secret requirements change, with exact
  Windows PowerShell commands. The agent never creates or commits keystores, passwords, or
  service-account files.
