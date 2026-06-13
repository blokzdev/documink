# Decisions log

Running record of **key decisions the specs did not fully determine**, made autonomously under
the Option-C continuous-loop autonomy contract (see `CLAUDE.md`). Each entry lists the options
considered, the choice, and the rationale, for later human review. Genuine spec conflicts and
security-sensitive resolutions are flagged **⚠ review**.

Format: newest first. A decision that later graduates into a spec/ADR notes the ADR id.

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
