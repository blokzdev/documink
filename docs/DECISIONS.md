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
