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

## Autonomy contract (Option B)

- You MAY run **plan → implement → test → refine → document AUTONOMOUSLY *within* a single
  roadmap phase.**
- At every **phase boundary**, STOP for human review: commit the phase to the current
  **feature branch**, push it, and open (or update) a **PR into `main`** — then wait. Do not
  start the next phase until the human has reviewed.
- **Branch / PR flow:** one branch per PR (a branch may carry multiple commits). The agent
  pushes its **own feature branch** and opens the PR; the agent **never pushes to or merges
  `main`** — the human reviews and merges. After a merge, sync to the updated `main` and cut a
  fresh branch for the next phase.
- Within a phase, if you hit a decision the specs don't determine, a spec conflict, or
  anything security-sensitive (keys, crypto, signatures, PII handling) → **STOP and surface
  it.** Never choose silently (`deviation-protocol.md`).
- **Commit-scope discipline:** one phase per commit. Never bundle unrelated changes
  (formatting drift, doc-status edits, scratch files) into a phase commit. Incidental cleanup
  is its own separate commit.
- **High-stakes V1 phases — extra caution, more frequent stops:** Phase 1 (vault/keys),
  Phase 9 (device profiler / signed manifests), Phase 12 (Mink memory).

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
