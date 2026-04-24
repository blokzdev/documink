# DocuMink — Product Requirements Document (PRD)

**Scope:** V1 launch, with V2/V3/V4 vision for context
**Owner:** Product
**Audience:** Engineering, design, AI coding agents, stakeholders

---

## 1. Product overview

**DocuMink** is a privacy-first, local-first app for detecting, masking, and reversibly anonymizing sensitive personal and health information (PII/PHI) in documents, images, and text — with a built-in on-device AI assistant named **Mink** that helps users work with their documents conversationally.

Everything runs on-device. All detected sensitive data is stored in an encrypted local vault. Mapping back to original values is gated behind biometric authentication. The app is cross-platform (Flutter), launching Android-first via Google Play Store, followed by Windows. iOS is deferred until after V4.

### 1.1 One-line positioning

> "Privacy-first on-device document redactor with a reversible vault and a local AI assistant. Your data never leaves your device."

### 1.2 Why this exists

Existing PII/PHI redaction tools require cloud uploads, which defeats the purpose for the very users who need redaction most. On-device regex tools lack accuracy. Free mobile redaction apps routinely exfiltrate data to ad networks. AI assistants (Claude, ChatGPT, Gemini) send every message to cloud inference. DocuMink fills both gaps: production-grade redaction accuracy plus a genuinely capable conversational AI assistant — both running entirely on-device, with zero data ever leaving the user's hardware.

---

## 2. Product principles (non-negotiables)

These principles override feature requests. Any proposed change that violates one of these requires explicit sign-off and documentation.

1. **On-device by default.** No cloud inference, no user accounts, no mandatory telemetry.
2. **Reversibility is optional but first-class.** User chooses anonymize (one-way) vs. pseudonymize (reversible) per entity or per policy.
3. **Biometric gate on every decode.** No bypass, no "remember me" beyond session.
4. **Transparent by design.** User can inspect every detection result, audit log entry, and event. Mink never performs actions the user can't see.
5. **Open formats.** All user data exportable in open formats; no lock-in.
6. **Free forever for core use.** Privacy features that matter are never behind a paywall.
7. **Never sync plaintext.** Sync layer only transports encrypted blobs and CRDT deltas.
8. **Scoped consent, always.** Mink reads what the user explicitly grants access to — nothing more.

---

## 3. Target users

### 3.1 Primary personas

- **Clinicians and healthcare workers** preparing redacted clinical notes.
- **Legal professionals** redacting client information from discovery documents, contracts, or exhibits.
- **Privacy-conscious individuals** sharing screenshots, forms, receipts, or documents containing personal info.
- **Journalists and researchers** handling source material that must protect informant identity.

### 3.2 Anti-personas (we are not optimizing for)

- Enterprise compliance officers requiring centralized admin (V5+).
- Bulk-document processors moving thousands of files/day.
- Users whose regulatory context mandates cloud processing (HIPAA covered entities with BAAs).

---

## 4. V1 scope: Features

### 4.1 Input methods

| Input | V1 | Notes |
|---|---|---|
| Camera capture (single page) | ✅ | ML Kit text recognition for OCR |
| Paste text | ✅ | Primary quick-use path |
| Import image (JPG, PNG, HEIC) | ✅ | Via system file picker |
| Import PDF (single and multi-page) | ✅ | Text layer preserved; rasterize if scanned |
| CSV | ❌ | V3 |
| DOCX | ❌ | V3 |
| Batch/multi-file import | ❌ | V3 |

### 4.2 Detection engine

**Four-tier pipeline** run in parallel, results reconciled by overlap resolver:

- **Tier 1 — Regex/checksum recognizers:** emails, phones, SSN, credit card (Luhn), IBAN, MRN patterns, passports, dates, URLs, IPs.
- **Tier 2 — ML Kit Entity Extraction (Android):** addresses, dates/times, flight numbers, tracking numbers, payment cards. Free and bundled with the OS.
- **Tier 3 — GLiNER-PII-Edge INT8 ONNX model:** names, organizations, locations, clinical PHI, and user-defined custom entities.
- **Optional Tier 4 — Device-capability-tiered LLM** (also powers Mink — see §5). Downloads on-demand, auto-selects Balanced variant with Specialized alternative available.

### 4.3 Tier 4 LLM ladder

The app profiles device capability at first use and recommends a tier. Each auto-recommendable tier offers a **Balanced** (default) and **Specialized** (user-switchable) variant:

| Tier | Balanced | Specialized | Specialized benefit |
|---|---|---|---|
| **System-provided** (Android/Windows) | Gemini Nano / Phi Silica | — | Zero-download, OS-managed |
| **Performance** | Gemma 4 E4B (~1.8 GB) | Qwen 3.5-9B (~5 GB) | Desktop-class reasoning on flagships |
| **Standard** *(default for Pixel 6-class)* | Gemma 4 E2B (~1.2 GB) | Qwen 3.5-4B (~2.2 GB) | Stronger multilingual + reasoning |
| **Light** | Qwen 3.5-2B (~1.2 GB) | SmolLM3-3B (~1.8 GB) | Deeper English reasoning |
| **Ultra-light** | Qwen 3.5-0.8B (~600 MB) | Qwen 2.5-0.5B (~330 MB) | Smallest footprint, fastest decode |
| **Minimum** *(floor, single option)* | SmolLM2-360M (~220 MB) | — | Fits any ≥2 GB RAM device |

Advanced users on high-end hardware can opt into **Professional** (Gemma 4 26B A4B MoE or Phi-4 14B, ~9 GB, 12+ GB RAM) or **Workstation** (Gemma 4 31B or Qwen 3.6-27B, ~18 GB, 32+ GB RAM) tiers — never auto-recommended, require explicit consent with disk-space warnings.

All catalog models are **Apache 2.0 or MIT** licensed. Below the Minimum floor (<2 GB RAM), Tier 4 is gracefully disabled with transparent UX; Tiers 1–3 continue unchanged. Mink still appears but operates in a constrained informational mode.

**Full tier catalog** — source URLs, quantization choices, hosting strategy, and licensing bundles — lives in `docs/models.md`.

### 4.4 Custom entity types

Users can define their own recognizers via regex pattern, optional validator (Luhn, etc.), example strings, label, and default operator. Persist in the vault. Unlimited in both free and Pro tiers.

### 4.5 Anonymization operators

| Operator | Description | Reversible? |
|---|---|---|
| Redact | Replace with `[REDACTED]` or black bar | ❌ |
| Mask | Partial (`J*** D***`, `****-****-****-1234`) | ❌ |
| Replace | User-specified fake value | ❌ |
| Tokenize (random) | `<PERSON_a7x9qB>`, vault-backed | ✅ |
| Tokenize (FPE) | Format-preserving via FF1 | ✅ |
| Encrypt | AES-GCM in-place with vault key | ✅ |

### 4.6 Vault & decode

- All reversible operations write to a **SQLCipher-encrypted local vault**.
- Keyed to master passphrase (Argon2id derivation).
- Every decode requires **biometric authentication**.
- **Per-document and per-entity decode** — user can reveal individual entities without decoding the whole document.
- **Audit log** records every decode, export, sync, Mink tool call, and tier change.
- **Session auto-lock** after 60–300s of inactivity.

### 4.7 Export

- Redacted image (PNG, JPG)
- Redacted PDF (text layer preserved if present; rasterized otherwise)
- Text export (plain and JSON with entity metadata)
- Side-by-side preview with per-entity toggle (biometric-gated for reversible entities)

### 4.8 Sync (V1)

- **BYOC to Google Drive** via `appDataFolder` scope (user's quota, not ours).
- **LAN sync via mDNS** — two paired devices on same Wi-Fi exchange encrypted CRDT deltas directly.
- **CRDT layer** (cr-sqlite) for conflict-free multi-device merges.
- **Cross-device onboarding** via QR code exchange.

### 4.9 Analytics & telemetry

- **Zero third-party analytics.** No Firebase Analytics, no Mixpanel, no ad SDKs. CI denies analytics imports.
- **Opt-in anonymous crash reports** via Sentry with aggressive scrubbing (no PII, no content, no paths, no IP).
- **On-device event log** — user-inspectable, exportable.

---

## 5. Meet Mink — the on-device AI assistant

### 5.1 What Mink is

**Mink is a conversational AI assistant that lives entirely on the user's device.** Every user gets their own Mink, synced across their paired devices as encrypted state. When users interact with Mink, they're interacting with the same persona — their Mink — regardless of which device they happen to be on.

Mink is powered by the currently active Tier 4 LLM. On a Pixel 6, Mink runs on Gemma 4 E2B. On a Copilot+ PC, Mink runs on Phi Silica. The **identity** is constant; the **inference model** adapts to the device. This is transparent in the UI — users can see which model is running their Mink at any time.

### 5.2 What Mink can do

**Baseline Mink (V1):**
- Conversational chat — ask questions, discuss ideas, get help (like Claude, ChatGPT, Gemini, but on-device).
- Persistent chat sessions with history, stored encrypted in the vault.
- Tool-call-based interaction with DocuMink features ("Mink, redact this document," "Mink, tokenize all names," "Mink, show me what I anonymized last week").
- Responds only when invoked by the user (reactive by default).

**Reactive proactive suggestions (V1, carefully scoped):**
- After completing an action (e.g., a document scan), Mink may surface a contextual suggestion: *"I noticed this document has 47 instances of 'John Smith' — want me to tokenize them all consistently?"*
- Suggestions appear only in-context, never as push notifications.
- All dismissible; user setting to disable entirely.
- No background processing — Mink runs during active use only.

**Voice, extended multimodal I/O, background agents:** deferred to V3+.

### 5.3 How Mink handles context

Mink's context access is **strictly scoped**:

- **Outside a Project:** Mink sees only what the user types directly into chat. It does not have access to the vault, documents, or any other project's data. This is the casual "ask Mink a quick question" mode.
- **Inside a Project:** Mink's context is scoped to that Project's documents, chat history, and configuration — and only if the user has explicitly granted access at Project creation. See §6.
- **Cross-Project actions** require explicit per-invocation consent.

Mink never reads documents outside the active Project context without explicit user action. Enforced at vault query layer — `workspace_id` filtering prevents cross-Project bleed.

### 5.4 Mink memory

Mink remembers you across sessions and devices. Memory is structured into typed stores — stable preferences, time-stamped activity summaries, entities you've worked with, patterns you follow, documents you've shared, and the Knowledge Vault that already holds your reversibly-anonymized PII. Each type has its own retrieval behavior and privacy posture.

**Critical design property:** Mink's memory never stores raw sensitive data. When Mink remembers something about a person, location, or other PII entity, it stores an encrypted reference that points to the Knowledge Vault — not the value itself. Mink can reason about *"the cardiologist you've been working with in 14 documents"* without ever holding the name in memory; the name stays in the vault, biometric-gated, and appears on screen only when you explicitly reveal it.

**User controls over memory:**
- Settings → Mink Memory shows every stored memory, separated by type (Core, Episodic, Semantic, Procedural).
- Every memory shows its **source** — did you explicitly tell Mink, did Mink infer this from a conversation, or did Mink observe this from your actions?
- Inspect, edit, delete individual memories at any granularity. Delete all memories in one Project without affecting others.
- "Forget this about me" action in chat — Mink confirms and removes.
- Export all memory as structured JSON for portability.

**Show/hide masked data** is a global user control that applies uniformly across documents, chat, and memory views. Default is masked (tokens visible). Tap to reveal decodes ephemerally while you're authenticated; re-masks on session lock or navigation away.

Full memory architecture specification lives in **memory.md**.

### 5.5 Tier-dependent capability

Mink's conversational sophistication scales with the active Tier 4 model. Stated transparently in UI:

- **Performance / Professional / Workstation / System-provided:** full capability — extended reasoning, long context, all tool calls, full memory updates across all six types.
- **Standard:** strong capability — handles most everyday tasks well; full memory updates.
- **Light / Ultra-light:** constrained but useful — shorter context handling, simpler responses, all tool calls work, memory updates scoped (episodic + explicit-statement core memory; semantic via observed fingerprint matches only).
- **Minimum:** minimal — simple Q&A and basic tool invocation only; memory writes only when user explicitly asks Mink to remember something. Explicit UI indicator: "Mink is running in Minimum mode on this device."
- **Below Minimum (no Tier 4):** Mink UI replaced with informational screen explaining what's unavailable and what still works. Core detection (Tiers 1–3) continues unaffected.

### 5.6 What Mink never does

- Sends any user data to any server.
- Speaks on the user's behalf without explicit action.
- Reads documents or projects the user hasn't explicitly granted access to.
- Takes irreversible actions (decode, export, delete) without biometric confirmation at the moment.
- Changes its own tier, variant, or configuration silently.
- **Stores raw PII or PHI in its memory** — always uses vault token references.

---

## 6. Projects — the scoped harness for everything

### 6.1 What a Project is

A Project is a **domain-agnostic scaffold** — a bounded working environment composed at creation time to fit the user's domain. The same underlying machinery (documents, chat, permissions, tools, custom entities, policy, vault namespace) configures itself into meaningfully different experiences based on the Project's composition.

A Tax Documents project, a Medical Records project, and a Novel Draft project are all the same structure with different compositions:

- **Different tools enabled** — Medical grants narrow read/detect/anonymize; Novel grants content-rewrite tools
- **Different policy defaults** — Medical defaults MRN→FPE and PHI→redact; Novel has no PHI policy
- **Different custom entity types** — Tax defines EIN/TIN; Engineering defines commit-hash/ticket-id
- **Different permission manifests** — what Mink can do in this Project
- **Different Mink persona** — conservative in Medical; creative in Novel
- **Different file type expectations**

All composition is **declarative data**, not code. New Project templates are data, not app releases.

### 6.2 Project creation paths

Three paths, all producing the same underlying Project structure:

**1. Start from Template** — the one-tap path. User picks from eight Verified templates (§6.3), reviews the composition preview, creates Project.

**2. Upload Documents** — the AI-scaffolded path. User uploads one or more documents. Mink performs on-device domain inference (Light tier and above) and proposes a scaffold:
- **Strong match:** "This looks like a medical document. I suggest the Medical Records template."
- **Weak match:** shows multiple candidates with a "which matches better?" affordance.
- **No match:** Mink generates a scaffold from scratch, clearly marked "AI-scaffolded — please review," and offers to save it as a reusable personal template.
- On Ultra-light or Minimum tier devices: domain inference unavailable; flow gracefully falls back to template picker or Blank Wizard.

**3. Start Blank** — the guided-wizard path. User answers a few questions (domain, content type, sensitive entities, desired tools) and DocuMink composes a custom Project.

### 6.3 V1 Verified templates (8 shipped)

Each template includes reviewed custom entity types, default policy, tool permissions, and Mink persona:

1. **Personal Documents** — receipts, forms, IDs, utility bills
2. **Medical Records** — clinical notes, insurance forms, prescriptions (flagship PHI; narrow tool permissions)
3. **Legal & Contracts** — agreements, discovery, client correspondence
4. **Tax & Financial** — returns, statements, tax forms
5. **Research & Journalism** — source material, interviews, notes (source-protection focused)
6. **Creative Writing** — drafts, manuscripts, outlines (permissive content tools)
7. **Engineering & Technical** — RFCs, incident reports, code reviews
8. **Blank Project** — escape hatch with guided wizard

Templates are delivered via a **signed remote manifest** (`https://documink.ai/templates/manifest.json`) — Ed25519-signed, verified on every fetch, cached with offline fallback. New Verified templates ship without new app releases.

### 6.4 Project permissions

Every Project has a **permission manifest** declaring what Mink can do in this Project. Examples:

```
Project: Medical Records
  read_documents: true
  detect_pii: true
  anonymize: true
  decode: requires_biometric
  rewrite_content: false       ← Mink refuses rewrites here
  search_web: false             ← Mink never searches anything

Project: Novel Draft
  read_documents: true
  detect_pii: false
  anonymize: false
  rewrite_content: true         ← Mink helps rewrite here
  expand_content: true
```

Permission changes are audit-logged. Mink surfaces denials transparently: *"That tool is disabled for this Project. Edit Project settings if you want to change this."*

### 6.5 Project boundaries

- **Hard isolation.** Data in Project A is invisible to Project B — enforced at vault query layer via `workspace_id` filtering.
- **No implicit cross-Project memory.** Mink's working memory in Project A does not carry into Project B.
- **Global chat exists outside Projects** — casual, unscoped conversations. Mink has no document access in global chat; only sees what the user types.
- **Cross-Project actions** (e.g., "search all projects for X") require explicit per-invocation consent and are audit-logged.

### 6.6 V3+ Project evolution

- **Merge Projects** (V3) — requires careful consent flows for both source Projects.
- **Team-scoped Projects** (V3) — workspace-level permission enforcement for shared vaults.
- **Community templates** (V4, via thin relay backend) — users publish signed Project templates; recipients import via URL. DocuMink hosts signed bytes, doesn't endorse content.

---

## 7. User flows (hero paths)

### 7.1 First-run onboarding

1. Welcome: three slides explaining what DocuMink does and the privacy promise.
2. Master passphrase creation + strength meter + recovery phrase (BIP-39).
3. Biometric enrollment (optional convenience factor).
4. Permissions (camera, photos) with rationale.
5. **Device capability profiling** runs in background.
6. **Tier 4 decision screen:** "Meet Mink — your on-device AI assistant. We recommend [Balanced variant] for your device: [size], [speed category]." Options: Accept, Show options (reveals Specialized + other qualifying tiers + opt-in tiers), Skip (Mink appears in constrained informational mode, Tier 4 not downloaded).
7. Brief home-screen tutorial; dismissible.

### 7.2 Scan & redact a physical document

1. Home → "Scan."
2. Camera captures page.
3. Detection pipeline runs.
4. Preview shows entities highlighted by type.
5. User reviews, accepts/adjusts operators per entity.
6. Apply. Redacted image rendered; reversible entities written to vault.
7. Share, save, or export as PDF. Reverse any entity later via biometric gate.

### 7.3 Start a Project from upload

1. Home → "New Project" → "Upload Documents."
2. Pick one or more files.
3. Mink performs domain inference (if Light tier or above) → proposes Medical Records template with composition preview.
4. User confirms or edits composition; Project created.
5. User explicitly grants Mink access to documents.
6. Project opens — Mink greets user contextually, documents queued for processing.

### 7.4 Chat with Mink inside a Project

1. User opens Tax Documents Project.
2. Mink's context loads — permission manifest, custom entity types, policy, relevant documents (with consent).
3. User types: "Which of these receipts have amounts over $500?"
4. Mink invokes `search_documents` tool scoped to Project → returns matching receipts inline.
5. User follows up: "Mask the vendor names on those."
6. Mink invokes `anonymize` tool → updates documents, writes audit log entries. Reversible via biometric.
7. Every tool invocation appears in the chat transcript with an explanation.

### 7.5 Add a second device

1. Device 1: Settings → "Add device" → generates rotating QR code bound to one-time transport key.
2. Device 2: After passphrase creation → "Link to existing device" → scans QR → authenticated key exchange over LAN.
3. Vault + settings + Projects + chat history + Mink memory sync.

---

## 8. Non-functional requirements

### 8.1 Performance targets (on a mid-range device, e.g., Pixel 6)

| Metric | Target |
|---|---|
| Detection latency (paragraph paste) | <100 ms |
| Detection latency (typical page text) | <300 ms |
| OCR + detection (image) | <2 s |
| Mink first-token latency (Standard tier) | <2 s |
| Mink decode speed (Standard tier) | ≥15 tok/s |
| App cold start | <2 s |
| PDF redaction (10-page doc) | <15 s |

### 8.2 Footprint

- **Base APK:** <150 MB.
- **Install size with core models (Tiers 1–3):** <250 MB.
- **Optional Tier 4 LLM (on-demand):** 0 MB (system-provided) to ~1.8 GB (Performance). Advanced opt-in tiers (Professional, Workstation) up to ~18 GB — never auto-downloaded.
- **Floor behavior:** below ~2 GB RAM / 250 MB free storage, Tier 4 disabled with transparent UX.
- **Vault growth:** ~2 KB per reversible entity; ~1 KB per chat message.

### 8.3 Offline behavior

**100% of detection, anonymization, vault, and Mink functionality works offline.** Sync is optional and async. No feature gated behind connectivity. No license check server.

### 8.4 Accessibility

WCAG 2.1 AA. TalkBack/Narrator compatible. 48dp minimum touch targets. Dynamic type. 4.5:1 contrast.

---

## 9. Compliance posture

### 9.1 Google Play

- Data Safety: "not collected" (core); "optional, not shared" (opt-in crash reports).
- Health Apps declaration: completed; no `android.permission.health.*` scopes.
- AI-Generated Content policy: triggered by Mink; in-app flagging mechanism for reported outputs.
- Foreground Service: N/A (no background inference).

### 9.2 GDPR

- Pseudonymization (not anonymization) when vault maps retained — disclosed in privacy policy.
- DPIA prepared for healthcare-adjacent use.
- Full data export and delete-all functions in-app.
- No controller relationship with users; no processor relationship when BYOC sync is used (we never see ciphertext keys).

### 9.3 HIPAA

- **V1 stance:** NOT claimed as Safe Harbor de-identification in marketing. Positioned as "privacy-preserving redaction."
- Consumer app (HHS FAQ 3013) — not a BA unless distributed for/on behalf of a covered entity.
- V3+ reconsideration after test coverage for 18-identifier detection.

---

## 10. Security posture

### 10.1 Threat model

**Defended against (Motivated tier):** device loss/theft, common forensic tooling, malicious apps reading DocuMink storage, shoulder-surfing, BYOC sync-provider compromise.

**Explicitly out of scope:** nation-state adversaries, chip-level extraction, supply-chain compromise, malicious/rooted OS with active attacker, rubber-hose attacks.

### 10.2 Controls

- AES-256 at rest (SQLCipher).
- Argon2id passphrase derivation (64 MB, t=3, p=4).
- KEK wrapped by Android Keystore (StrongBox where available) / Windows DPAPI.
- Biometric gate on all decode and irreversible Mink actions.
- FLAG_SECURE on vault screens.
- `android:allowBackup="false"`.
- Auto-lock 60–300s.
- Certificate pinning on BYOC connections.

---

## 11. Freemium structure

### 11.1 V1 launch: everything free

No paywall, no account required, no feature gating. Goal: install base and user research.

### 11.2 V1.1+ Pro introduction

| Feature | Free | Pro (~$3–5/mo or ~$30/yr) |
|---|---|---|
| Detection, masking, anonymization | ✅ | ✅ |
| Unlimited local documents | ✅ | ✅ |
| Unlimited devices (BYOC + LAN sync) | ✅ | ✅ |
| Unlimited custom entity types | ✅ | ✅ |
| Mink (chat, Projects, tools) | ✅ | ✅ |
| Unlimited Projects | ✅ | ✅ |
| Shipped Verified templates | ✅ | ✅ |
| AI-scaffolded Projects from upload | ✅ | ✅ |
| Save AI-scaffolded as personal template | ✅ | ✅ |
| Audit log export (CSV, PDF) | ❌ | ✅ |
| Batch processing (multi-document) | ❌ | ✅ |
| Advanced export formats | ❌ | ✅ |
| Multilingual models (V3+) | ❌ | ✅ |
| Priority model updates | ❌ | ✅ |
| Cross-project search | Limited | ✅ |
| Chat history export | ❌ | ✅ |
| **V4+:** Publish community templates | ❌ | ✅ |
| **V4+:** Use verified community templates | ❌ | ✅ |
| **V4+:** WAN inference dispatch | ❌ | ✅ |

### 11.3 V3 Team tier

Introduced with V3 alongside shared vaults and RBAC. Seat-based pricing TBD.

---

## 12. Success metrics

No telemetry, so success is measured via proxies:

**V1 launch (90 days):**
- Install growth (Play Console aggregate)
- 30/90-day retention (Play Console aggregate)
- Crash-free rate ≥99.5%
- Play Store rating ≥4.5 with ≥100 reviews
- Qualitative: reviews mentioning privacy posture and Mink

**V1.1 (freemium launch):**
- Free→Pro conversion rate (target 2–4%)
- Pro retention ≥80% month-over-month after first 3 months

---

## 13. Risks & open questions

- **Detection ceiling on poor-quality inputs** → V3 multilingual, improved OCR.
- **Tier 4 model download UX** → always optional, clear size warnings, one-tap skip.
- **Mink first-chat latency** → Tier 4 models have warmup; show loading state with transparency about what's happening locally.
- **Domain inference misclassification** → conservative thresholds, always human-review before Project commit, AI-scaffolded clearly marked.
- **Keystore/StrongBox fragmentation** → graceful fallback with clear protection-level indicator.
- **App size creep** → enforce <250 MB install-size budget in CI.

---

## 14. What's NOT in V1

- CSV, DOCX, XLSX file types
- Batch/multi-document processing (Pro in V1.1)
- Multilingual detection (English only)
- iOS, macOS (deferred past V4)
- Team/shared vaults (V3+)
- Document creation, form filling, e-signature (V4)
- URL-based document sharing (V4)
- Community templates (V4)
- LAN-dispatched inference (V3)
- WAN-dispatched inference (V4)
- Voice I/O for Mink (V3+)
- Cloud-hosted inference (never)
- Web version (never in V1–V4)

---

## 15. V2/V3/V4 vision (context only)

**V2:** Windows port via Flutter desktop target, Phi Silica passthrough on Copilot+ PCs, opt-in desktop-class tiers (Professional, Workstation) activated, cross-platform sync validated.

**V3:** multilingual models (Qwen 3.5's native 201 languages unlock this cleanly), CSV/DOCX/XLSX, LAN-dispatched inference across paired devices, merge Projects, **and Teams tier** — shared vaults, RBAC, admin audit, seat-based billing.

**V4:** evolution to full privacy-preserving document platform:
- Document creation, form filling, e-signature (Simple + Advanced per eIDAS)
- Encrypted URL-based sharing via thin relay backend
- **Community templates** published through the same relay
- **WAN-dispatched inference** — same-user devices coordinate through the relay with E2E encryption between the user's own devices
- DocuMink's first (and only) backend component; minimal, stateless, content-addressed, no user accounts

**Post-V4:** reconsider iOS/macOS based on user demand and V4 outcomes.

---

*End of PRD.*
