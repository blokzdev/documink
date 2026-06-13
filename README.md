# DocuMink

Privacy-first, local-first document redactor plus on-device AI assistant.

- **Platforms:** Android V1, Windows V2. iOS/macOS deferred past V4.
- **Stack:** Flutter ≥3.38, Dart ≥3.10, Riverpod, drift+SQLCipher, sqlite-vec, flutter_gemma, fllama, cr-sqlite.
- **Domain:** documink.ai
- **Hard rules:** No cloud inference. No user accounts. No third-party analytics. No plaintext sync. No PII/PHI in memory tables.

## Authoritative specs

All architectural decisions live in `docs/`:

- `docs/PRD.md` — product requirements; what we're building and why
- `docs/blueprint.md` — technical architecture; how we're building it
- `docs/memory.md` — Mink memory subsystem specification
- `docs/models.md` — Tier 4 LLM catalog, sources, quantization, and hosting strategy
- `docs/roadmap.md` — milestones → phases → tasks

**Precedence when specs disagree:**
- PRD defines *what*; blueprint defines *how*.
- memory.md is authoritative on memory behavior.
- models.md is authoritative on Tier 4 model-level detail (sources, quantization, hosting).
- If blueprint and models.md disagree on a model detail, models.md wins and blueprint is updated to match.

## For AI agents working in this repo

Before starting any task:

1. Read the relevant Roadmap phase in `docs/roadmap.md`. V1 has 17 phases in dependency order.
2. Check blueprint.md §15 "Don't do" rules before proposing architectural changes. These encode researched failure modes.
3. For memory-layer work, read memory.md §3 (PII-safe reference model) and §12 (memory-specific "don't do" rules).
4. For Tier 4 model work, read models.md — catalog, quantization choices, hosting strategy, and §9 catalog-specific rules.
5. Flag any proposed deviation from the docs explicitly. Either the implementation should change, or the docs should be updated — but not silently.

**Codegen command:** run `dart run build_runner build --force-jit --delete-conflicting-outputs`. The `--force-jit` flag is required on Dart 3.10 until [dart-lang/build#4343](https://github.com/dart-lang/build/issues/4343) is resolved; omitting it will fail with `'dart compile' does not support build hooks`. See `docs/blueprint.md` §15 #30 and `.agents/rules/dart-toolchain.md`.

See `.agents/rules` subfolder for workspace-wide conventions (serialized by AntiGravity from its Customizations → Rules → Workspace panel).

## Build status

**V0 complete.** Phase 1 — Flutter scaffold (three flavors dev/staging/prod, Riverpod + go_router + drift codegen, strict lints). Phase 2 — CI/CD guardrails (analyze, test, apk-size, license-scan, analytics-scan, verify-model-hashes, codegen-freshness; pre-commit hooks). Phase 3 — Architecture Decision Records (ADR-001…ADR-017) committed under `docs/adr/`.

**V1 in progress — Phase 1 (core data layer & encrypted vault), delivered as sequential sub-PRs:**
- **1a (merged)** — full drift schema (16 relational tables from blueprint §3.1 + §3.2) + SQLCipher-backed executor via `package:sqlite3` v3 `source: sqlite3mc` (ADR-019). The `mink_embeddings` vec0 table is deferred to V1.2 (ADR-018).
- **1b (this PR)** — `KeyService`: the key hierarchy (Argon2id → MK → HKDF-SHA256 subkeys: DB key, KEK, fingerprint-HMAC, sync) + DEK wrap/unwrap (AES-256-GCM). Argon2id salt lives in `flutter_secure_storage` (pre-unlock); correctness anchored to RFC 9106 / RFC 5869 known-answer tests (ADR-020). Next: 1c (VaultService), 1d (BIP-39 recovery).

## Development setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate drift schema code:
   ```bash
   dart run build_runner build --force-jit --delete-conflicting-outputs
   ```

3. Enable Git pre-commit hooks:
   ```bash
   git config core.hooksPath .githooks
   ```
   *Note: For Windows developers, this relies on Git-for-Windows evaluating shell scripts (`sh.exe`), which is the default configuration.*
