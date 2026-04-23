# DocuMink — Roadmap

**Structure:** Milestones → Phases → Tasks
**No calendar dates.** Progression is gated by exit criteria, not timelines.

**Reading this doc:**
- **Milestones** are shippable product versions.
- **Phases** are coherent chunks of work within a milestone, numbered from 1 within each milestone.
- **Tasks** are concrete deliverables with enough detail for an engineer or AI coding agent.
- Exit criteria are what must be true for the milestone to ship.

**Milestone scheme:**
- **V0** — Foundation (pre-release scaffolding)
- **V1** — Android public launch (Mink, Projects, full tier system, all features free)
- **V1.1** — Freemium introduction (minor release extending V1)
- **V1.2** — Iterative post-launch improvements (minor release extending V1)
- **V2** — Windows port (major milestone — new platform)
- **V3** — Expansion + Teams tier (major milestone — multilingual, more formats, LAN dispatch, Teams)
- **V4** — Document platform + thin relay backend (major milestone — new product surface)
- **V5+** — Beyond (iOS/macOS reconsidered, enterprise, collaborative editing)

---

## Milestone V0 — Foundation & scaffolding

**Goal:** project skeleton that compiles, runs, and enforces architectural guardrails. No product features yet.

**Exit criteria:**
- Flutter app launches on Android emulator and physical device.
- CI pipeline green with all guardrails enabled.
- Three-flavor build (dev/staging/prod) works.
- ADRs committed for each major architectural decision.

### Phase 1 — Project setup

- Initialize Flutter project with stable channel, Dart ≥3.5, Flutter ≥3.24.
- Configure flavors: `dev`, `staging`, `prod` with separate application IDs.
- Strict linting (flutter_lints + custom rules).
- Folder structure:
  ```
  lib/
    core/          (shared utilities, types, errors)
    features/      (per feature: detection, vault, mink, projects, sync, …)
    services/      (application services)
    data/          (drift schema, repositories)
    ui/            (widgets, screens, theming)
  test/
  integration_test/
  ```
- Set up Riverpod, go_router, drift (code generation working).
- Initial theme (light + dark) and accessibility tokens.

### Phase 2 — CI/CD guardrails

- GitHub Actions workflow:
  - `flutter analyze` — fail on any warning.
  - `dart test` — run all unit tests.
  - APK size check (fail if base >150 MB).
  - License scanner on `pubspec.lock` — fail on deny-listed licenses.
  - Analytics-SDK scanner — fail if banned SDK appears.
  - Model hash verification for bundled ONNX artifacts.
- Pre-commit hooks: `dart format`, `flutter analyze`.
- Internal testing track on Play Console.

### Phase 3 — ADRs

Commit ADRs under `docs/adr/`:

- ADR-001: Flutter as cross-platform framework.
- ADR-002: ONNX Runtime via `flutter_onnxruntime` as primary inference runtime for encoders.
- ADR-003: SQLCipher + drift for vault.
- ADR-004: GLiNER-PII-Edge as primary Tier 3 detection model.
- ADR-005: Argon2id + Keystore/DPAPI for key management.
- ADR-006: FF1 (not FF3) for format-preserving encryption.
- ADR-007: Multi-tenant schema from day one.
- ADR-008: No third-party analytics.
- ADR-009: cr-sqlite for CRDT sync.
- ADR-010: BYOC (Google Drive) + LAN mDNS as V1 sync.
- ADR-011: Device-capability-tiered Tier 4 LLM with Balanced/Specialized variants, signed remote tier catalog, transparent floor UX, opt-in upper tiers, no silent swaps.
- ADR-012: Mink as a single-agent-per-user scoped-context model (not multi-agent).
- ADR-013: Projects as declarative domain-agnostic harnesses delivered via signed remote manifest.
- ADR-014: V4 thin relay backend as DocuMink's first and only hosted component, scoped to encrypted transport for three uses (URL sharing, community templates, same-user WAN inference).
- ADR-015: iOS/macOS deferred until after V4.
- ADR-016: Mink memory architecture — six typed stores adapted from MIRIX taxonomy with single-agent deterministic router (not multi-agent), PII-safe reference model via vault token fingerprints, SQLite + sqlite-vec on-device (not Postgres or specialized databases). Full spec in DocuMink-Memory.md.

---

## Milestone V1 — Public launch (Android)

**Goal:** ship a complete, polished Android app to Google Play Store. English-only, single-user, local-first, fully featured per PRD including Mink, Projects, templates, and the full tier system. Everything free; no paywall.

**Exit criteria:**
- All hero user flows work end-to-end on physical Pixel 6, Pixel 9, and Samsung mid-range devices.
- Detection F1 ≥0.90 on internal test set (1000 labeled docs, Tiers 1–3).
- Base APK ≤150 MB, install size with bundled models ≤250 MB (optional Tier 4 models downloaded post-install).
- Device Capability Profiler works correctly on reference devices and a 2 GB-RAM low-end emulator.
- All auto-recommendable Tier 4 tiers (Minimum, Ultra-light, Light, Standard, Performance) downloadable, verifiable, and runnable on qualifying devices — both Balanced and Specialized variants (where present).
- Floor UX validated on a device below Minimum tier threshold.
- Mink conversational flow works in both global chat and Project-scoped chat.
- Mink's typed memory system ships with Core + Episodic + Knowledge Vault active; Semantic, Procedural, Resource tables schema-ready (activation V1.2).
- PII-safe memory invariant verified: integration tests assert no plaintext PII can be written into memory tables; all memory references PII via HMAC-SHA256 token fingerprints.
- Show/hide-masked rendering works uniformly across documents, chat, and memory views.
- All 8 Verified Project templates work end-to-end with correct permission enforcement.
- All three Project creation paths functional (Template, Upload with domain inference, Blank Wizard).
- Model and template manifests verify Ed25519 signatures on every fetch; tamper simulation blocks as expected.
- Crash-free rate ≥99.5% in internal testing track.
- Third-party security audit passed (key management + vault + sync crypto + manifest signing + model runtime + tool dispatch + Mink permission enforcement).
- Play Store Data Safety form completed; privacy policy live at documink.ai/privacy.
- Accessibility audit passed (TalkBack-navigable, WCAG 2.1 AA).

### Phase 1 — Core data layer & vault

- Implement drift schema per Blueprint §3 (including Mink and Projects tables).
- Implement `KeyService`:
  - Argon2id derivation.
  - HKDF subkey derivation with domain separation.
  - KEK wrapping via flutter_secure_storage (Keystore).
  - DEK generation, vault_meta storage, retrieval via KEK.
  - StrongBox detection + graceful fallback.
- Implement `VaultService`:
  - Unlock / lock state machine.
  - Session timer with auto-lock.
  - Tokens CRUD with ciphertext + HMAC fingerprint indexing.
- BIP-39 recovery phrase generation, display, verification.
- Unit tests with NIST + known test vectors.

### Phase 2 — Detection pipeline (Tiers 1–3)

- Implement `PiiRecognizer` abstraction.
- Tier 1 recognizers (Blueprint §4.2).
- Tier 2: integrate `google_mlkit_entity_extraction`.
- Tier 3: bundle GLiNER-PII-Edge INT8 ONNX, integrate via `flutter_onnxruntime`.
  - `detection_labels.yaml` asset.
  - Chunking with 50-token overlap; cross-chunk dedup.
- Overlap resolver.
- Golden tests with fixture documents.
- Benchmark suite on reference devices.

### Phase 3 — Anonymizer operators

- `AnonymizerService` with operator dispatch.
- Implement all operators: Redact, Mask, Replace, Token-Random, FPE (FF1), Encrypt.
- FF1 implementation verified against NIST test vectors.
- Policy engine:
  - Default policy as asset.
  - Per-workspace overrides in `vault_meta`.
  - Per-document overrides supported.
- Round-trip tests for all reversible operators.

### Phase 4 — Input handlers

- Camera capture flow (permission with rationale, single-page capture, OCR via ML Kit).
- Paste text input (inline highlights, share-sheet intent handler).
- Image import (JPG, PNG, HEIC via system picker).
- PDF import (text-layer extraction + OCR-per-page for scanned).

### Phase 5 — UI / UX (non-chat)

- Home screen with primary actions (Scan, Paste, Import, New Project, Chat with Mink).
- Editor screen with detection sidebar and per-entity operator selection.
- Document preview (original ↔ redacted toggle, biometric-gated reversible entities).
- Vault browser (list of documents with status).
- Settings (policy, auto-lock, biometrics, crash-reports opt-in, custom entity types, AI Model section).
- FLAG_SECURE on vault screens.
- Dark mode.
- i18n scaffolding (English-only in V1, structure ready for V3 multilingual).

### Phase 6 — Custom entity types

- "Add Custom Entity" UI in Settings and inside Projects.
- Form: label, regex, validator (`luhn`, `none`), example strings, default operator.
- Regex sandbox with live preview.
- Persist in `custom_entity_types`; Project-scoped when created in a Project.
- Integrate into detection pipeline (Tier 1 alongside built-ins).

### Phase 7 — Export

- Redacted image export (PNG, JPG).
- Redacted PDF export (preserve text layer if present; rasterize otherwise).
- Text export (plain `.txt` + JSON with entity metadata).
- Share via system share sheet; save to gallery / Files.

### Phase 8 — Sync (BYOC + LAN)

- BYOC Google Drive:
  - OAuth via `google_sign_in` with `appDataFolder` scope.
  - Vault push/pull with encrypted delta blobs.
  - CRDT merge via cr-sqlite.
  - Background sync on foreground-after-gap heuristic.
- LAN sync:
  - mDNS advertising and discovery.
  - QR-code pairing with rotating transport key.
  - TLS-pinned WebSocket transport.
  - Authenticated CRDT delta exchange.
- Second-device onboarding flow with QR scan.

### Phase 9 — Device Capability Profiler + signed model manifest

- **Profiler service** (Blueprint §4.7):
  - `DeviceCapabilities` data class — full signal set.
  - Android platform channel implementations (Java/Kotlin). Windows stubbed for V2.
  - `computeScore()` pure-Dart function.
  - `selectTier()` pure-Dart using capability score + remote catalog (not hard-coded).
  - Unit tests: floor, Minimum, Ultra-light, Standard, flagship, synthetic future-device fixtures.
- **Signed model manifest:**
  - Ed25519 signing infrastructure; public key pinned in binary.
  - `manifest.json` hosted at `documink.ai/models/manifest.json` per Blueprint §4.7 spec with nested Balanced/Specialized variants per tier.
  - Manifest fetcher with signature verification.
  - Weekly refresh with exponential backoff.
  - Verification failure blocks update.
- **Common `LlmBackend` interface:**
  - Abstraction over `flutter_gemma` (LiteRT-LM), `fllama` (GGUF), `google_mlkit_genai_prompt` (Gemini Nano).
  - Uniform `generate(prompt, tools, context) → StreamingResponse` entry point.

### Phase 10 — Tier 4 model implementations (all auto-recommendable tiers, both variants)

- **Minimum** (single option): SmolLM2-360M-Instruct int4 GGUF via `fllama`.
- **Ultra-light:** Balanced: Qwen 3.5-0.8B int4 GGUF (`fllama`). Specialized: Qwen 2.5-0.5B int4 GGUF (`fllama`).
- **Light:** Balanced: Qwen 3.5-2B int4 GGUF (`fllama`). Specialized: SmolLM3-3B int4 GGUF (`fllama`).
- **Standard:** Balanced: Gemma 4 E2B `.task` (`flutter_gemma`). Specialized: Qwen 3.5-4B int4 GGUF (`fllama`).
- **Performance:** Balanced: Gemma 4 E4B `.task` (`flutter_gemma`). Specialized: Qwen 3.5-9B int4 GGUF (`fllama`).
- **System-provided (Android):** Gemini Nano via `google_mlkit_genai_prompt`. Runtime detection with graceful degradation.
- **Opt-in tiers declared in manifest but not auto-recommended:**
  - Professional: Gemma 4 26B A4B MoE (Balanced), Phi-4 14B (Specialized). Android stub only; active on Windows V2.
  - Workstation: Gemma 4 31B (Balanced), Qwen 3.6-27B (Specialized). Android stub only; active on Windows V2.
- **System-provided (Windows)** stubbed for V2 — Phi Silica passthrough.
- **Play Asset Delivery configuration:**
  - Per-variant asset packs.
  - Standard-tier Balanced as install-time pack (skippable).
  - Others on-demand.
  - SHA-256 verification; resume support.
- **Benchmark suite:**
  - Latency p50/p95 per model on Pixel 6, Pixel 9, Galaxy A-series, 3 GB emulator, 2 GB emulator.
  - F1 accuracy on PII disambiguation held-out set.
  - CI gate: F1 drop >2 points OR latency +30% blocks release.

### Phase 11 — Tier 4 UX (profiler recommendations, Settings, floor UX)

- **Onboarding Tier 4 decision screen:**
  - "Meet Mink" intro + recommended tier with Balanced variant (size, speed category).
  - One-tap "Accept and download."
  - "Show options" reveals Specialized + other qualifying tiers + opt-in tiers with size warnings.
  - Explicit "Skip" → Mink in constrained informational mode.
  - Desktop preference question (stubbed for V2 Windows port).
- **Settings → AI Model:**
  - Current tier + variant with model name, size, last-profiled timestamp, device score.
  - Variant toggle (Balanced ↔ Specialized) with benefit label.
  - Tier override dropdown (qualifying tiers only).
  - "Re-check my device" button.
  - "Remove downloaded model" action.
  - "Show available opt-in tiers" with size warnings.
- **Floor UX (below Minimum threshold):**
  - Transparent explanation on onboarding.
  - Settings shows what works, what's disabled.
  - Tier-4-dependent UI visibly disabled (not hidden) with tooltips.
  - Mink UI replaced with informational screen in this state.
  - "Re-check my device" available for recovery.
  - Accessibility: disabled states announced by TalkBack.
- **No-silent-swap enforcement:**
  - Tier changes, variant switches, model installs/uninstalls, and version updates all write audit_log entries.
  - Version updates prompt with before/after comparison.

### Phase 12 — Mink conversational layer + typed memory system

- **`MinkService`** — session management, context assembly, `LlmBackend` invocation, tool-call dispatch.
- **`ToolRegistry`** with V1 tool catalog (Blueprint §5.4):
  - `detect_pii`, `anonymize_document`, `decode_token` (biometric-gated), `search_documents`, `list_entities`, `summarize_document`, `rewrite_content`, `expand_content`, `export_document`, `create_custom_entity`, `modify_policy`.
  - Memory tools: `recall_core(key)`, `recall_episodic(time_range, project_id?)`, `remember(type, value, scope)`, `forget(memory_id)`.
  - Each tool declares input/output schema, required permissions, biometric requirement.
- **`ContextAssembler`** — builds LLM input with system prompt + relevant memory slices + conversation history + tool descriptions + consent-gated document snippets (see DocuMink-Memory.md §5 for the deterministic router logic).
- **Typed memory stores — V1 active subset:**
  - **Core Memory** — stable preferences and identity; written explicitly via `remember` or inferred from user statements.
  - **Episodic Memory** — automatic time-stamped summaries after user actions (scan, redaction, chat, export); tier-scaled update behavior per DocuMink-Memory.md §7.
  - **Knowledge Vault** — already implemented as the `tokens` table; memory layer references it via HMAC-SHA256 fingerprints.
  - Semantic, Procedural, and Resource Memory — **schema shipped in V1, active in V1.2**. Tables created and sync-ready so V1 users accumulate no data loss when those stores activate later.
- **Embedding infrastructure:**
  - Bundle `all-MiniLM-L6-v2` INT8 ONNX (~80 MB).
  - Initialize `sqlite-vec` extension, create `mink_embeddings` virtual table.
  - `EmbeddingService` with `embed(text) → vector` API.
  - V1 usage: compute embeddings for Core and Episodic entries to support semantic retrieval within those types.
- **PII-safe memory enforcement:**
  - All memory write paths route through `MemoryRepository.assertNoPlaintext(value)` which scans incoming content for detected PII and rejects writes that contain unreferenced plaintext — forces conversion to token refs first.
  - Integration test: attempt to write raw PII into each memory table; assert failure with structured error.
- **Tool dispatch flow:**
  - Parse LLM output for structured tool calls.
  - Permission check against active Project manifest → transparent denial with explanation if not permitted.
  - Biometric gate if required.
  - Execute and return structured result.
  - Write audit_log entry for every tool call (including denials and memory writes).
- **Chat UI:**
  - Session list (grouped by Project, plus global chats).
  - Streaming response rendering.
  - Tool calls rendered inline with explanation ("Mink ran `search_documents` and found 3 results").
  - Model indicator (shows which Tier 4 model is running Mink).
  - **Token-ref rendering:** chat messages containing token references render as masked by default; single "reveal" toggle per view with session-scoped state.
- **Mink Memory UI (Settings → Mink Memory):**
  - Memory grouped by type (Core, Episodic). V1.2 adds Semantic, Procedural, Resource sections.
  - Each entry shows provenance ("You told me" / "Inferred from conversation" / "Observed from action").
  - Per-entry edit and delete.
  - Per-Project memory vs global memory clearly separated in the view.
  - Export all memory as structured JSON.
  - "Forget everything about [topic]" action that finds and removes all related entries across types.
- **Tier-dependent capability indicators:**
  - "Lightweight mode" pill on Ultra-light/Light tiers.
  - "Minimum mode" pill on Minimum tier.
  - "Mink unavailable" informational screen when below floor.
- **Show/hide-masked global control:**
  - Settings toggle for default behavior (start masked vs. start revealed when authenticated).
  - Per-view override with session-scoped state per DocuMink-Memory.md §8.

### Phase 13 — Proactive suggestions (V1 scoped)

- `ProactiveSuggester` hooks into:
  - Post-scan completion.
  - Post-detection completion on pasted text.
  - Post-redaction application.
- Targeted prompt to LLM asking "is there a valuable follow-up suggestion for what just happened?"
- Suggestion card rendered in-context (never push notification).
- Dismissible; offers the action as one-tap.
- Settings toggle to disable proactive suggestions entirely.
- Audit-logged when offered and when acted upon.
- No background processing — only triggers during active use.

### Phase 14 — Projects & templates

- **Project schema** per Blueprint §3 and §6.
- **`ProjectService`** — CRUD with manifest versioning, isolation enforcement (`workspace_id` / `project_id` filtering in every query).
- **`TemplateService`** — fetches signed templates manifest from `documink.ai/templates/manifest.json`, verifies Ed25519, caches with offline fallback.
- **V1 Verified templates** (8 shipped):
  - personal, medical, legal, tax, research, creative, engineering, blank.
  - Each with reviewed custom entity types, default policy, tool permissions, Mink persona.
- **Creation paths:**
  - Template picker UI with preview.
  - Blank Wizard with 4–5 questions.
  - Upload flow with `DomainInferenceService`:
    - On Light+ tier: reads first 1–2 pages of uploaded docs via LlmBackend, emits structured suggestion.
    - Strong/weak/no-match branches per Blueprint §6.2.
    - "AI-scaffolded" badge on generated templates.
    - Offer to save as personal template.
    - On Ultra-light/Minimum: gracefully falls back to template picker with explanation.
- **Project UI:**
  - Project list with thumbnails and metadata.
  - Project detail view (documents, chat sessions, settings).
  - Project settings: permission manifest editor, policy editor, custom entity types, Mink persona adjustments.
- **Personal templates:**
  - Saved AI-scaffolded / customized projects surface as "Yours" in template picker.
  - Synced via CRDT.

### Phase 15 — Audit log & transparency

- Record every decode, export, sync push/pull, vault unlock, failed biometric, Mink tool call (including denials), proactive suggestion offered/dismissed/actioned, tier change, variant switch, model install/uninstall, manifest version update, project created/modified/archived.
- UI: Settings → Audit Log (paginated, filterable by event type and time range).
- CSV export (shipped in V1 with internal flag for Pro-gate activation in V1.1).

### Phase 16 — Accessibility & polish

- TalkBack passthrough on every screen.
- Dynamic type tested to 200%.
- Color contrast verified (4.5:1 text, 3:1 large).
- Touch target audit (≥48dp).
- Empty, error, loading states for all screens.
- Micro-interactions and animations.

### Phase 17 — Launch prep

- Third-party security audit (scope: key management, vault, sync crypto, manifest signing, Mink tool dispatch, Project isolation, model runtime sandboxing).
- Privacy policy drafted, hosted at documink.ai/privacy.
- Data Safety form completed.
- Play Store listing: screenshots, feature graphic, description (privacy posture + Mink + Projects + tier system).
- Regression suite on all Tier 4 models on reference devices.
- Internal testing track → closed alpha → open beta.
- Bug triage and final polish.
- Production release to Play Store.

---

## Milestone V1.1 — Freemium introduction

**Goal:** introduce Pro tier without disrupting existing free users.

**Exit criteria:**
- Subscription flow works with Play Billing.
- Pro-gated features functional and clearly marked.
- Free users retain all V1 capabilities.
- Restore purchase works across reinstalls.

### Phase 1 — Billing integration

- Integrate `purchases_flutter` (RevenueCat; free tier + cross-store ready for future Windows/iOS).
- Configure products in Play Console: monthly + annual Pro.
- Subscription state management with on-device cache + RevenueCat validation.

### Phase 2 — Gate Pro features

- In `FeatureFlagService`:
  - Audit log export → Pro.
  - Batch processing → Pro (feature implementation in V1.2).
  - Advanced export formats → Pro.
  - Chat history export → Pro.
  - Cross-project search unlimited → Pro.
- UI: Pro upsell modal with feature comparison.
- Pro badge in profile/Settings.

### Phase 3 — Communication

- In-app announcement to existing free users: "everything you use today stays free forever."
- Update Play Store listing.
- Privacy policy update (billing data processed by Play Billing; we never see card details).

---

## Milestone V1.2 — Iterative improvements + full memory activation

**Goal:** address early user feedback, add Pro depth, activate the remaining three memory types (Semantic, Procedural, Resource) now that Mink's V1 usage patterns provide grounded data on what users actually need from memory.

**Exit criteria:**
- Top-10 reported issues triaged and resolved.
- Batch processing shipped (Pro-gated).
- Advanced export formats shipped.
- Semantic, Procedural, and Resource Memory active and populated from user activity.
- Memory UI fully exposes all six types with inspect/edit/delete controls per DocuMink-Memory.md §8.

### Phase 1 — Feedback response

- Triage Play reviews, direct feedback, Sentry crash clusters.
- Fix top crashes and UX friction.
- Tune profiler scoring based on aggregate tier-selection telemetry from opt-in crash reports (no PII).

### Phase 2 — Batch processing (Pro)

- Multi-file selection from Files app.
- Apply policy to all; produce redacted outputs in batch.
- Per-file progress UI.

### Phase 3 — Advanced export formats (Pro)

- Watermarked PDF ("Redacted by DocuMink").
- Side-by-side diff PDF.
- Audit report bundled with export.

### Phase 4 — Semantic Memory activation

- Activate `mink_semantic_memory` and `mink_semantic_relationships` populations from document processing and chat activity.
- Semantic entity resolution via HMAC-SHA256 fingerprint match against `tokens` table — no plaintext ever enters memory rows.
- Hierarchical relationship graph (parent/child trees via recursive CTEs).
- Vector embedding for each semantic entity; integrate with `sqlite-vec` for similarity retrieval.
- `recall_semantic(entity_type?, descriptor?, related_to?)` tool exposed to Mink.
- Conservative rule: semantic memory only tracks entities with an existing vault token — never builds shadow profiles of un-redacted PII.
- Memory visualization UI: tree view per DocuMink-Memory.md §8.

### Phase 5 — Procedural Memory activation

- Observe user actions across sessions (trigger → response patterns).
- Populate `mink_procedural_memory` when a pattern reaches confidence threshold.
- Mink surfaces observed patterns for user confirmation ("I've noticed you FPE EINs on tax returns — want me to do this automatically?").
- User-confirmed patterns become active automations with clear opt-out.
- `recall_procedural(current_action_context)` tool for pattern-aware tool suggestions.

### Phase 6 — Resource Memory activation

- Compute and store embeddings for existing documents.
- Vector similarity search across Project document corpus.
- Upgrade `search_documents` tool to use hybrid BM25 (FTS5) + vector similarity ranking.
- Backfill embeddings for pre-V1.2 documents via background job (with progress indicator; user opt-in; pauses on low battery).

### Phase 7 — V1.2 launch gate

- Regression tests.
- Update Play Store listing.

---

## Milestone V2 — Windows port

**Goal:** DocuMink available on Windows 10/11 with full feature parity, including Phi Silica and opt-in desktop-class tiers.

**Exit criteria:**
- Windows build runs all hero flows.
- Shared ONNX and model manifests work identically across Android + Windows.
- MSIX installer signed and distributable.
- Windows-native UX (keyboard shortcuts, window chrome).
- Phi Silica passthrough functional on Copilot+ PCs.
- Professional and Workstation opt-in tiers downloadable and runnable on Windows.
- Cross-platform sync validated.

### Phase 1 — Platform bring-up

- Enable Windows Flutter target.
- Platform channels for DPAPI, Windows Hello (via `local_auth`), Windows.Media.Ocr.
- ONNX Runtime DirectML EP configured.
- Windows-specific Device Capability Profiler signals: GPU VRAM (DXGI), power plan, CPU cores.

### Phase 2 — Windows UX adaptation

- Desktop layouts (wider screens, side-by-side panes).
- Keyboard shortcuts.
- Menu bar with standard Windows affordances.
- Drag-and-drop file import.
- Desktop "faster vs more accurate" preference question activated.

### Phase 3 — Phi Silica passthrough

- Runtime detection of Copilot+ PC + Windows AI API availability.
- Integrate `LanguageModel` via platform channel.
- Present as "System AI (Phi Silica)" tier — highest-priority auto-recommendation on eligible hardware.
- Graceful degradation to next-best tier if unavailable.

### Phase 4 — Opt-in desktop-class tiers activated

- Professional (Gemma 4 26B A4B MoE Balanced, Phi-4 14B Specialized) downloadable via opt-in.
- Workstation (Gemma 4 31B Balanced, Qwen 3.6-27B Specialized) downloadable via opt-in.
- DirectML inference verified on RTX 4060/4080/4090 class GPUs.
- Thermal behavior verified on sustained inference; throttling detection with user warning.

### Phase 5 — Packaging & distribution

- MSIX build configuration.
- EV code-signing certificate procurement.
- Direct-download installer hosted at documink.ai.
- Optional: Microsoft Store submission.

### Phase 6 — Sync cross-platform validation

- Android ↔ Windows BYOC sync via Google Drive.
- Android ↔ Windows LAN sync (Bonjour on Windows).
- Conflict scenarios verified.

---

## Milestone V3 — Expansion + Teams tier

**Goal:** multilingual detection, more document formats, LAN-dispatched inference, merge Projects, and Teams tier with shared vaults and RBAC. Combines what were separately scoped as V2 expansion and V2.1 Teams in earlier plans.

**Exit criteria:**
- Tier 4 models ship with 10+ languages enabled (Qwen 3.5 already supports 201 natively).
- CSV, DOCX, XLSX supported.
- LAN-dispatched inference functional between paired devices.
- Merge Projects functional with conflict resolution.
- Multiple users share a workspace with RBAC decode permissions.
- Admin audit log aggregates member activity.
- Team tier pricing and feature split finalized and live.

### Phase 1 — Multilingual detection

- Extend `detection_labels.yaml` to cover additional languages.
- Evaluate Qwen 3.5-based Tier 4 outputs for multilingual disambiguation (already native).
- Evaluate GLiNER multilingual variants for Tier 3 (upgrade from GLiNER-PII-Edge if benchmarks justify).
- Ship English + top European languages first (French, German, Spanish, Italian, Dutch, Portuguese).
- Language auto-detection on input.
- Multilingual is Pro-gated (English remains free).

### Phase 2 — CSV / DOCX / XLSX support

- CSV: per-column entity detection, per-column policy.
- DOCX: text extraction, redaction with style preservation (best-effort).
- XLSX: cell-level detection, formula preservation.

### Phase 3 — LAN-dispatched inference

- Same-user devices on the same LAN discover each other via existing sync infrastructure.
- Opt-in "Use a more capable paired device when available" in Settings → AI Model.
- Phone dispatches heavy inference to laptop/desktop; uses existing LAN transport key.
- UI shows "Running on [Device Name]" during dispatched inference.
- One-tap revert to local.
- Graceful fallback to local on network drop or remote unavailability.
- Audit-logged.

### Phase 4 — Additional BYOC providers

- OneDrive via Microsoft Graph.
- Dropbox via Dropbox API v2.
- Provider abstraction with common `CloudProvider` interface.

### Phase 5 — Merge Projects

- Consent flow for both source Projects.
- Conflict resolution for custom entity types, policies, permission manifests.
- New audit log entries linking pre-merge Projects.

### Phase 6 — Teams schema foundation

- Add `workspace_members`, `member_keys` tables.
- Tree-based group key agreement implementation (TreeKEM reference).
- Migration path from single-user to shared workspace.

### Phase 7 — Shared vault protocol

- Group key agreement implementation wired end-to-end.
- Invite flow: admin generates invite; new member accepts on their device.
- Per-member decode permissions (read-only, decode-allowed, policy-editor, admin).

### Phase 8 — Admin features

- Member management UI.
- Aggregate audit log across members.
- Policy enforcement: admin-set policy cannot be overridden by members.
- Compliance report export.

### Phase 9 — Teams billing

- Seat-based Team pricing.
- Admin billing console.

---

## Milestone V4 — Privacy-first document platform + thin relay backend

**Goal:** expand DocuMink from redactor + assistant to full document lifecycle platform. Introduce DocuMink's first (and only) backend — the thin relay serving three uses: URL sharing, community templates, same-user WAN inference.

**Exit criteria:**
- Users can create documents from templates and fill forms.
- E-signature (Simple + Advanced per eIDAS) implemented and legally defensible.
- Encrypted URL-based sharing via thin relay functional.
- Community templates publishable and importable via relay.
- Same-user WAN inference dispatch functional.
- Document lifecycle (create → fill → redact → sign → share) coherent in one unified UX.

### Phase 1 — Document authoring foundation

- Introduce `form_fields` table.
- Template system: curated library + user-created templates (extending Project template infrastructure).
- Rich-text / structured-form editor (scoped: form-filling, not freehand Word processor).

### Phase 2 — Form filling

- Detect form fields in imported PDFs (AcroForm + XFA + AI-assisted for flat PDFs).
- Inline fill with auto-detect PII suggestions from Mink.
- Save filled doc with vault-backed reversibility for PII fields.

### Phase 3 — E-signature

- Simple electronic signature: draw or upload; tamper-evident via document hash.
- Advanced electronic signature: certificate-based (user-provided or DocuMink-generated self-signed with device attestation); PDF embedding per PAdES subset.
- Audit trail of signature events.
- Legal opinion secured for eIDAS and ESIGN/UETA claims.

### Phase 4 — Thin relay backend (minimal, stateless)

DocuMink's first hosted component. Serves three clients described in subsequent phases.

- Endpoints:
  - `POST /blobs` (anonymous encrypted blob upload → ULID + expiry)
  - `GET /blobs/:id` (fetch, rate-limited)
  - `POST /templates` (signed template upload)
  - `GET /templates/:hash` (fetch)
  - `POST /relay/:device_fingerprint` (encrypted inference dispatch, opt-in Pro)
- No user accounts; no persistence beyond expiry; object storage only.
- Infrastructure: Cloudflare Workers + R2 (or AWS Lambda + S3). Costs scale with usage.
- Abuse protection: rate limits, payload size caps, expiry defaults.

### Phase 5 — URL-based encrypted document sharing

- Client flow: encrypt with ephemeral key → upload blob → generate `documink.ai/s/<id>#<key>`.
- Recipient opens URL → app (or lightweight web viewer) downloads blob → decrypts client-side → displays.
- Optional Pro: longer retention, custom expiry, view receipts (convergent-encryption-based).
- Server logs only blob IDs and bytes; key never transmitted.

### Phase 6 — Community templates

- User signs their own template with a per-user keypair.
- Publish via relay → `documink.ai/t/<hash>` URL.
- Recipients import via URL; app shows "Published by [author pubkey fingerprint]" indicator.
- No curated directory in V4; out-of-band discovery (users share URLs via Reddit, email, etc.).
- Verified community templates (DocuMink-reviewed) become a Pro feature in V4+.

### Phase 7 — Same-user WAN inference dispatch

- Each paired device registers with the relay as "available for inference" with a public key fingerprint.
- Phone sends encrypted inference request via relay addressed to laptop's fingerprint.
- Relay forwards opaque ciphertext; laptop decrypts, runs inference locally, encrypts response, sends back via relay.
- UI shows "Running on your laptop at home" with clear "This sends encrypted context through DocuMink's relay" disclosure.
- Opt-in Pro feature given relay bandwidth costs.
- Audit-logged on both source and destination devices.

### Phase 8 — Lightweight web viewer

- Static page hosted at documink.ai/s/<id>.
- WASM-based decryption + redaction-aware display.
- No account required to view.
- CTA: "Install DocuMink to manage your own documents."

### Phase 9 — Unified document lifecycle UX

- Single-screen flow showing document stages (draft → fill → redact → sign → share).
- Cross-stage entity tracking (PII detected at creation time tracked through signing and sharing).
- Receipts and audit continuity across stages.

---

## Milestone V5+ — Beyond

Reserved for:

- **iOS / macOS port** — reconsidered based on V4 outcomes and user demand.
- Collaborative editing (still encrypted, OT/CRDT-based).
- Integrations with EHR / matter management / practice management (still local-first where possible).
- Enterprise SSO and compliance reports.
- Custom model fine-tuning for organization-specific entities.
- Open-source reference implementation of the relay backend for privacy-sensitive orgs to self-host.
- Verified community template directory with moderation infrastructure.

---

## Cross-cutting commitments

These apply to every milestone:

- **No plaintext ever leaves the device.** Any feature proposed that violates this is rejected at design review.
- **No third-party analytics. No tracking. No ads.** Hard product principle.
- **Accessibility is not a phase** — every new screen meets WCAG 2.1 AA at PR time.
- **Security-sensitive changes** (touching key management, vault schema, sync crypto, Mink tool dispatch, Project isolation, manifest signing, relay endpoints) require second-engineer review with the `security-review` label.
- **License compliance** is CI-enforced.
- **Model updates** require regression testing against the held-out benchmark set.
- **No silent changes** to models, tiers, variants, or Project manifests — always prompt, always audit-log.
- **Every Mink tool call** writes to `audit_log`, including permission-denials and biometric-gate outcomes.
- **Project isolation is a hard invariant** — integration tests assert that Project A data is invisible from Project B context on every release.

---

*End of Roadmap.*
