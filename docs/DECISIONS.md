# Decisions log

Running record of **key decisions the specs did not fully determine**, made autonomously under
the Option-C continuous-loop autonomy contract (see `CLAUDE.md`). Each entry lists the options
considered, the choice, and the rationale, for later human review. Genuine spec conflicts and
security-sensitive resolutions are flagged **⚠ review**.

Format: newest first. A decision that later graduates into a spec/ADR notes the ADR id.

---

## 2026-06-14 — V1 Phase 5d: settings persistence

- **`SettingsStore` interface + in-memory default + `shared_preferences` impl at bootstrap** — the
  same injectable-seam pattern as `SecureKeyStore`/`DeviceSignalCollector`, so headless tests run
  without platform channels and the persistent store is device-verified (VERIFICATION.md).
- **Non-sensitive prefs only** in `shared_preferences` (theme mode). Privacy invariant #4: **no PII**
  here — sensitive state stays in the encrypted vault. Theme mode is not PII.
- `shared_preferences` (BSD-3, allowlisted) added; replaces the deferred-deps comment in pubspec.
- `themeModeProvider.build()` reads the persisted value synchronously (the store is loaded at
  bootstrap before `runApp`), so theme applies pre-first-frame without a flash.

## 2026-06-14 — V1 Phase 5b: paste-and-redact editor

- **Irreversible operators only** (Redact / Mask / Replace) in this chunk: they run through the
  pure synchronous `Anonymizer` with **no unlocked vault**, so the whole flow is headless-testable.
  Reversible operators (Token-Random / FPE / Encrypt) need the vault-unlock UX + crypto and land in
  a later chunk (`editorOperators` enforces this; all are `!isReversible`).
- **Operator selection per label (entity type), not per span.** Matches the policy engine's
  label→operator model (`AnonymizationPolicy.operatorFor(label)`) and keeps the `Anonymizer`
  unmodified. Per-span granularity is a possible later refinement.
- **Default = redact** for every detected label (privacy-safe default), overridable in the UI.
- Editor state is a `Notifier<PasteEditorState>` that stores the computed `previewText`, so the
  screen just renders state and tests assert on it directly.

## 2026-06-14 — V1 Phase 5a: UI app-shell foundation

Spec doesn't dictate UI implementation details; recommended choices:

- **Runtime theming** via `themeModeProvider` (`Notifier<ThemeMode>`, default `system`, AppBar
  quick-toggle cycles system→light→dark). **In-memory for now**; persistence lands with the Settings
  screen (Phase 5e) — no need to introduce a settings store yet.
- **Router as a provider** (`routerProvider` + `createRouter()` factory) instead of a single global
  `GoRouter`, so widget tests get an isolated router (no navigation state leaking between tests).
  `Routes` centralizes path constants.
- **Placeholder destinations** for routes whose full screens land in later chunks (Phase 4 native
  input, 5b editor, 5e settings, etc.) — keeps navigation real and widget-testable now without
  faking. Each placeholder names the phase that will replace it.
- **`context.push`** (not `go`) for Home actions so there's a back stack.
- Widget tests run headless; **visual correctness, FLAG_SECURE, and a11y remain device-verified**
  (VERIFICATION.md).

## 2026-06-14 — Enablement: testable APK, Play Store signing, verification/setup governance

Maintainer-directed (the specs don't cover build/release plumbing). Decisions:

- **Sideloadable test APK via a separate manual workflow.** New
  `.github/workflows/build-apk.yml` is **`workflow_dispatch`-only** so it doesn't burn Action
  minutes on every PR (maintainer's call). It uploads the debug-signed `app-prod-release.apk`
  as an artifact. `ci.yml`'s `apk-size-check` is untouched (stays the per-PR size gate, no upload).
- **Play App Signing + upload key** for Play Store (recommended path). `build.gradle.kts` gains a
  `release` signingConfig that reads `android/key.properties` (local) or `ANDROID_*` env/secrets
  (CI), **falling back to debug signing when absent** so secret-less builds (apk-size-check, fork
  PRs) still compile. New `release.yml` builds a signed AAB on `v*` tags. The agent **never creates
  or commits keystores/passwords** — the maintainer generates and holds them on their Windows box;
  `SETUP.md` is the runbook (exact PowerShell). ⚠ review (security-adjacent: signing/secrets) — no
  invariant weakened; no secret material in the repo (gitignored).
- **`VERIFICATION.md` introduced** as the running on-device/native verification checklist, seeded
  from the deferred-items audit; **`SETUP.md`** as the maintainer runbook. `CLAUDE.md` gains a
  standing rule to append to VERIFICATION.md whenever a phase defers a device check and to keep
  SETUP.md current. Clarifies that widget tests run headless (UI phases partially gated here).
- **Phase 4 ↔ 5 execution-order swap.** Build UI/UX scaffolding (Phase 5) before native input
  handlers (Phase 4): the UI is widget-testable headless and is the scaffold inputs plug into;
  Phase 4 is mostly native. **Phase numbers kept stable** (avoid breaking "Phase 5 bootstrap"
  cross-references); documented as a note in `roadmap.md`.

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

## 2026-06-14 — V1: Project manifest + tool-permission enforcement (§5/§6)

- **Deny-by-default.** `ProjectPermissions.level()` returns `denied` for absent/unknown keys, and
  `ToolPermissionRegistry.evaluate()` denies unknown tools — the safe default for the project-isolation
  invariant. Permission values parse as bool (`granted`/`denied`) or `requires_biometric`.
- **Single source of truth for tool→permission** (the §5 table) in `ToolPermissionRegistry.tools`;
  biometric is forced when either the tool is flagged biometric (e.g. `decode_token`) **or** the
  permission level is `requires_biometric` (e.g. `decode`). This is the enforcement point the Mink
  ToolRegistry dispatch (a later, LLM-runtime phase) will call before executing any tool.
- **Manifest custom-entity seeds kept raw** (`List<Map>`) rather than parsed into
  `CustomEntityDefinition`, because manifests use validators like `luhn_npi` outside the current
  `CustomValidator` set and ids/workspace are assigned at project-creation time. `default_policy`
  bridges to `AnonymizationPolicy` for direct use.
- Pure Dart; the Project-creation flow + Settings UI are UI-phase tasks.

## 2026-06-14 — V1 P8b: CRDT conflict resolution (§9.4)

- **Auto-resolution primitives** match the spec: `lwwWinner` (LWW on scalars, newer `updatedAt` wins,
  ties broken by lexicographically-greater `deviceId` so all replicas converge regardless of merge
  order) and `setUnion` (collection merge). cr-sqlite applies column LWW at runtime; these model the
  same semantics for app-level merges/tests.
- **Hard-conflict detection** is the genuine app-level value: `SyncConflictDetector` flags the §9.4
  case cr-sqlite would silently resolve — two devices independently creating the same custom-entity
  *identity* (`workspace_id, project_id, label`) with diverging definition (regex/validator/operator).
  Same record id ⇒ CRDT handles; identical definition ⇒ benign duplicate; divergent ⇒ surfaced to
  Settings → Sync Conflicts. Pure Dart, fully tested; the conflict-resolution UI is a UI-phase task.

## 2026-06-14 — V1 P8a: sync delta envelope crypto (HIGH-STAKES — fuller logging)

- **Scope.** Only the encryption envelope for CRDT deltas — the headless-testable, security-relevant
  slice of Phase 8. The native transport (cr-sqlite delta generation, BYOC Google Drive, mDNS +
  WebSocket/TLS) is deferred to a device session.
- **Faithful to spec, no new crypto.** §9.1/§9.2 mandate "never sync plaintext" + "AES-GCM-encrypted
  CRDT deltas" under MK-derived transport keys. `SyncEnvelope` uses **AES-256-GCM** (the same blessed
  primitive as the vault) under the existing **`syncKey`** (KeyService HKDF `documink:sync:v1`,
  previously reserved). Reuses the `cryptography` package — no new dependency, no invented scheme.
- **Decisions the spec didn't pin (logged):** (1) wire format `version(1)‖nonce(12)‖ct‖mac(16)` with a
  version byte for forward-compat; (2) **AAD binds `(deltaId, deviceId)`** (0x00-delimited, injective)
  so a delta blob can't be relabelled to another `<ulid>` filename, replayed, or re-attributed to a
  different origin device without failing authentication. This strengthens the no-plaintext-sync
  invariant; it does not weaken any existing one, so proceeding under the autonomy contract (logged
  here + called out in the PR).
- **Payload opacity.** The delta bytes are treated as opaque (cr-sqlite's CBOR delta at runtime); the
  envelope neither parses nor depends on their structure.

## 2026-06-14 — V1 P15a: audit log repository + CSV export

- **Append-only** `record(...)` (plain `insert`, never update/delete) over the existing `audit_log`
  table; `AuditEventType` constants cover the roadmap §15 / schema event set.
- **No raw PII in audit rows** (privacy-invariants #7): the repository stores IDs/token-refs/metadata
  as given; the *caller* keeps plaintext out of `metadata`. Documented on `AuditEntry` (kept the
  contract simple rather than re-scanning every audit write).
- **Query**: newest-first, filter by event type(s) + `[since, until)` time range, `limit`/`offset`
  pagination — matches the Settings → Audit Log UI needs (UI itself is a UI-phase task).
- **CSV export** is a pure static function with RFC-4180 quoting (fields with comma/quote/newline are
  quoted, internal quotes doubled) — testable headless; ships in V1 (Pro-gate flag is V1.1).

## 2026-06-14 — V1 P12c: deterministic memory router (completes Phase 12 active-V1)

- **Deterministic dispatch (no LLM)** per memory.md §4.1: a `switch` over tool names
  (`remember`/`recall_core`/`recall_episodic`/`forget`) → `MemoryRepository`. Mink emits the tool
  call; routing is plain code.
- **Rejected writes surface as failures, not exceptions.** A `MemoryPiiLeakError` from the guard is
  caught and returned as a failed `MemoryToolResult` so Mink can react ("I can't store that as-is").
- **Injectable id/clock.** The router takes an id generator + clock (defaults: time+random id,
  `DateTime.now`) so tests are deterministic. No ULID util existed; a real one can replace the default
  later without API change.
- **Scope param.** `remember` honors `scope: 'global'|'project'` to attach/omit the projectId.

## 2026-06-14 — V1 P12b: MemoryRepository (Core + Episodic, guarded)

- **Active-V1 types only.** Implemented Core + Episodic (memory.md §2.1/§2.2); Knowledge Vault is the
  existing `tokens` table; Semantic/Procedural/Resource are schema-only until V1.2 activation (§2.4-2.6).
- **Every write passes `MemoryWriteGuard.assertNoPlaintext`** before insert (Core scans the `value`;
  Episodic scans `{summary, details}`), so 12a's invariant is enforced at the persistence boundary.
- **Scope-aware recall** (current Project + workspace globals) mirrors the §6.7 isolation pattern used
  for custom entities; Episodic recall adds `since`/`episodeType`/`limit`, newest-first (§2.2).
- Values stored as JSON (`value_json`/`details_json`/`token_refs_json`); domain entries decode them.
  `forget{Core,Episodic}` for deletion. Router (tool-call dispatch) is 12c.

## 2026-06-14 — V1 P12a: Mink memory PII-safe write guard (HIGH-STAKES — fuller logging)

- **The invariant.** memory.md §3 requires raw PII/PHI plaintext to *never* enter memory tables.
  12a implements the §3.3 write-path enforcement: `MemoryWriteGuard.assertNoPlaintext` →
  `MemoryPiiScanner` runs the **shared detection pipeline** over content and rejects any detected PII
  that isn't already a token reference (`MemoryPiiLeakError` with structured violations).
- **Token-ref accounting.** Form A (`{"type":"token_ref",…}` maps) is skipped wholesale; Form B
  (`<<tok_…>>` inline markers) is stripped before scanning. Form C (canonical fingerprint) is a BLOB,
  carries no plaintext, so inherently safe. The scanner walks arbitrary JSON (Map/List/String) and
  reports violations with a JSON-path location.
- **Detection coverage caveat.** The guard is exactly as strong as the registered recognizers. With
  only Tier 1 active (headless), structured PII (SSN/email/phone/CC/MRN/…) is caught; PERSON/ADDRESS
  rely on Tier 2/3 (gated). Once Tier 2 (ML Kit) / Tier 3 (GLiNER) are wired at app bootstrap the same
  guard covers names/addresses with no code change. Logged so this dependency is explicit.
- **Scope.** 12a is the security choke point only. `MemoryRepository` (Core + Episodic active-V1
  tables) and the deterministic recall router are 12b; Semantic/Procedural/Resource are V1.2-activation
  per memory.md §2.

## 2026-06-14 — V1 P6b: ReDoS-safe regex preview sandbox (completes Phase 6)

- **Isolate + kill-on-timeout.** Dart's `RegExp` has no interruptible timeout, so the live preview
  runs the untrusted pattern in a **disposable isolate** (`Isolate.spawn`) and the result future is
  raced against a deadline; on `TimeoutException` the isolate is `kill`ed immediately. This is the
  only robust way to neutralize catastrophic backtracking (ReDoS) without hanging the UI thread.
- **Defense in depth:** the sample is truncated to `maxSampleLength` (default 10k) before matching,
  bounding work regardless of the timeout.
- Result is a typed `RegexPreviewResult` (ok+matches / error+message / timedOut). Tested incl. an
  actual exponential pattern `(a+)+$` that reliably trips the timeout path.

## 2026-06-14 — V1 P6a: custom entity types core

- **Naming.** drift already generates a `CustomEntityType` data class for the table; the domain model
  is `CustomEntityDefinition` to avoid collision (validator/operator as enums, examples as a list;
  the repository maps to/from the string/JSON drift row).
- **Validators.** roadmap §6 specifies `luhn` | `none`; implemented both (blueprint §4 also mentions
  `luhn_npi` — deferred until a concrete NPI rule is needed; `CustomValidator` is extensible).
- **Form validation** also checks that provided **examples match the pattern and pass the validator**
  (catches author mistakes early) — beyond the bare roadmap list.
- **Recognizer priority** default 5 (above raw Tier 1 structured but below contextual tiers); tunable.
  Zero-width matches are skipped (would violate the `DetectedSpan` end>start invariant).
- **ReDoS safety deferred to 6b.** 6a compiles patterns vetted by the validator; the *live preview*
  sandbox with isolate timeout (untrusted pattern × adversarial input) is its own chunk. Pipeline
  execution of stored patterns runs in the detection isolate.

## 2026-06-14 — V1 P9c: profiler persistence + orchestration (completes Phase 9)

- **Persistence shape (decision).** §4.7 lists several `llm_*` `vault_meta` fields. Stored as a
  **single JSON document** under `llm:profiler_state` (one atomic row) rather than one row per field —
  simpler, atomic updates, no partial-write states. The JSON keys keep the spec's `llm_*` names.
- **Native collection deferred.** `DeviceSignalCollector` is an interface; the Android
  (ActivityManager/StatFs/…) and Windows (GlobalMemoryStatusEx/DXGI/…) adapters are platform code
  wired at Phase-5 bootstrap (same pattern as the ML Kit Tier 2 adapter). `deviceSignalCollectorProvider`
  throws until overridden, so the pure core stays headless-testable (fake collector in tests).
- **`ProfilerService`** takes the **already-verified** manifest (9b) as a parameter — it never parses
  raw manifest bytes itself; selection + persistence only.
- **User preference ±1 tier shift** (desktop onboarding, §4.7) is **persisted** here but applied in the
  onboarding UI (Phase 5); 9c keeps to selection + persistence.

## 2026-06-14 — V1 P9b: Ed25519-signed manifest verification (HIGH-STAKES — fuller logging)

- **Signing scheme (decision).** The blueprint sketch shows a `signature` field *inside* the manifest
  JSON, which would require canonical JSON re-serialization to verify (fragile). Instead the signed
  artifact (`manifest.signed.json`) embeds the manifest **body as an exact string** and the Ed25519
  signature covers that string's UTF-8 bytes. Verification is byte-exact and serialization-independent.
  Logged as a deviation from the §4.7 sketch (the security property is identical/stronger).
- **Pinned public key.** `ManifestVerifier` verifies against a **pinned** key (constant in code),
  ignoring any key embedded in the file — otherwise an attacker could swap both. On any failure
  (tampered body/signature, wrong key, bad alg, unparseable) it **throws and never returns an
  unverified manifest** (§4.7/§6.4: "never falls back to unsigned"). Tests cover all five rejection
  paths incl. a body forged under a different key.
- **Dev/review key.** The committed key is a **development** Ed25519 key (deterministic from a fixed
  seed in `tool/scripts/sign_manifest.dart`, clearly marked DEV-ONLY). The production private key is
  held in external secure key management and never committed; the pinned public key is swapped at
  release (key rotation = app update, models.md §5). The dev private key is NOT committed.
- **Tier 3 unblocked (ADR-022).** The manifest carries `detection_models` (GLiNER PII: bundled
  `tier3_baseline_bundled` + `tier3_upgrade` variants with `min_score` gates) alongside the Tier 4
  `tiers`. This is the data layer the deferred Tier 3 hybrid delivery needs.
- **Dev placeholder SHA-256.** Manifest `sha256` fields are zero placeholders (no multi-GB model
  files downloaded here); CI's `verify-model-hashes` checks `tool/model_hashes.json` (bundled
  models), not this manifest, so placeholders don't break CI. `ModelHashVerifier` is tested against
  real computed hashes. Real hashes are filled when models are actually hosted (models.md §5 step 2).

## 2026-06-13 — V1 P9a: Device Capability Profiler core (HIGH-STAKES phase — fuller logging)

- **Sequencing (user-approved).** With Phase 3 done, the strict next phase (4: input handlers) is
  native camera/OCR/PDF and untestable in this headless sandbox. Maintainer chose "headless-testable
  cores first," so Phase 9's pure-Dart core runs now — it also **unblocks the deferred Tier 3 model
  delivery** (ADR-022). Native/UI phases (4–8) move to a device session.
- **Phase 9 chunking.** 9a = pure-Dart score + selection core (this PR); 9b = Ed25519-signed manifest
  loading + SHA-256 verification (security-critical; unblocks Tier 3); 9c = `vault_meta` persistence
  + providers + native signal-collector interface (gated).
- **Unit system (decision).** Capabilities stored canonically in **bytes**; all conversions use
  **decimal** units (1 GB = 1e9, 1 MB = 1e6) so the §4.7 score formula and the manifest's
  `size_bytes` / `min_ram_mb` share one consistent system. Avoids binary/decimal mix-ups in the
  storage-headroom and RAM gates. (Spec is unit-loose; logged for review.)
- **selectTier** implements §4.7 verbatim: score ≥ `min_score`, hard `requires` gate, and
  `freeStorageBytes ≥ largestVariantBytes × 1.2` (20% headroom); highest non-opt-in tier wins,
  always defaults to the **Balanced** variant, opt-in tiers surfaced separately. Device-agnostic with
  **no upper ceiling** (verified by a synthetic far-future-device fixture).
- **FloorReason** (added beyond the spec's `floorReason` String): a typed diagnosis
  (insufficientScore / insufficientRam / insufficientStorage / noQualifyingTier) against the
  easiest-to-qualify auto tier, to drive the §4.7 floor UX copy. No security surface.
- **No manifest parsing in 9a.** Selection runs on an in-memory `TierCatalog` (built programmatically
  in tests). JSON parsing is deferred to 9b so the app **never acts on an unverified manifest** —
  parsing and Ed25519 verification land together.

## 2026-06-13 — V1 P3c: FF1 format-preserving encryption

- **FF1 only** (NIST SP 800-38G), hand-rolled on pointycastle (MIT) AES per §2.5/§7.1; **FF3/FF3-1
  forbidden** (NIST withdrawal, §15). Implementation **verified against the NIST FF1 sample
  vectors** (AES-128, radix 10, with/without tweak) — committed as KATs. The radix>10 path is
  covered by a round-trip test only (couldn't authoritatively confirm the radix-36 sample's
  tweak/output from memory; radix 10 is what DocuMink uses for digit FPE).
- **Key = vault DEK** (AES-256) — avoids expanding the 1b key hierarchy with a dedicated FPE
  subkey; FF1 with AES-256 is valid. **Tweak = SHA-256(entity_type ‖ 0x00 ‖ workspace_id)** (the
  0x00 separator makes the encoding injective) — realizes §7.1's "entity_type + workspace_id hash".
- **Card keep-last-4**: CREDIT_CARD FPE leaves the last 4 digits clear (§7.1); separators preserved.
  FPE is **stateless + deterministic** (no token row); reversible via `fpeReverse` with the same
  (label, workspaceId, keepClear).
- `AnonymizationService.anonymize` gained an optional `workspaceId` (default '') for the FPE tweak;
  the pipeline supplies the real workspace id. crypto (BSD-3) added for sync SHA-256.

## 2026-06-13 — V1 P3b: reversible operators (Token-Random + inline Encrypt)

- **Async-vs-sync seam.** 3a's `Anonymizer.apply` is sync; reversible ops need async crypto/DB. Kept
  3a's API and added `AnonymizationService` that **precomputes** surrogates (async) into a map, then
  calls `apply` with a sync resolver. No change to the merged 3a.
- **Token-Random** mints `<LABEL_6base62>` (CSPRNG) and encrypts plaintext with **AAD = surrogate**
  via `TokenCrypto`; returns a `TokenRecord` (surrogate, ciphertext, fingerprint) for the pipeline
  to persist as a `tokens` row. **Intra-document dedup** (same plaintext → same surrogate via
  fingerprint match) is the pipeline's job at persistence; this layer mints fresh per call.
- **Encrypt (inline, stateless).** `<ENC:base64(nonce‖ct‖mac)>`, AAD = fixed domain string
  `documink:inline-encrypt:v1`, **no vault row** (§7.1 "stateless reversal"). Reversible whenever the
  vault (DEK) is unlocked.
- **FPE deferred to 3c:** a policy mapping a label to `fpe` throws `UnsupportedError` until FF1 lands
  (no silent mishandling).

## 2026-06-13 — V1 P3a: anonymizer framework + operator output formats

- **Phase 3 chunking.** 3a = operator framework + policy engine + irreversible ops
  (Redact/Mask/Replace); 3b = vault-backed reversible ops (Token-Random + AES-GCM Encrypt, on
  1c's TokenCrypto); 3c = hand-rolled FF1 FPE + NIST SP 800-38G vectors (FF1 only; FF3 forbidden
  per §15/§7.1). Splits the security-sensitive FF1 crypto into its own reviewable PR.
- **Operator output formats (not precisely spec'd for V1 — chosen, refinable):** redact →
  `[REDACTED]`; mask → `•`×len (length-preserving, full mask by default); replace → `<LABEL>`
  (entity-type tag). Constants on `Anonymizer`.
- **Policy as YAML asset** (`assets/policy/default_policy.yaml`, matches §4.6) via the `yaml`
  package (BSD-3); parser takes a string so it's headless-testable, production loads via
  `rootBundle`. `DEFAULT:` key sets the fallback (redact). Overrides layer via `policy.override(...)`.
- **Reversible ops delegated.** `Anonymizer.apply` routes Token-Random/FPE/Encrypt to an injected
  `ReversibleSurrogate`; absent ⇒ `StateError` (3a has no vault). Keeps 3a pure-Dart + testable.

## 2026-06-13 — V1 P2 Tier 3: hybrid detection-model delivery + sequencing (user-confirmed)

Research (knowledgator GLiNER-PII family, Apache-2.0): edge F1 75.5% (~100 MB INT8), small 76.8%,
base 81.0% (UINT8 197 MB / FP16 330 MB), large 83.3%. The model is too big to bundle a high-accuracy
variant within the PRD's ≤250 MB install ceiling (Phase 12 also bundles ~80 MB MiniLM), and 8-bit
GLiNER quantization has a documented accuracy drop.

- **Delivery strategy.** Options: (A) tiered download + degradation; (B) bundle one small INT8;
  (C) hybrid: bundle smallest + optional downloaded base/large upgrade. **Chose C (maintainer).**
  Offline baseline + per-device accuracy; reuses the Phase 9 signed-manifest/download infra.
  Graduated to **ADR-022**; blueprint §4.3, roadmap Phase 2, models.md §3.4 updated.
- **Sequencing.** The downloaded-upgrade path depends on Phase 9 (profiler + manifest + download),
  so **Phase 3 (Anonymizer operators) is done next** and full Tier 3 lands with/after Phase 9.
  **Chose maintainer-confirmed.**
- **Follow-up flagged:** re-evaluate whether the clinical PHI model (`obi/deid_bert_i2b2`, ~110 MB,
  ADR-004) should also be download-on-demand vs bundled (bundling both NER models pressures 250 MB).

## 2026-06-13 — V1 P2e: minSdk 24 → 26 (spec conflict, user-confirmed) ⚠ review

- **Conflict.** blueprint §11 pinned **minSdk 24 (Android 7.0)**, but `com.google.mlkit:
  entity-extraction:16.0.0-beta6` (Tier 2) requires **minSdk 26**; the manifest merger failed the
  release build (caught by `apk-size-check`). Surfaced via deviation-protocol.
- **Options.** (A) raise minSdk to 26; (B) keep 24 + force-merge ML Kit's manifest
  (`tools:overrideLibrary`) and gate Tier 2 to API ≥26 at runtime; (C) drop ML Kit (Tier 2).
- **Choice: A — raise minSdk to 26 (maintainer-confirmed).** Android 8.0 (2017) covers effectively
  all active devices in 2026; (B) adds an override + runtime guard and disables Tier 2 on 24–25;
  (C) loses Tier 2. `android/app/build.gradle.kts` set `minSdk = 26`; blueprint §11 corrected.

## 2026-06-13 — V1 P2e: Tier 2 ML Kit integration

- **Plugin-agnostic seam.** `MlKitEntityRecognizer` consumes an injectable
  `TextAnnotator` over a local `TextAnnotation` type (not the plugin's `EntityAnnotation`), so the
  type→label mapping is fully unit-tested without platform channels. The plugin-coupled adapter
  (`mlkit_annotator.dart`) is device-only and not exercised in headless CI (like the gated
  SQLCipher test).
- **Not added to the default `piiRecognizersProvider`.** Tier 2/3 need native runtimes / a
  downloaded model, so they are composed into the pipeline at **Phase 5 bootstrap** on capable
  devices; the default provider stays pure-Dart and headless-testable. ML Kit model
  download/lifecycle is a bootstrap concern.
- **Type mapping.** email→EMAIL, phone→PHONE, iban→IBAN, paymentCard→CREDIT_CARD, url→URL,
  address→LOCATION, dateTime→DATE; isbn/money/flightNumber/trackingNumber/unknown dropped (not PII).
  Tier 2 priority (20) > Tier 1 (10) so context-aware detections win overlap ties.

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
