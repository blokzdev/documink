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
