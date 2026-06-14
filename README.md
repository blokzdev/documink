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

**V1 Phase 1 (core data layer & encrypted vault) — ✅ complete** (sub-PRs 1a–1d merged):
- **1a (merged)** — full drift schema (16 relational tables from blueprint §3.1 + §3.2) + SQLCipher-backed executor via `package:sqlite3` v3 `source: sqlite3mc` (ADR-019). The `mink_embeddings` vec0 table is deferred to V1.2 (ADR-018).
- **1b (merged)** — `KeyService`: the key hierarchy (Argon2id → MK → HKDF-SHA256 subkeys: DB key, KEK, fingerprint-HMAC, sync) + DEK wrap/unwrap (AES-256-GCM). Argon2id salt lives in `flutter_secure_storage` (pre-unlock); correctness anchored to RFC 9106 / RFC 5869 known-answer tests (ADR-020).
- **1c (merged)** — `VaultService`: the lock/unlock state machine (blueprint §8.2) — passphrase → derive keys → open the SQLCipher DB → unwrap the DEK → auto-lock timer (default 120s) → best-effort key zeroization on lock. Plus `TokenCrypto`/`TokensRepository`: token plaintext encrypted at rest with AES-256-GCM (AAD = surface token) and a keyed HMAC-SHA256 fingerprint for lookup. `appDatabaseProvider` now derives from the unlocked vault.
- **1d (merged)** — `RecoveryService`: BIP-39 24-word recovery phrase as a checksummed 256-bit codec for the Master Key (entropy path, exact round-trip; not the PBKDF2 seed) with confirm-by-re-entry (blueprint §8.4, ADR-021). Anchored to the Trezor BIP-39 vectors.

**V1 in progress — Phase 2 (detection pipeline, Tiers 1–3), delivered as sequential sub-PRs:**
- **2a (merged)** — detection core (pure Dart): `PiiRecognizer` abstraction + `DetectedSpan`/`PiiLabels`, `TextNormalizer` (Unicode NFC + zero-width strip + hyphen line-join, blueprint §4.1), the Presidio-style `OverlapResolver` (§4.5), and the `DetectionPipeline` orchestrator.
- **2b (merged)** — Tier 1 structured/checksum recognizers (§4.2), pure Dart: Email, URL, IP (v4/v6), SSN (SSA validity), CreditCard (Luhn), IBAN (mod-97).
- **2c (merged)** — Tier 1 heuristic/locale recognizers (§4.2), pure Dart: Date (ISO/numeric/textual), MRN and Passport (keyword-anchored via lookbehind, span tight to the identifier).
- **2d (merged)** — `PhoneRecognizer` (§4.2): candidate regex + `phone_numbers_parser` (pure-Dart libphonenumber port, MIT) validity check. **Completes Tier 1.**
- **2e (merged)** — Tier 2 `MlKitEntityRecognizer` (§4.3) wrapping `google_mlkit_entity_extraction`: the ML-Kit-type → label mapping is pure-Dart tested via an injectable annotator; the native on-device adapter is isolated and composed at Phase 5 bootstrap. (minSdk raised 24→26 for ML Kit.)
- **Tier 3 (GLiNER)** — delivery strategy decided (**ADR-022**): hybrid bundled-baseline + device-tiered downloaded upgrade via the Phase 9 signed manifest, with graceful degradation to Tiers 1–2. The downloaded-upgrade path depends on Phase 9 infra, so **full Tier 3 lands with/after Phase 9**.

**V1 in progress — Phase 3 (anonymizer operators, blueprint §4.6/§7.1), delivered as sequential sub-PRs:**
- **3a (merged)** — operator framework + policy engine (default YAML asset + per-workspace/document overrides) + the 3 irreversible operators (Redact/Mask/Replace) with offset-correct (right-to-left) application. Pure Dart.
- **3b (merged)** — reversible vault-backed operators (§7.1): **Token-Random** (`<LABEL_6base62>` surrogate + AES-256-GCM ciphertext via 1c's `TokenCrypto`, reversible by lookup) and **Encrypt** (stateless inline `<ENC:base64>`). `AnonymizationService` precomputes the async surrogates then delegates to the sync `Anonymizer`, returning persistable `TokenRecord`s.
- **3c (merged)** — **FF1 format-preserving encryption** (NIST SP 800-38G, FF1 only — FF3 forbidden) hand-rolled on `pointycastle` AES, **verified against the NIST FF1 sample vectors**. `FpeOperator` does digit-string FPE preserving separators with card keep-last-4; tweak = SHA-256(entity_type ‖ workspace_id); keyed by the vault DEK; deterministic + reversible (no vault row). Wired into the policy/`AnonymizationService`. **Completes V1 Phase 3 (anonymizer operators).**

**V1 in progress — Phase 9 (Device Capability Profiler, blueprint §4.7).** Sequenced ahead of the native/UI phases (4–8) by maintainer decision — it's pure-Dart/testable in this environment and **unblocks the deferred Tier 3 model delivery** (ADR-022):
- **9a (merged)** — the pure-Dart selection core: `DeviceCapabilities` + `capabilityScore` (§4.7 formula), the `TierCatalog`/`ModelVariant` model, and `DeviceCapabilityProfiler.selectTier` (device-agnostic, no ceiling: highest auto-qualifying tier → Balanced, opt-in tiers surfaced, 20% storage headroom, floor-reason diagnosis). Fixture-tested (floor/minimum/mid/flagship/synthetic-future + storage & RAM gates).
- **9b (merged)** — **Ed25519-signed manifest** (§4.7 / models.md §5). `ManifestVerifier` verifies the signature over the manifest body against a **pinned** public key (rejects tampered body/signature/wrong-key/bad-alg — never falls back to unsigned), then parses it into a `ModelManifest` (`TierCatalog` + Tier 3 `DetectionModel`s). `ModelHashVerifier` does post-download SHA-256. Ships `assets/model_manifest/manifest.{json,signed.json}` + a re-runnable `tool/scripts/sign_manifest.dart`. The manifest also carries the **Tier 3 GLiNER PII** entries — **unblocks the deferred Tier 3 delivery** (ADR-022).
- **9c (this PR)** — persistence + orchestration: `ProfilerState` (the §4.7 `llm_*` fields) persisted to `vault_meta` as one JSON blob via `ProfilerRepository`; `DeviceSignalCollector` interface (native Android/Windows adapters wired at Phase-5 bootstrap); `ProfilerService` (collect → select against the verified manifest → persist; `recheck`). Providers wired. **Completes V1 Phase 9 (Device Capability Profiler + signed manifest).**

**V1 in progress — Phase 6 (custom entity types, roadmap §6), pure Dart:**
- **6a (merged)** — `CustomEntityDefinition` (label/regex/validator/examples/default-operator) + `CustomEntityValidator` (form vetting: regex compiles, operator/validator known, examples match + pass the validator) + `CustomEntityRecognizer` (a `PiiRecognizer` running user patterns → spans, with the `luhn`/`none` validator) + `CustomEntityRepository` (persist to `custom_entity_types`, workspace-global vs Project-scoped).
- **6b (this PR)** — `RegexSandbox`: ReDoS-safe live preview running the user pattern in a **disposable isolate** with a hard timeout (killed on timeout) + a sample-length cap, returning `ok`/`error`/`timedOut`. **Completes V1 Phase 6 (custom entity types).**

**V1 in progress — Phase 12 (Mink memory, memory.md §3), high-stakes:**
- **12a (merged)** — the PII-safe write-path invariant (memory.md §3.3): `TokenRef` (Form A) + `<<tok_…>>` inline markers (Form B) + `isTokenRefMap`; `MemoryPiiScanner` runs the detection pipeline over would-be memory content, recursively walking JSON and **excluding token references**, flagging any unreferenced PII; `MemoryWriteGuard.assertNoPlaintext` rejects leaks with a structured `MemoryPiiLeakError`.
- **12b (merged)** — `MemoryRepository` for the active-V1 types (Core + Episodic): every write passes the guard; recall is scope-aware (current Project + workspace globals); Episodic recall supports `since`/`episodeType`/`limit`, newest-first. `forget` deletes.
- **12c (this PR)** — `MemoryRouter`: the deterministic (no-LLM) dispatcher mapping Mink's memory tool calls (`remember`/`recall_core`/`recall_episodic`/`forget`) to the repository; a rejected write (unreferenced PII) surfaces as a failed `MemoryToolResult` rather than throwing. **Completes V1 Phase 12 (Mink memory, active-V1: Core + Episodic + PII-safe write path).**

**V1 Phase 15 (audit log) — in progress:**
- **15a (this PR)** — `AuditLogRepository`: append-only `record(...)` for the full event-type set (`AuditEventType`: decode/export/sync/vault_unlock/biometric_failed/mink_tool_call/tier_change/…), newest-first `query` filterable by event type(s) + time range with `limit`/`offset` pagination, and RFC-4180 **CSV export**. Privacy invariant #7 (audit every privacy-relevant action). The Settings → Audit Log UI is a UI-phase task.

**V1 Phase 8 (sync) — crypto core started:**
- **8a (merged)** — `SyncEnvelope`: AES-256-GCM seal/open of CRDT sync deltas under the MK-derived `syncKey` (§9.1 "never sync plaintext"). Versioned wire format (`version‖nonce‖ct‖mac`); the **delta id + origin device id are bound as AAD** so a delta can't be relabelled, replayed, or re-attributed. The delta payload is opaque (cr-sqlite CBOR at runtime).
- **8b (this PR)** — CRDT conflict resolution (§9.4): `lwwWinner` (Last-Writer-Wins on scalars, deterministic device-id tiebreak) + `setUnion` (collection merge) primitives, and `SyncConflictDetector` that surfaces **hard conflicts** cr-sqlite would silently LWW — two devices creating the same custom-entity identity (`workspace,project,label`) with diverging definitions → Settings → Sync Conflicts. The native transport (cr-sqlite, BYOC Drive, mDNS/WebSocket) is a device-session task.

**V1 Project system (§6) — manifest + permission enforcement:**
- `ProjectManifest` parses the §6.1 declarative config (permissions, default policy → `AnonymizationPolicy`, custom-entity seeds, persona); `ProjectPermissions` is **deny-by-default** (bool / `requires_biometric` / absent). `ToolPermissionRegistry` maps every Mink tool to its required permission (§5 table) and decides allow / allow-with-biometric / deny — the project-isolation enforcement point for Mink tool dispatch.

**Enablement (build & release):** a manual **Build APK (manual)** workflow (`workflow_dispatch`) produces a sideloadable debug-signed APK artifact for phone testing; a **Release (signed AAB)** workflow signs an App Bundle from upload-key secrets on `v*` tags (Play App Signing). Release signing is scaffolded in `android/app/build.gradle.kts` (debug fallback when secrets absent). See **`SETUP.md`** for the one-time keystore/secrets steps and **`VERIFICATION.md`** for the on-device checklist. (Phase 4↔5 build order swapped — UI before native input; see `docs/roadmap.md`.)

**V1 Phase 5 (UI/UX) — in progress:**
- **5a (merged)** — app-shell foundation: runtime light/dark/system theming (`themeModeProvider` + AppBar quick-toggle), go_router navigation skeleton (`routerProvider` + `Routes`), and the **Home hub** (primary actions: Scan / Paste / Import / New Project / Chat with Mink, + Settings). Destinations not yet built route to clearly-labelled placeholders. **Widget-tested** (render, navigation, theme toggle). On-device rendering / FLAG_SECURE / a11y tracked in `VERIFICATION.md`.
- **5b (merged)** — the **paste-and-redact editor**: paste text → real Tier-1 detection (`detectionPipelineProvider`, headless) → per-entity-type operator selection (Redact / Mask / Replace) → live **redacted preview** (pure `Anonymizer`). First functional vertical slice; fully widget-tested. Reversible operators (Token-Random / FPE / Encrypt) need the vault-unlock UX and arrive in a later chunk.
- **5c (merged)** — the **Settings screen**: live theme selection (System / Light / Dark via `RadioGroup`, wired to `themeModeProvider`) plus the Security / Privacy / About structure (rows that depend on native features — biometrics, vault, audit-log UI — shown as labelled placeholders until their phases). Widget-tested.
- **5d (merged)** — **settings persistence**: a `SettingsStore` seam (in-memory default for tests; `shared_preferences`-backed impl wired at bootstrap) so the theme choice survives restarts. Non-sensitive prefs only — never PII (privacy invariant #4). The store is the reusable persistence point for later non-sensitive settings.
- **5f (this PR)** — **reversible operators in the editor**: now that the editor sits behind the vault gate, its operator picker adds **Token-Random** (`<EMAIL_xxxxxx>` vault surrogate) and **Encrypt** (`<ENC:…>` inline ciphertext) alongside Redact/Mask/Replace, computed via `AnonymizationService` (unlocked-vault `TokenCrypto`). Preview-only — tokens are minted but **not persisted** until save/export (a later phase). FPE is held for a later per-type chunk (FF1 needs numeric input). Picker moved to wrapping `ChoiceChip`s. Headless-tested with an in-memory unlocked-vault seam.
- **5g (this PR)** — **save anonymized documents to the vault**: a `DocumentRepository` transactionally persists a `documents` row + its detected `entities` + reversible `tokens` (linked via a new `AnonymizationOutcome.tokensBySpan`), and writes a `document_saved` audit entry; a **Save to vault** action in the editor persists the exact previewed outcome (so stored tokens match the surrogates). Single default workspace for V1 (multi-workspace UI later). End-to-end headless test decrypts a persisted token back to its plaintext.
- **5h (this PR)** — **vault browser + document detail**: `My documents` lists saved documents (newest first, with empty state) from the vault; tapping one opens a read-only detail screen showing the redacted content + metadata. Biometric-gated **reveal** of reversible tokens is a later (native) phase. Widget-tested.
- **5i (this PR)** — **biometric-gated token reveal** (§5 `decode`; high-stakes): the document detail screen reveals the original values behind reversible tokens after device auth. Decryption is real (vault `TokenCrypto`); the prompt sits behind an `Authenticator` seam (deny-by-default; `local_auth` wired at bootstrap; fake in tests). Every attempt — success or denial — is **audit-logged** (`document_reveal`, with biometric result); plaintext is shown transiently and never persisted/logged. Headless-tested for approve (plaintext shown) and deny (error, no plaintext).
- **5j (this PR)** — **delete documents**: a delete action (with confirm dialog) in the document detail removes the document + its entities + tokens in one transaction and audits `document_deleted`; the vault list refreshes. Completes the document CRUD lifecycle. Widget- + repo-tested.
- **5e (merged)** — **vault unlock UX** (§8.2; high-stakes): a passphrase gate (`VaultUnlockScreen`) that creates the vault on first run (passphrase + confirm → `initialize`) and unlocks thereafter (`unlock`); a go_router redirect gates every screen behind `appUnlockedProvider` (locked → unlock screen). Bootstrap wires the vault DB file (`path_provider`). Widget-tested headlessly against a real `VaultService` (in-memory key store + plain executor): create→unlock, wrong-passphrase rejection, mismatch validation, and the gate redirect. Unblocks reversible operators + the vault browser. Biometric fast-path remains a later phase.

**Status:** the full headless-testable pure-Dart/crypto core of V1 is complete. Remaining phases (5 UI then 4 input, 7 export rendering, 8 transport, 10–11 Tier-4 runtime, 13–14 template/inference UI, 16–17 a11y/release) are native/UI/model and need a device or Windows box to build and validate.

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
