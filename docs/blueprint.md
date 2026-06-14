# DocuMink — Technical Blueprint

**Scope:** V1 technical architecture, with forward compatibility notes for V2/V3/V4
**Audience:** Engineering, AI coding agents

This document is the technical source of truth. If the PRD and Blueprint disagree, the PRD defines what we're building; the Blueprint defines how.

---

## 1. System architecture overview

DocuMink is a Flutter app with a four-tier detection pipeline, a SQLCipher-backed reversible tokenization vault, a device-capability-tiered on-device LLM layer powering the Mink assistant, a Project system providing scoped harnesses for domain-specific work, and a BYOC/LAN sync layer. All inference is on-device. All sensitive data at rest is encrypted. All keys are managed by the platform Keystore/DPAPI.

### 1.1 High-level component diagram

```
┌───────────────────────────────────────────────────────────────────┐
│                          Flutter UI (Dart)                         │
│  Home · Camera · Editor · Vault · Projects · Mink Chat             │
│  Settings · Onboarding · Sync · Template Picker · Domain Inference │
└────────────────────────────────┬──────────────────────────────────┘
                                 │
┌────────────────────────────────▼──────────────────────────────────┐
│                     Application Services (Dart)                    │
│  DocumentService · DetectionService · AnonymizerService            │
│  VaultService · KeyService · SyncService · AuditService            │
│  ProjectService · TemplateService · MinkService · ToolRegistry     │
│  DeviceCapabilityProfiler · LlmService · DomainInferenceService    │
└────────────────────────────────┬──────────────────────────────────┘
                                 │
    ┌────────────────────────────┼──────────────────────────────────┐
    │                            │                                  │
┌───▼──────┐  ┌──────────────────▼────────┐  ┌────────┐  ┌──────────▼───┐
│Detection │  │   Mink Assistant Layer    │  │Project │  │    Vault     │
│Pipeline  │  │   (LLM + Tool Registry)   │  │Harness │  │(drift+SQLCph)│
├──────────┤  ├───────────────────────────┤  ├────────┤  ├──────────────┤
│T1 Regex  │  │ LlmBackend abstraction    │  │Manifest│  │workspaces    │
│T2 MLKit  │  │  ├─ flutter_gemma         │  │Perms   │  │projects      │
│T3 GLiNER │  │  ├─ fllama (GGUF)         │  │Tools   │  │documents     │
│T4 LLM    │◄─┤  ├─ ML Kit GenAI (Nano)   │◄─┤Policy  │  │entities      │
│          │  │  └─ Windows AI (Silica)   │  │Templates│ │tokens        │
│          │  │                           │  │(V1 ship)│ │chat_sessions │
│          │  │ Tool dispatch + consent   │  │Signed   │ │chat_messages │
│          │  │ Proactive suggester (V1)  │  │manifest │ │mink_memory   │
└──────────┘  └───────────────────────────┘  └─────────┘ │custom_ents   │
       │                    │                            │audit_log     │
       │                    │                            │vault_meta    │
       │                    ▼                            │sync_state    │
       │     ┌─────────────────────────┐                 └──────────────┘
       │     │ Device Capability       │                        │
       │     │ Profiler + signed model │                        │
       │     │ manifest (remote)       │                        │
       │     └─────────────────────────┘                        │
       │                                                        │
       ▼                                                        ▼
┌──────────────────────────────────────┐  ┌────────────────────────────┐
│ ONNX Runtime (flutter_onnxruntime)   │  │ KeyService                 │
│ LiteRT-LM (via flutter_gemma)        │  │  Argon2id → MK → KEK/DEK   │
│ llama.cpp (via fllama)               │  │  Keystore/DPAPI wrapped    │
└──────────────────────────────────────┘  └────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ Sync Layer (BYOC Google Drive + LAN mDNS; V1)                       │
│   + LAN-dispatched inference (V3)                                   │
│   + V4 thin relay: URL sharing, community templates, WAN dispatch   │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 Platform targets

| Platform | V1 | V2 | V3 | V4 | Beyond |
|---|---|---|---|---|---|
| Android (7+, API 24+) | ✅ | | | | |
| Windows 10/11 | | ✅ | | | |
| iOS / macOS | | | | | Reconsidered post-V4 |
| Linux | | | | | Possible |
| Web | Never in V1–V4 | | | | |

---

## 2. Technology stack

### 2.1 Core framework

| Layer | Choice | Version | License |
|---|---|---|---|
| App framework | Flutter | ≥3.38 | BSD-3 |
| Language | Dart | ≥3.10 | BSD-3 |
| State management | Riverpod | ≥2.5 | MIT |
| Routing | go_router | ≥14 | BSD-3 |
| Local KV (settings) | shared_preferences | latest | BSD-3 |
| Secure key store | flutter_secure_storage | ≥10 | BSD-3 |
| Passphrase KDF | argon2 | latest | Apache-2.0 |
| Crypto primitives (HKDF/AES-GCM) | cryptography | latest | Apache-2.0 |

**Package entry-points per phase.** Packages enter `pubspec.yaml` when used, not speculatively:

- `flutter_secure_storage`, `argon2`, `cryptography` — enter at V1 Phase 1b (key hierarchy);
  `sqlite3` with `source: sqlite3mc` (vault) entered at Phase 1a (ADR-019).
- `shared_preferences` — enters at V1 Phase 5 (settings persistence).
- ML / LLM packages (`flutter_onnxruntime`, `flutter_gemma`, `fllama`, `google_mlkit_*`) — enter at the V1 phases that integrate them (Phases 2, 9, 10).

### 2.2 ML / detection runtimes

| Layer | Choice | License | Notes |
|---|---|---|---|
| ONNX inference | flutter_onnxruntime | MIT | 16 KB page-size compliant for Play |
| OCR | google_mlkit_text_recognition | Apache 2.0 | Android |
| Structured PII (Android) | google_mlkit_entity_extraction | Apache 2.0 | Phones, addresses, cards |
| LLM: LiteRT-LM path | flutter_gemma | Apache 2.0 | For `.task` format models (Gemma 4 family) |
| LLM: GGUF path | fllama (Telosnex) | MIT | For GGUF models (Qwen, SmolLM family) |
| LLM: system-provided (Android) | google_mlkit_genai_prompt | Apache 2.0 | Gemini Nano passthrough |
| LLM: system-provided (Windows) | Windows AI APIs via platform channel | — | Phi Silica passthrough |
| Embedding model (bundled, always) | `all-MiniLM-L6-v2` INT8 ONNX | Apache 2.0 | ~80 MB; powers Mink memory vector search and Resource Memory retrieval; NOT tier-dependent (needed at every tier for memory to function) |

### 2.3 Detection models (V1)

> **See `docs/models.md` for the authoritative Tier 4 catalog** — source URLs, SHA-256 hashes (filled in at manifest authoring time), quantization choices per model family, hosting strategy (Play Asset Delivery on Android V1, HuggingFace on Windows V2), and licensing bundles. This section summarizes; models.md is the detail source.

**Tier 3 (always-on, bundled in base APK):**

| Purpose | Model | HF ID | License | Size (INT8) |
|---|---|---|---|---|
| Primary PII NER | GLiNER-PII-Edge | `knowledgator/gliner-pii-edge-v1.0` | Apache 2.0 | ~100 MB |
| Clinical PHI | OBI clinical de-id BERT | `obi/deid_bert_i2b2` | MIT | ~110 MB |

**Tier 4 (optional, downloaded on-demand; Balanced auto-selected; Specialized user-switchable):**

*Auto-recommendable tiers (profiler picks highest qualifying tier → Balanced variant):*

| Tier | Variant | Model | HF ID / Source | License | Int4 size | Min RAM | Specialized benefit |
|---|---|---|---|---|---|---|---|
| **System-provided (Android)** | — | Gemini Nano via ML Kit GenAI | System | — | 0 MB | — | Zero-download, OS-managed (Pixel 9+, Galaxy S24/S25) |
| **System-provided (Windows)** | — | Phi Silica via Windows AI APIs | System | — | 0 MB | — | Zero-download, OS-managed (Copilot+ PCs) |
| **Performance** | Balanced | Gemma 4 E4B | `google/gemma-4-E4B` | Apache 2.0 | ~1.5–2 GB | 6 GB | — |
| **Performance** | Specialized | Qwen 3.5-9B Instruct | `Qwen/Qwen3.5-9B-Instruct` | Apache 2.0 | ~5 GB | 6 GB | Desktop-class reasoning; 201 languages |
| **Standard** *(default for Pixel 6-class)* | Balanced | Gemma 4 E2B | `google/gemma-4-E2B` | Apache 2.0 | ~800 MB–1.5 GB | 4 GB | — |
| **Standard** | Specialized | Qwen 3.5-4B Instruct | `Qwen/Qwen3.5-4B-Instruct` | Apache 2.0 | ~2.2 GB | 4 GB | Stronger multilingual + reasoning |
| **Light** | Balanced | Qwen 3.5-2B Instruct | `Qwen/Qwen3.5-2B-Instruct` | Apache 2.0 | ~1.2 GB | 4 GB | — |
| **Light** | Specialized | SmolLM3-3B | `HuggingFaceTB/SmolLM3-3B` | Apache 2.0 | ~1.8 GB | 4 GB | Deeper English reasoning; open training recipe |
| **Ultra-light** | Balanced | Qwen 3.5-0.8B Instruct | `Qwen/Qwen3.5-0.8B-Instruct` | Apache 2.0 | ~500–700 MB | 3 GB | — |
| **Ultra-light** | Specialized | Qwen 2.5-0.5B Instruct | `Qwen/Qwen2.5-0.5B-Instruct` | Apache 2.0 | ~330 MB | 3 GB | Smallest footprint; fastest decode |
| **Minimum** *(floor, single option)* | — | SmolLM2-360M Instruct | `HuggingFaceTB/SmolLM2-360M-Instruct` | Apache 2.0 | ~220 MB | 2 GB | Fits anywhere ≥2 GB RAM |
| **None (floor)** | — | — | — | — | 0 MB | <2 GB | Tier 4 disabled with explicit UX; Tiers 1–3 unaffected |

*Opt-in only tiers (never auto-recommended):*

| Tier | Variant | Model | License | Int4 size | Min RAM | Specialized benefit |
|---|---|---|---|---|---|---|
| **Professional** | Balanced | Gemma 4 26B A4B MoE | Apache 2.0 | ~9 GB | 12 GB | — |
| **Professional** | Specialized | Phi-4 14B | MIT | ~8.5 GB | 12 GB | Dense architecture; English technical/medical |
| **Workstation** | Balanced | Gemma 4 31B dense | Apache 2.0 | ~18 GB | 32 GB | — |
| **Workstation** | Specialized | Qwen 3.6-27B dense | Apache 2.0 | ~16 GB | 32 GB | Latest Alibaba reasoning flagship; complex multilingual |

**Notes:**
- All catalog models Apache 2.0 or MIT — no Gemma Terms or custom-terms exceptions (Gemma 4 shipped under Apache 2.0 on 2026-04-02).
- **Balanced is auto-selected**; user switches to Specialized via onboarding "Show options" or Settings.
- **Minimum and System-provided tiers are single-option** (no meaningful second axis).
- **Compact tier removed** from final design — Ultra-light Balanced covers 3 GB RAM devices adequately.
- Tier catalog delivered via signed remote manifest (§4.7) — new tiers/variants added without app release.

**Explicitly out of scope:**
- **Kimi K2.5 / K2.6** trillion-parameter MoE — ~500 GB at INT4, not on-device viable.
- **GPT-OSS 120B** — exceeds Workstation RAM target.
- **Llama 3.2 / 3.3 / 4 series** — 700M MAU cap + attribution obligation; Apache 2.0 equivalents exist at every tier.
- **Qwen 3.6 frontier models** (397B, 122B) — beyond any tier's footprint.

**🚫 Do NOT ship (licensing traps):**
- `iiiorg/piiranha-v1-detect-personal-information` — CC-BY-NC-ND-4.0.
- Any model trained on `ai4privacy/pii-masking-400k` — inherits NC obligations.
- `Qwen2.5-3B` — Qwen Research License (non-commercial). 0.5B/1.5B/7B and all Qwen 3.5/3.6 small/medium are Apache 2.0.

### 2.4 Storage & persistence

| Layer | Choice | License | Notes |
|---|---|---|---|
| DB engine | SQLite (SQLCipher) | Public domain / BSD | AES-256, Community Edition free |
| Flutter binding | drift | MIT | Reactive queries, compile-time types |
| SQLCipher integration | `package:sqlite3` v3 user-define `source: sqlite3mc` | MIT | Selected via Build Hooks (`hooks.user_defines`); SQLCipher-compatible cipher pinned at open (`PRAGMA cipher = 'sqlcipher'`). The former `sqlcipher_flutter_libs` package became a no-op shim on `package:sqlite3` 3.x — see ADR-019. |
| Migrations | drift built-in | MIT | Versioned schema |
| Vector search | sqlite-vec | Apache 2.0 | Native SQLite extension for vector indexes; HNSW-family ANN — backs Mink's Semantic and Resource Memory retrieval. **`mink_embeddings` vec0 table deferred to V1.2** (no bundleable Flutter build under SQLCipher yet) — see ADR-018 and §3.2. |
| Full-text search | SQLite FTS5 | Public domain | Built-in BM25-based full-text index; backs `search_documents` tool and Episodic Memory topic lookup |
| JSON | SQLite JSON1 | Public domain | Built-in; used for Project manifests, memory value payloads, Mink tool call metadata |
| CRDT replication | cr-sqlite | MIT | SQLite extension enabling conflict-free multi-device sync |

**Why SQLite (not Postgres or specialized databases):**

DocuMink is local-first — the database runs inside the user's phone or laptop, not on infrastructure we control. SQLite is the category-correct engine for embedded on-device storage, and its extension ecosystem covers every capability we need:

- **Full-text search** — FTS5's BM25 matches what Elasticsearch / pg_textsearch provide.
- **Vector search** — sqlite-vec implements HNSW-family ANN, same algorithm class as pgvector / Pinecone.
- **Document storage** — JSON1 extension covers what JSONB / MongoDB would offer.
- **Time-series workloads** — Mink writes at most a few dozen episodic events per active day; a B-tree index on `created_at` outperforms any time-series-specific engine at this volume.
- **CRDT sync** — cr-sqlite is mature, mobile-ready, and has no equivalent at the embedded tier for Postgres.

Postgres was evaluated and rejected: it is a server process (cannot be embedded in a sandboxed mobile app), has a 50–100+ MB binary footprint before extensions (our entire V1 install-size budget is 250 MB with models), needs 100+ MB of RAM at idle (impossible on a 2 GB Minimum-tier device), and requires a separate lifecycle model that conflicts with how Android and iOS manage background processes. The embedded-Postgres ecosystem (`pg_embed`, etc.) targets desktop development environments, not production mobile distribution.

Specialized databases (Elasticsearch, Pinecone, Redis, MongoDB, InfluxDB, PostGIS) were evaluated and rejected on the same grounds plus per-tool redundancy with SQLite extensions. **One encrypted database, one backup artifact, one sync target.**

**🚫 Do NOT use:** Hive (values encrypted, keys plaintext per NVISO Labs 2024). Also: no separate vector DB, no separate time-series DB, no separate document DB. Everything lives in the single SQLCipher-encrypted SQLite file.

### 2.5 Crypto primitives

| Purpose | Library | License |
|---|---|---|
| AES-GCM, AES-CTR, HKDF | cryptography | Apache 2.0 |
| Hardware-backed crypto | cryptography_flutter | Apache 2.0 |
| Argon2id | argon2 | MIT |
| FF1 format-preserving encryption | hand-rolled on pointycastle AES | MIT |
| HMAC-SHA256 | cryptography | Apache 2.0 |
| Ed25519 signature verification (manifests) | cryptography | Apache 2.0 |

### 2.6 Sync

| Layer | Choice | License |
|---|---|---|
| CRDT engine | cr-sqlite | MIT |
| BYOC: Google Drive | googleapis + google_sign_in | BSD-3 |
| LAN discovery | multicast_dns + nsd | BSD-3 / MIT |
| Transport crypto | cryptography AES-GCM framed | Apache 2.0 |

### 2.7 UI & media

| Purpose | Library | License |
|---|---|---|
| Camera | camera | BSD-3 |
| Image picker | image_picker | BSD-3 |
| PDF rendering | syncfusion_flutter_pdf (free tier) or pdf | evaluated at build |
| Image manipulation | image | MIT |
| File share | share_plus | BSD-3 |
| QR code gen/scan | qr_flutter + mobile_scanner | BSD-3 / MIT |
| Biometrics | local_auth | BSD-3 |

### 2.8 Monitoring (opt-in)

| Purpose | Library | License | Notes |
|---|---|---|---|
| Crash reporting | sentry_flutter | BSD-3 | Aggressive scrubbing, opt-in only |

---

## 3. Data model

Multi-tenant-ready schema from day one. Every row includes `workspace_id` (V1 single-user → single workspace; V3+ Teams → multiple members per workspace).

### 3.1 Core schema

```sql
CREATE TABLE workspaces (
  id TEXT PRIMARY KEY,            -- ULID
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  kek_version INTEGER NOT NULL
);

CREATE TABLE projects (
  id TEXT PRIMARY KEY,            -- ULID; also used as workspace_id for Project isolation
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  name TEXT NOT NULL,
  template_id TEXT,               -- 'personal','medical','legal','tax','research',
                                  -- 'creative','engineering','blank','ai_scaffolded', or community-hash
  manifest_json TEXT NOT NULL,    -- serialized ProjectManifest (see §6)
  manifest_version INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  archived INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE documents (
  id TEXT PRIMARY KEY,            -- ULID
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),  -- NULL if outside any project
  name TEXT NOT NULL,
  type TEXT NOT NULL,             -- 'text','image','pdf', (V4) 'form','signed'
  source_hash BLOB NOT NULL,      -- SHA-256 of original input
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  redacted_artifact_path TEXT,
  status TEXT NOT NULL,           -- 'draft','redacted','exported'
  metadata_json TEXT
);

CREATE TABLE entities (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  document_id TEXT NOT NULL REFERENCES documents(id),
  entity_type TEXT NOT NULL,      -- 'EMAIL','PERSON','MRN', or custom label
  detector TEXT NOT NULL,         -- 'regex','mlkit','gliner','llm'
  span_start INTEGER NOT NULL,
  span_end INTEGER NOT NULL,
  confidence REAL NOT NULL,
  operator_applied TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE tokens (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  entity_id TEXT NOT NULL REFERENCES entities(id),
  token_value TEXT NOT NULL,
  plaintext_fingerprint BLOB NOT NULL,  -- HMAC-SHA256 (separate key)
  ciphertext BLOB NOT NULL,             -- AES-GCM with token_value as AAD
  key_version INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_tokens_fingerprint ON tokens(workspace_id, plaintext_fingerprint);
CREATE INDEX idx_entities_document ON entities(document_id);
CREATE INDEX idx_documents_project ON documents(project_id);

CREATE TABLE custom_entity_types (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),  -- NULL = global to workspace
  label TEXT NOT NULL,
  regex_pattern TEXT,
  validator TEXT,
  examples_json TEXT,
  default_operator TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  UNIQUE(workspace_id, project_id, label)
);

CREATE TABLE audit_log (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT,                -- NULL for global events
  event_type TEXT NOT NULL,       -- 'decode','export','sync_push','vault_unlock',
                                  -- 'mink_tool_call','tier_change','variant_change',
                                  -- 'model_install','project_created', etc.
  document_id TEXT,
  entity_id TEXT,
  tool_name TEXT,                 -- for mink_tool_call events
  success INTEGER NOT NULL,
  biometric_result TEXT,
  metadata_json TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE vault_meta (
  key TEXT PRIMARY KEY,
  value BLOB NOT NULL
);

CREATE TABLE sync_state (
  device_id TEXT PRIMARY KEY,
  last_push_at INTEGER,
  last_pull_at INTEGER,
  peer_public_keys_json TEXT
);
```

### 3.2 Mink-specific schema

```sql
CREATE TABLE chat_sessions (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),  -- NULL = global chat
  title TEXT,                     -- user-editable; auto-generated from first exchange
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  tier_at_creation TEXT NOT NULL, -- which tier was active when session started
  variant_at_creation TEXT NOT NULL,
  model_id_at_creation TEXT NOT NULL,
  archived INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE chat_messages (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES chat_sessions(id),
  role TEXT NOT NULL,             -- 'user','mink','tool_call','tool_result','system'
  content TEXT NOT NULL,          -- may contain token refs like <<tok_01HXJ4...>> instead of plaintext
  tool_call_json TEXT,            -- structured tool call payload, if role='tool_call'
  tool_result_json TEXT,          -- structured tool result, if role='tool_result'
  tokens_input INTEGER,           -- diagnostic
  tokens_output INTEGER,          -- diagnostic
  inference_ms INTEGER,           -- diagnostic
  model_id TEXT NOT NULL,         -- which specific model generated this message
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_chat_messages_session ON chat_messages(session_id, created_at);

-- Mink memory is split into six typed stores per the MIRIX-derived taxonomy.
-- Full specification in memory.md.

-- Type 1: Core Memory — stable identity and preferences. Active V1.
CREATE TABLE mink_core_memory (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),  -- NULL = global
  key TEXT NOT NULL,              -- e.g. 'user_preferred_tone'
  value_json TEXT NOT NULL,       -- may contain token refs; never contains raw PII
  provenance TEXT NOT NULL,       -- 'explicit_user_statement','inferred','system_default','observed'
  confidence REAL,                -- for non-explicit provenance
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(workspace_id, project_id, key)
);

-- Type 2: Episodic Memory — time-stamped activity summaries. Active V1.
CREATE TABLE mink_episodic_memory (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),  -- NULL = global episodes
  occurred_at INTEGER NOT NULL,
  summary TEXT NOT NULL,          -- human-readable, may contain token refs
  details_json TEXT,              -- structured metadata (entities involved as token refs, actions taken, etc.)
  episode_type TEXT NOT NULL,     -- 'scan','redaction','chat','export','project_created', etc.
  token_refs_json TEXT,           -- JSON array of token_ids referenced in this episode
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_episodic_time ON mink_episodic_memory(workspace_id, project_id, occurred_at);

-- Type 3: Knowledge Vault — verbatim PII/PHI. ALREADY IMPLEMENTED as the `tokens` table.
-- Not re-declared here; see §3.1. Memory-layer code references it via HMAC-SHA256 fingerprints.

-- Type 4: Semantic Memory — entities and relationships, PII-safe via token refs. Schema V1, activation V1.2.
CREATE TABLE mink_semantic_memory (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),  -- NULL = cross-project global entity (rare; always user-initiated)
  entity_type TEXT NOT NULL,      -- 'PERSON','ORGANIZATION','LOCATION','CONCEPT', etc.
  canonical_fingerprint BLOB,     -- HMAC-SHA256(plaintext); NULL for concepts that have no PII backing
  descriptor TEXT,                -- non-PII descriptive metadata ("cardiologist","referring physician")
  parent_id TEXT REFERENCES mink_semantic_memory(id),  -- hierarchical parent (tree structure)
  occurrence_count INTEGER NOT NULL DEFAULT 1,
  first_seen_at INTEGER NOT NULL,
  last_seen_at INTEGER NOT NULL,
  embedding_id TEXT REFERENCES mink_embeddings(id),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_semantic_fingerprint ON mink_semantic_memory(workspace_id, canonical_fingerprint);
CREATE INDEX idx_semantic_parent ON mink_semantic_memory(parent_id);

CREATE TABLE mink_semantic_relationships (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),
  from_entity_id TEXT NOT NULL REFERENCES mink_semantic_memory(id),
  to_entity_id TEXT NOT NULL REFERENCES mink_semantic_memory(id),
  predicate TEXT NOT NULL,        -- 'works_at','mentioned_in','related_to', etc.
  confidence REAL NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_rel_from ON mink_semantic_relationships(from_entity_id);
CREATE INDEX idx_rel_to ON mink_semantic_relationships(to_entity_id);

-- Type 5: Procedural Memory — observed user workflow patterns. Schema V1, activation V1.2.
CREATE TABLE mink_procedural_memory (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  project_id TEXT REFERENCES projects(id),
  trigger_pattern_json TEXT NOT NULL,  -- e.g. {"action":"scan","document_type":"tax_return"}
  action_pattern_json TEXT NOT NULL,   -- e.g. {"operator":"fpe","entity_type":"EIN"}
  observed_count INTEGER NOT NULL DEFAULT 1,
  confidence REAL NOT NULL,
  last_observed_at INTEGER NOT NULL,
  user_confirmed INTEGER NOT NULL DEFAULT 0,  -- user explicitly approved this pattern
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Type 6: Resource Memory — already covered by `documents` table from §3.1.
-- V1.2+ adds vector embeddings for similarity search.

-- Shared: embedding storage for Semantic and Resource Memory vector search.
-- Uses sqlite-vec extension; embeddings stored as BLOB (float32 array).
-- DEFERRED TO V1.2 (ADR-018): sqlite-vec has no bundleable Flutter build that
-- loads under the encrypted SQLite library today, and its only consumers
-- (Semantic / Resource memory) activate in V1.2. The V1-Phase-1 schema creates
-- all 16 relational tables but NOT this virtual table; `mink_semantic_memory.
-- embedding_id` is implemented as a plain nullable TEXT with no foreign key
-- (a vec0 virtual table cannot be a FK target). This table is created when V1.2
-- activates embedding search.
CREATE VIRTUAL TABLE mink_embeddings USING vec0(
  id TEXT PRIMARY KEY,
  workspace_id TEXT,
  project_id TEXT,
  source_type TEXT,               -- 'semantic_entity','document_summary','episode_summary'
  source_id TEXT,                 -- FK to whichever table
  embedding FLOAT[384]            -- all-MiniLM-L6-v2 dimensions
);
```

**Notes on the memory schema:**

- The existing `tokens` table from §3.1 serves as Mink's **Knowledge Vault** — no separate structure needed. This is a DocuMink-specific advantage: our existing reversible-tokenization vault is already the exact structure MIRIX describes for verbatim PII storage.
- `canonical_fingerprint` in `mink_semantic_memory` is the HMAC-SHA256 of the entity's plaintext, computed with the separate HMAC key defined in §8.1. This lets semantic entities resolve to vault tokens without the memory layer ever holding plaintext.
- `parent_id` self-reference in `mink_semantic_memory` implements the hierarchical tree structure MIRIX describes. Traversed via SQLite recursive CTEs.
- `mink_embeddings` uses the sqlite-vec virtual table for HNSW-family ANN search. Vectors produced by the bundled `all-MiniLM-L6-v2` model (see §2.2).
- Memory isolation per Project follows the same `workspace_id`/`project_id` pattern as everywhere else in the schema. Enforced at the repository layer.

### 3.3 Design notes

- **ULIDs** over UUIDs for natural ordering and smaller indexes.
- **`plaintext_fingerprint` uses a separate HMAC key** — lookups don't require decryption. The same fingerprinting scheme doubles as the cross-reference identity for Mink's Semantic Memory.
- **AAD in AES-GCM is the token value** — prevents ciphertext transplantation.
- **Minimal plaintext in any column** — `chat_messages.content` may contain structured token references (`<<tok_01HXJ4...>>`) rather than inline plaintext, which get rendered on display with the show/hide-masked toggle. SQLCipher encrypts the entire DB at rest regardless.
- **`project_id` NULL allowed** on documents, chat_sessions, custom_entity_types, all six Mink memory tables — represents global-scope records outside any Project.
- **Project isolation enforced at repository layer** — every `ProjectService` and memory repository method takes a `projectId` and filters queries. Cross-project access requires explicit `AuditedCrossProjectAccess` API that writes to `audit_log`.
- **Memory layer never holds plaintext PII** — see memory.md for the full PII-safe reference model.

---

## 4. Detection pipeline

### 4.1 Pipeline stages

```
Input (text | image | PDF)
  ↓
Normalize (Unicode NFC, line-join, strip zero-width)
  ↓
(If image/PDF): OCR (ML Kit / Windows.Media.Ocr)
  ↓
Tier 1: Regex/checksum (parallel, fast)
Tier 2: ML Kit Entity Extraction (Android)
Tier 3: GLiNER-PII-Edge INT8 ONNX
Tier 4 (optional): LLM fallback for low-confidence spans OR user-invoked "deep analysis"
  ↓
Overlap resolver (Presidio-style)
  ↓
Policy engine (entity_type → operator mapping; Project-scoped when in Project)
  ↓
Apply operators (produce redacted artifact + write token rows)
  ↓
Persist to vault + render redacted artifact + write audit_log
```

### 4.2 Tier 1 recognizers (ship in V1)

Implemented in pure Dart as `PiiRecognizer` implementations:

- `EmailRecognizer`, `PhoneRecognizer` (libphonenumber-dart), `SsnRecognizer` (validity checks)
- `CreditCardRecognizer` (Luhn), `IbanRecognizer` (mod-97), `UrlRecognizer`, `IpAddressRecognizer`
- `DateRecognizer` (ISO + common ambiguous formats), `MrnRecognizer` (pattern + hospital prefixes)
- `PassportRecognizer` (country-specific for top-10)

### 4.3 Tier 3: GLiNER-PII-Edge integration

- **Hybrid, device-tiered delivery (ADR-022):** the **smallest GLiNER-PII variant** (edge/small,
  ~100 MB INT8) is **bundled** as an always-available offline baseline; capable devices get a
  **downloaded** base/large upgrade (FP16 where size allows) selected by the Device Capability
  Profiler (§4.7) and delivered via the same signed manifest + SHA-256 + PAD/download as Tier 4.
  Graceful degradation: no upgrade → baseline; no baseline → Tiers 1–2 only. (Full download path
  lands with Phase 9.)
- Loaded via `flutter_onnxruntime` at first use (lazy).
- Execution provider auto-selected: NNAPI (Android) → XNNPACK → CPU; DirectML (Windows) → CPU.
- Max 512 tokens per inference; long documents chunked with 50-token overlap; post-processing dedupes cross-chunk detections.
- Labels from `detection_labels.yaml` — zero-shot, updateable without retraining.

### 4.4 Tier 4: Device-tiered LLM fallback

- **Off by default** at first launch. User opts in after Device Capability Profiler recommendation (§4.7).
- **When triggered:** (a) Tier 3 confidence < 0.7 in ambiguous context, OR (b) user explicitly enables "deep analysis" for a document, OR (c) Mink invokes detection as a tool call (§5.4).
- Input: ~200 chars surrounding context + ambiguous span.
- Prompt: structured JSON output requesting entity type + confidence.
- If Tier 4 unavailable (skipped, below floor, or model not yet downloaded), pipeline silently proceeds with Tiers 1–3 only.

**Tier-aware runtime dispatch:** `LlmService` is model-agnostic; dispatches based on `vault_meta.llm_tier` + `llm_variant`. Runtimes per variant:

- **GGUF-based variants** (Qwen, SmolLM family): `fllama` via llama.cpp.
- **`.task`-based variants** (Gemma 4 family): `flutter_gemma` via LiteRT-LM.
- **System-provided (Android)**: `google_mlkit_genai_prompt` (Gemini Nano).
- **System-provided (Windows)**: Windows AI API (Phi Silica) via platform channel.

All implement a common `LlmBackend` interface — upstream code (Tier 4 detection, Mink chat, domain inference) is model-agnostic.

### 4.5 Overlap resolver

Presidio's algorithm: group by overlap → pick highest-confidence → tiebreak by longest span → tiebreak by detector priority (configurable).

### 4.6 Policy engine

User-configurable default policy; Project-scoped override when in a Project:

```yaml
# Default global policy
PERSON: token_random
EMAIL: mask
PHONE: mask
SSN: redact
CREDIT_CARD: fpe
MRN: fpe
LOCATION: token_random
DATE_OF_BIRTH: redact
```

Per-document overrides allowed. Project templates ship with their own policy defaults (§6.3).

### 4.7 Device Capability Profiler

The profiler is **device-agnostic with no upper ceiling.** It computes a numeric capability score and looks up the highest qualifying tier from a remote, signed tier catalog. New tiers and variants can be added without app releases. Runs once at onboarding, persists in `vault_meta`, user-adjustable anytime.

**Signals collected (all local):**

| Signal | Source (Android) | Source (Windows) | Purpose |
|---|---|---|---|
| Total RAM | `ActivityManager.getMemoryInfo()` | `GlobalMemoryStatusEx` | Primary capacity gate |
| Free storage | `StatFs` | `GetDiskFreeSpaceEx` | Disqualify tiers that won't fit |
| CPU cores/arch | `/proc/cpuinfo` | `GetLogicalProcessorInformation` | Throughput estimate |
| NPU presence/class | QNN delegate, Tensor detection | Windows ML EP enumeration | Acceleration score |
| GPU presence/VRAM | Vulkan queries | DXGI adapter enumeration | Desktop acceleration |
| System model availability | `GenerativeModel.status()` | `LanguageModel.IsAvailable()` | Bonus tier eligibility |
| Thermal envelope | Battery temp, charging state | Power plan | Sustained vs burst preference |
| Form factor | `Configuration.screenLayout` | Desktop detection | Desktop vs mobile defaults |
| Platform version | SDK/build | Build number | Runtime compatibility |

**Capability scoring:**

```dart
score = (ram_gb * 10)
      + (free_storage_gb * 2)
      + (cpu_cores * 3)
      + (npu_class * 20)       // 0=none, 1=basic, 2=strong, 3=flagship
      + (gpu_vram_gb * 8)
      + (system_model_available ? 50 : 0)
      + (form_factor == desktop ? 15 : 0);
```

**Signed manifest schema** (nested variants per tier; full catalog detail in `docs/models.md`):

```jsonc
{
  "version": 6,
  "signed_at": "2026-xx-xxT00:00:00Z",
  "signature": "ed25519:...",
  "tiers": [
    {
      "tier": "system_provided_android",
      "min_score": 100,
      "requires": { "system_model": "gemini_nano" },
      "opt_in_only": false,
      "variants": {
        "balanced": {
          "model_id": "gemini-nano-passthrough",
          "runtime": "mlkit_genai",
          "size_bytes": 0,
          "license_bundle": "system"
        }
      }
    },
    {
      "tier": "performance",
      "min_score": 90,
      "requires": { "min_ram_mb": 6144 },
      "opt_in_only": false,
      "variants": {
        "balanced": {
          "model_id": "gemma-4-e4b-int4",
          "runtime": "litert_lm",
          "size_bytes": 1800000000,
          "sha256": "...",
          "url": "https://documink.ai/models/gemma-4-e4b-int4.task",
          "license_bundle": "apache-2.0"
        },
        "specialized": {
          "model_id": "qwen3.5-9b-instruct-int4",
          "runtime": "gguf",
          "size_bytes": 5000000000,
          "sha256": "...",
          "url": "https://documink.ai/models/qwen3.5-9b-instruct-int4-q4_k_m.gguf",
          "license_bundle": "apache-2.0",
          "benefit_label": "Desktop-class reasoning on flagship phones; 201 languages"
        }
      }
    }
    // ... additional tiers per §2.3 tables
  ]
}
```

**Selection algorithm:**

```dart
TierSelection selectTier(DeviceCapabilities caps, TierCatalog catalog) {
  final score = computeScore(caps);

  final qualifying = catalog.tiers.where((t) {
    final largestVariantBytes = t.variants.values
      .map((v) => v.sizeBytes)
      .reduce((a, b) => a > b ? a : b);
    return score >= t.minScore
        && caps.meetsHardRequirements(t.requires)
        && caps.freeStorageBytes >= largestVariantBytes * 1.2;  // 20% headroom
  }).toList();

  final autoTier = qualifying
    .where((t) => !t.optInOnly)
    .sortedByDescending((t) => t.minScore)
    .firstOrNull;

  final optInAvailable = qualifying
    .where((t) => t.optInOnly)
    .sortedByDescending((t) => t.minScore)
    .toList();

  return TierSelection(
    recommendedTier: autoTier?.tier ?? Tier.none,
    recommendedVariant: Variant.balanced,  // always default to Balanced
    optInAvailable: optInAvailable.map((t) => t.tier).toList(),
    deviceScore: score,
    floorReason: autoTier == null ? computeFloorReason(caps) : null,
  );
}
```

**Onboarding UX:**
- Recommended tier + Balanced variant shown with size, speed category.
- One-tap "Accept and download" (primary path).
- "Show options" reveals Specialized + other qualifying tiers + opt-in tiers with size warnings.
- Desktop-only preference question: "Prefer faster responses or more accurate results?" (shifts recommendation ±1 tier).
- Explicit "Skip" option — Mink still appears in constrained informational mode.

**Floor behavior (below Minimum threshold):**
- Transparent UX explaining: "Your device runs all core features locally. Optional AI-assisted detection requires ≥2 GB RAM and 250 MB storage."
- Mink UI shows informational screen: "Mink is unavailable on this device. Core detection (Tiers 1–3) continues working. If you upgrade devices, DocuMink will detect the new capability automatically."
- Tier-4-dependent UI affordances **visibly disabled** with tooltips, not hidden (accessibility).
- "Re-check my device" button in Settings for recovery after storage cleanup.

**Ceiling behavior (qualifies for opt-in tiers):**
- Settings → AI Model → "Desktop-class models available" section.
- Both variants shown with size warnings.
- Explicit tap-through confirmation + disk-space check before download.
- Auto-recommended tier remains default; opt-in is additive.

**Model update flow:** Manifest version bump → in-app prompt with old-vs-new comparison (size, speed, changelog) → user chooses install/defer/decline → old model cleanly uninstalled after new model SHA-256-verified. Never silent.

**Persistence additions to `vault_meta`:**
- `llm_tier`, `llm_variant` (balanced|specialized), `llm_model_id`, `llm_model_version`
- `llm_download_state` (not_downloaded|downloading|ready|failed)
- `llm_profiler_score`, `llm_profiler_ran_at`
- `llm_user_preference` (faster|balanced|accurate; desktop-only)
- `llm_opt_in_tier_enabled` (bool)

---

## 5. Mink — the assistant layer

### 5.1 Architecture

Mink is a **single conversational agent per user**, synced across paired devices as encrypted state. Backed by whichever Tier 4 model the active device can run. Identity is constant (name, memories, preferences); inference model adapts per device.

**Service layer components:**

- **`MinkService`** — entry point for all conversational interactions. Handles session management, context assembly, LLM invocation via `LlmBackend`, and tool-call dispatch.
- **`ToolRegistry`** — catalog of tools Mink can invoke, with per-Project permission enforcement.
- **`ContextAssembler`** — assembles the LLM input for each turn: system prompt (Project-scoped when applicable), Mink memory, conversation history, relevant document snippets (with consent check), and tool descriptions.
- **`ProactiveSuggester`** (V1, reactive-only) — runs after user actions (scan, detection, redaction) to surface contextual suggestions.
- **`DomainInferenceService`** — specialized wrapper around `LlmService` for the Project creation "upload path" (§6.2).

### 5.2 Chat session lifecycle

1. User opens chat UI (in a Project or globally).
2. `MinkService.startOrResumeSession(projectId?)` → loads or creates `chat_sessions` row.
3. User sends message → `chat_messages` row (role='user').
4. `ContextAssembler` builds input:
   - System prompt (from Project manifest if in Project, else default)
   - Recent `mink_memory` entries (scoped to Project when applicable)
   - Previous N chat turns (windowed to fit model context budget)
   - Tool descriptions (filtered by Project permission manifest)
   - Optional: relevant document snippets if Project grants `read_documents` and user's query references documents
5. `LlmBackend.generate()` invoked with assembled input.
6. Streaming output rendered to UI as tokens arrive.
7. If output contains tool calls, `ToolRegistry` dispatches them (§5.4).
8. Final message persisted as `chat_messages` row (role='mink'), tool calls as separate rows.

### 5.3 System prompts (Project-scoped)

Each Project template ships with a Mink persona. Example for Medical Records:

```
You are Mink, the user's privacy-focused document assistant, operating in the
"Medical Records" Project. Your role here is conservative and precise.

RULES:
- Never fabricate clinical details, diagnoses, or treatment plans.
- Always recommend reversible anonymization (FPE or tokens) over irreversible
  redaction for data the user may need to recover.
- When uncertain about a PHI classification, ask the user rather than guess.
- You do not have permission to rewrite or expand document content in this Project.

AVAILABLE TOOLS: [dynamically injected from permission manifest]
CUSTOM ENTITY TYPES: [dynamically injected]
```

### 5.4 Tool registry and dispatch

Tools are declarative Dart classes registered at app startup. Each tool declares: name, description, JSON input schema, output schema, required permissions, and whether it requires biometric gate.

**V1 tool catalog:**

| Tool | Description | Permission required | Biometric? |
|---|---|---|---|
| `detect_pii` | Run detection pipeline on provided text or document | `detect_pii` | — |
| `anonymize_document` | Apply operators to detected entities | `anonymize` | — |
| `decode_token` | Reveal plaintext for a reversible token | `decode` | ✅ |
| `search_documents` | Full-text search within current Project | `read_documents` | — |
| `list_entities` | List detected entities in a document | `read_documents` | — |
| `summarize_document` | Mink summarizes a document (must grant access) | `read_documents` | — |
| `rewrite_content` | Mink rewrites text (V1, for Creative/Engineering templates) | `rewrite_content` | — |
| `expand_content` | Mink adds to text | `expand_content` | — |
| `export_document` | Generate export in specified format | `export` | — |
| `create_custom_entity` | User asks Mink to add custom entity type | `modify_project_settings` | — |
| `modify_policy` | User asks Mink to change a policy default | `modify_project_settings` | — |

**Dispatch flow:**

1. LLM output parsed for tool call JSON (structured output mode).
2. `ToolRegistry.dispatch(toolCall, projectContext)`:
   - Permission check against Project manifest → deny with transparent message if not permitted.
   - Biometric check if tool requires it → prompt user, abort on denial.
   - Tool executes; result returned as structured JSON.
3. Tool result appended to chat transcript as `chat_messages` row (role='tool_result').
4. Result fed back into LLM for next turn.
5. Every tool call written to `audit_log`.

### 5.5 Proactive suggestions (V1, scoped)

`ProactiveSuggester` runs after specific user actions:
- Completing a document scan
- Finishing detection on a pasted block
- Applying redaction to a document

It asks the LLM (using a brief, targeted prompt with action context) whether a follow-up suggestion would be valuable. If yes, a compact suggestion card appears in-context (not as a push notification). The card offers the action + dismissal. User can disable all suggestions in Settings.

**V1 constraints:**
- In-context only (never a system notification).
- No background processing.
- Limited to post-action moments.
- User setting to disable entirely.
- Audit-logged when suggestion is offered and when acted upon.

### 5.6 Mink memory

Mink has a **typed multi-store memory system** — adapted from the MIRIX taxonomy (Wang & Chen, 2025) with key architectural changes for on-device operation: single-agent deterministic router instead of multi-agent, PII-safe reference model, Project-scoped isolation, and tier-scaled update behavior.

**Six memory types** (three active in V1, three schema-ready for activation in V1.2+):

1. **Core Memory** — stable user identity and preferences (active V1).
2. **Episodic Memory** — time-stamped summaries of activity within Projects (active V1).
3. **Knowledge Vault** — verbatim PII/PHI, already implemented as the existing `tokens` table (active V1).
4. **Semantic Memory** — entities and relationships, stored as PII-safe token references with vector embeddings for retrieval (schema V1, activation V1.2).
5. **Procedural Memory** — observed user workflow patterns (schema V1, activation V1.2).
6. **Resource Memory** — already covered by `documents` table, with embedding-based similarity search added in V1.2.

**Critical invariant: PII never enters memory as plaintext.** Semantic Memory stores HMAC-SHA256 fingerprints that reference rows in the Knowledge Vault (`tokens` table). Mink reasons about entities via opaque references; plaintext is only materialized through the existing biometric-gated decode flow. This means Mink's memory database can be inspected, exported, or (hypothetically) exfiltrated without revealing user PII — the vault's security guarantees extend to the memory layer.

**See `memory.md` for the full specification** — memory-type schemas, retrieval patterns, the deterministic router architecture, PII reference model with fingerprint-based identity, tier-scaled update behavior, Project scope enforcement per memory type, provenance tracking, user controls, sync behavior, and the memory-specific threat model.

### 5.7 Tier-dependent capability

Mink's behavior adapts to the active tier:

| Tier | Context window | Reasoning | Tool calls | UI indicator |
|---|---|---|---|---|
| System-provided / Performance / Pro / WS | Full | Extended | All | None (default) |
| Standard | Full | Strong | All | None |
| Light | Reduced (~4K context) | Moderate | All | None |
| Ultra-light | Shortened (~2K context) | Simple | All | "Lightweight mode" pill |
| Minimum | Minimal (~1K context) | Basic Q&A only | Limited subset | "Minimum mode" pill |
| None (below floor) | N/A | N/A | N/A | Informational screen replaces chat UI |

---

## 6. Projects — the scoped harness

### 6.1 Project manifest

A Project's configuration is a declarative JSON document stored in `projects.manifest_json`. It is **versioned** — edits create new versions; `audit_log` records the change; rollback is possible.

```jsonc
{
  "manifest_schema_version": 1,
  "template_id": "medical",           // or 'legal', 'blank', 'ai_scaffolded', community-hash
  "name": "Medical Records 2026",
  "domain": "healthcare",
  "permissions": {
    "read_documents": true,
    "detect_pii": true,
    "anonymize": true,
    "decode": "requires_biometric",
    "rewrite_content": false,
    "expand_content": false,
    "export": true,
    "search_web": false,
    "modify_project_settings": true,
    "cross_project_search": false
  },
  "default_policy": {
    "PERSON": "token_random",
    "MRN": "fpe",
    "DATE_OF_BIRTH": "redact",
    "PHI_DIAGNOSIS": "redact"
  },
  "custom_entity_types": [
    { "label": "PROVIDER_NPI", "regex": "\\b\\d{10}\\b", "validator": "luhn_npi" }
  ],
  "mink_persona": "medical_records_conservative",
  "mink_system_prompt_addendum": "…",
  "expected_file_types": ["pdf", "image"],
  "ui_accents": { "primary_color": "#2E5A88" }
}
```

### 6.2 Three creation paths

**Path A — Start from Template.**
- User browses Verified templates (signed manifest `templates/manifest.json`).
- Preview screen shows composition.
- One tap creates Project with template's manifest.

**Path B — Upload Documents (AI-scaffolded).**
- User selects files.
- On Light tier or above: `DomainInferenceService` reads first 1–2 pages of each document (locally, via `LlmBackend`) and emits structured output: `{ domain, confidence, candidate_templates[], suggested_custom_entities[], suggested_persona }`.
- **Strong match (confidence ≥0.75 single candidate):** UI proposes the matched template with composition preview and "This looks like a [X] document. Use this template?" affordance.
- **Weak match (multiple candidates with similar confidence):** UI shows top 2–3 candidates side by side.
- **No match (all candidates <0.5):** UI shows "AI-scaffolded — please review" flow with fully generated manifest. Prompts user after Project creation: "Save this as a reusable personal template?"
- **On Ultra-light / Minimum / below-floor:** Upload path skips inference, falls back to Template Picker or Blank Wizard with explanatory text.

**Path C — Start Blank (guided wizard).**
- User answers 4–5 questions (domain, content type, sensitive entities, desired tools).
- Wizard composes manifest.
- Project created with `template_id = 'blank'`.

### 6.3 Verified templates (V1 shipped)

Eight templates ship in the initial signed manifest:

1. **personal** — receipts, forms, IDs, utility bills. Permissive UI; conservative policy.
2. **medical** — clinical notes, insurance forms, prescriptions. Narrow tool permissions; flagship PHI policy.
3. **legal** — agreements, discovery, client correspondence. Strict anonymization defaults.
4. **tax** — returns, statements, tax forms. FPE-forward for ID numbers.
5. **research** — source material, interviews. Source-protection focused.
6. **creative** — drafts, manuscripts, outlines. Permissive content-rewrite tools.
7. **engineering** — RFCs, incident reports, code reviews. Custom entities for internal IDs.
8. **blank** — escape hatch with guided wizard.

### 6.4 Template delivery (signed remote manifest)

- Hosted at `https://documink.ai/templates/manifest.json`.
- Ed25519-signed with the same key infrastructure as the model manifest.
- Fetched at first launch, refreshed weekly.
- Cached locally; offline fallback to bundled last-known-good.
- Signature verification failure blocks update; never falls back to unsigned.

### 6.5 Personal templates

When a user saves an AI-scaffolded or customized Project as a "personal template," its manifest is stored in `vault_meta` under `personal_templates:<template_id>`. Personal templates appear in the template picker marked "Yours." Synced across devices via CRDT.

### 6.6 V4 community templates

Built on the V4 thin relay backend (§9.6). Users publish signed templates via the relay; recipients import via `documink.ai/t/<hash>` URL. DocuMink hosts signed bytes with no endorsement; user's app shows "Published by [author pubkey fingerprint]" indicator. Discovery is out-of-band in V4; curated directory deferred.

### 6.7 Project isolation enforcement

- `ProjectService.getDocuments(projectId)` — hard filter on `documents.project_id`.
- Mink's `ContextAssembler` loads context exclusively from current Project's workspace partition.
- Cross-project actions go through `AuditedCrossProjectAccess` API that requires explicit per-invocation user consent and writes to `audit_log`.
- Global chat sessions (`project_id=NULL`) have **no** access to any Project's documents — only what the user types directly.

---

## 7. Reversible tokenization layer

### 7.1 Three modes

**Random token** (default for names, free-text PII):
- Format: `<TYPE_6charBase62>`.
- Generated via `SecureRandom`.
- Ciphertext in `tokens.ciphertext`.

**FPE via FF1** (format-sensitive fields):
- NIST SP 800-38G FF1 only. **Do NOT implement FF3/FF3-1** — NIST withdrew FF3 in Draft Revision 2, February 2025.
- Tweak = entity_type + workspace_id hash.
- ~300 lines of Dart on `pointycastle` AES. NIST test vectors.
- CC numbers: preserve 6-4-4-4 format, keep last 4 (or first 6) in clear per policy.

**AES-GCM encrypt-in-place**:
- Base64 ciphertext in token wrapper.
- Stateless reversal (no vault row).
- For "encrypt not tokenize" user choice.

### 7.2 Decode flow

```
User taps token (UI)
  ↓
Biometric gate (local_auth)
  ↓ (success)
Fetch tokens row by token_value
  ↓
Decrypt ciphertext with DEK (AAD = token_value)
  ↓
Write audit_log entry
  ↓
Display plaintext ephemerally (no auto-clipboard)
```

---

## 8. Vault & key management

### 8.1 Key hierarchy

```
User passphrase (never stored)
  ↓ Argon2id (64 MB, t=3, p=4, salt in secure storage — see note)
Master Key (MK) — RAM only, zeroed on lock (best-effort, see note)
  ↓ HKDF-SHA256 with domain separation (info strings)
  ├─→ DB key            'documink:sqlcipher:v1'  (opens the SQLCipher vault)
  ├─→ KEK               'documink:kek:v1'        (wraps DEKs)
  ├─→ Fingerprint-HMAC  'documink:fp-hmac:v1'    (token indexing)
  └─→ Sync transport    'documink:sync:v1'

KEK wrapped by (biometric fast-path, Phase 5):
  - Android: Keystore (StrongBox where available) via flutter_secure_storage
  - Windows: DPAPI via flutter_secure_storage

DEK (data encryption key) encrypts tokens.ciphertext
  - Rotatable via key_version column
  - Stored wrapped (AES-256-GCM under KEK) in vault_meta
```

> **Note (V1 P1b, ADR-020).** The Argon2id **salt lives in `flutter_secure_storage`**, not in
> `vault_meta`: `vault_meta` is inside the encrypted database, which cannot be read until the
> DB key is derived — which needs the salt. The salt is not secret, but it must be readable
> *before* unlock. `vault_meta` holds only post-unlock material (the wrapped DEK, `key_version`).
> A **dedicated DB-key subkey** opens SQLCipher (HKDF info `documink:sqlcipher:v1`) so the
> database key and the KEK never share material. In V1's **passphrase-only** scope the KEK is
> re-derived from MK on every unlock; persisting a Keystore-wrapped KEK is the biometric
> fast-path and lands with Phase 5. **MK/subkey zeroing is best-effort** on managed Dart — the GC
> may retain copies that cannot be scrubbed; keys are held in `Uint8List` and overwritten on lock,
> never placed in `String`s or logs.

### 8.2 Unlock sequence

1. App start → vault locked (MK not in RAM).
2. User enters passphrase (or biometric fast-path if enrolled).
3. Argon2id → MK.
4. Derive subkeys.
5. SQLCipher rekey with derived key.
6. Start session timer (60–300s auto-lock).

### 8.3 Biometric convenience (not a replacement for passphrase)

- Enrollment: MK encrypted with Keystore-bound biometric-gated key.
- Unlock: biometric → Keystore returns key → decrypt MK.
- Passphrase required on: first unlock per session, after too many biometric failures, after device reboot (Android `SETUP_BIOMETRIC` key invalidation).

### 8.4 Recovery

- BIP-39 phrase shown once at onboarding; user confirms by re-entry.
- Phrase encodes the Argon2id-derived MK **via the BIP-39 entropy path** (24 words = 256-bit MK +
  checksum), so the exact MK bytes round-trip — *not* the PBKDF2 seed path (ADR-021). The
  `RecoveryService` codec (V1 P1d) is storage-free; the recover→reset-passphrase orchestration
  lands with Phase 5 onboarding.
- Lost passphrase + lost phrase = permanently inaccessible vault (by design).

---

## 9. Sync architecture

### 9.1 Principles

- **Never sync plaintext.**
- **Device-local derived keys.** Transport keys derived from MK; peers authenticate via public keys.
- **Idempotent CRDT deltas** via cr-sqlite.

### 9.2 BYOC Google Drive (V1)

- Scope: `https://www.googleapis.com/auth/drive.appdata` (app-private folder, not user-visible in Drive UI).
- Files: `vault.db.enc` (SQLCipher) + `deltas/<ulid>.cbor.enc` (AES-GCM-encrypted CRDT deltas).
- Push/pull triggers: foreground-after-gap, manual, Wi-Fi-connected-idle.
- OAuth via `google_sign_in`; tokens in platform secure storage.

### 9.3 LAN sync via mDNS (V1)

- Service type: `_documink._tcp.local.`.
- Each device advertises `device_id` + public key fingerprint.
- First-time pairing: QR-code-exchanged transport key.
- Subsequent auth: known public keys.
- Transport: WebSocket over TLS (self-signed, pinned from QR), AES-GCM-framed CRDT deltas.

### 9.4 Conflict handling

- CRDT auto-resolves most conflicts (LWW on scalars, set union on collections).
- Hard conflicts (e.g., custom_entity_types with same label, different patterns): surfaced in Settings → Sync Conflicts.

### 9.5 V3+ additions

- Additional BYOC: iCloud (if/when iOS ships post-V4), OneDrive, Dropbox.
- **LAN-dispatched inference (V3):** when a user has multiple paired devices on the same network, heavy inference can be dispatched to the more capable device. Uses existing LAN transport. Default off; explicit opt-in. UI shows "Running on [Device Name]" during dispatched inference; one-tap revert to local.
- **P2P over internet (V4):** via the thin relay backend; opt-in Pro.
- Team/shared vaults (V3+): `workspace_members` table, tree-based group key agreement (TreeKEM-style).

### 9.6 V4 thin relay backend

DocuMink's first (and only) backend component. Minimal, stateless, content-addressed. Serves three uses:

- **URL-based encrypted document sharing** — user encrypts document client-side, uploads blob, gets `documink.ai/s/<id>#<key>` URL. Key is in URL fragment, never transmitted to server.
- **Community template publishing** — author signs template with their own key, uploads blob. Recipients fetch via `documink.ai/t/<id>` and import. Signed-by-author, not by DocuMink.
- **Same-user WAN inference dispatch** — the relay forwards encrypted inference requests between the user's own devices (E2E encrypted between the user's devices; relay sees only ciphertext). Enables "phone uses home laptop for heavy inference even over the internet." Opt-in Pro feature.

Hosting: Cloudflare Workers + R2 or AWS Lambda + S3. No user accounts. Anonymous uploads with rate limiting. Content-addressed with expiry.

---

## 10. Cross-platform strategy

### 10.1 Android (V1)

- Min SDK: 26 (Android 8.0). **Raised from 24** in V1 P2e: `com.google.mlkit:entity-extraction`
  (Tier 2 detection) requires API 26. Android 8.0+ covers effectively all active devices; the
  low-single-digit % on API 24–25 is an accepted trade for native ML Kit. (docs/DECISIONS.md)
- Target SDK: latest (35).
- Architectures: arm64-v8a primary; armeabi-v7a optional split.
- 16 KB page size via `flutter_onnxruntime` 1.5.1+ (required Pixel 9+/Android 15+).
- Execution providers: NNAPI → XNNPACK → CPU (ONNX); LiteRT-LM for `.task` models.
- LiteRT QNN accelerator for Snapdragon 8 Gen 2+ (runtime-detected).

### 10.2 Windows (V2)

- Flutter Windows desktop.
- ONNX Runtime DirectML EP; Windows ML GA runtime on 24H2+.
- DPAPI for key wrapping; Windows Hello biometrics via `local_auth`.
- Phi Silica passthrough via Windows AI API (platform channel).
- MSIX installer; EV code signing for SmartScreen reputation.

### 10.3 Shared ONNX artifact

One ONNX file for both platforms. Runtime picks EP:
- Android: NNAPI → XNNPACK → CPU
- Windows: DirectML → CPU

No platform-specific detection model files.

---

## 11. Build & packaging

### 11.1 Android

- Flavors: `dev`, `staging`, `prod`.
- Play Asset Delivery for Tier 4 models (see `docs/models.md` §2 for full hosting strategy):
  - Standard-tier Balanced bundled as install-time pack (user can skip).
  - All other tiers/variants as on-demand packs.
  - Each pack ≤1 GB (Play limit); split packs for larger models (e.g., Qwen 3.5-9B).
- Base APK ≤150 MB. R8 aggressive shrinking.
- Play Integrity API optional, degrades gracefully.

### 11.2 Windows (V2)

- MSIX build.
- ~200 MB base + on-demand model downloads.
- Code-signed.
- Direct-download installer + optional MS Store.

### 11.3 CI/CD

- GitHub Actions pipeline:
  - `flutter analyze` strict.
  - `dart test` unit tests.
  - `flutter test integration_test/`.
  - License scanner (deny-list any non-commercial/GPL).
  - Analytics-SDK scanner (deny firebase_analytics, mixpanel, etc.).
  - APK size gate (<150 MB base).
  - ONNX model SHA-256 pin check.
  - Tier 4 model benchmark on reference devices (latency p50/p95, F1 accuracy). Regression gate: F1 drop >2 points or latency +30% blocks release.

---

## 12. Testing strategy

### 12.1 Unit tests (target: >80% service-layer coverage)

- Recognizers — golden fixtures.
- Operators — round-trip tests for reversible modes.
- FPE — NIST test vectors.
- Argon2id — known test vectors.
- CRDT — scripted conflict scenarios.
- `DeviceCapabilityProfiler.selectTier()` — floor, Minimum, mid, flagship, and synthetic "future device" fixtures.
- Tool permission enforcement — deny-on-missing-permission tests per Project manifest.

### 12.2 Integration tests

- End-to-end: scan → detect → redact → vault → decode → audit.
- Sync: push device A, pull device B, assert equality.
- Biometric gate: mocked `local_auth` success/fail paths.
- Project isolation: verify Project A data invisible from Project B.
- Mink tool dispatch: verify permission manifest enforced; denied tool calls logged with "permission_denied" result.

### 12.3 Model evaluation suite

- Held-out test set: 1000 hand-labeled docs.
- Metrics: per-entity P/R/F1, latency p50/p95.
- Nightly on reference device (emulator + physical).
- Regression gate: F1 drop >2 points blocks release.

### 12.4 Security review

- Pre-V1 launch:
  - Third-party audit (scope: key management, vault, sync crypto, manifest signing, model runtime sandboxing).
  - SBOM generation and review.
  - FPE fuzzing.
  - MobSF scan on release APK.

### 12.5 Accessibility

- Automated `SemanticsDebugger` checks.
- Manual TalkBack + Narrator passthrough on all hero flows.

---

## 13. Third-party dependency policy

### 13.1 License allow-list

Apache 2.0, MIT, BSD (2/3-clause), ISC, Zlib, Unlicense, CC0.

### 13.2 License deny-list

- GPL, AGPL (LGPL case-by-case).
- CC-BY-NC*, CC-BY-NC-ND*.
- Qwen Research License, Falcon Research License (for the specific variants).
- **Gemma Terms** — Gemma 4 ships under Apache 2.0, so this is obsolete; but legacy Gemma 3 usage would require the terms-bundle, which we avoid.
- **Llama Community License** — the 700M MAU cap adds complexity; we use Qwen/Gemma Apache 2.0 equivalents everywhere.
- Custom source-available licenses without commercial-use grant.

### 13.3 Banned SDKs

- All ad networks.
- All analytics SDKs (Firebase Analytics, Mixpanel, Amplitude, Segment, GA).
- Social-login SDKs beyond Google Drive OAuth.
- Tracking-focused push notification services.

---

## 14. Forward compatibility hooks

### 14.1 V2 (Windows port)

- Flutter Windows target scaffolding already in project structure.
- `LlmBackend` interface supports Windows AI API (Phi Silica) as a registered implementation.
- Device Capability Profiler accepts Windows-specific signals (DXGI GPU VRAM, power plan).
- Opt-in Professional / Workstation tiers already declared in model manifest, just not yet activated on Android.

### 14.2 V3 (expansion + Teams)

- `detection_labels.yaml` multilingual extension (Qwen 3.5-based tiers already support 201 languages natively).
- `workspace_members`, `member_keys` tables for Teams.
- `CloudProvider` interface with implementations for additional BYOC (iCloud post-V4, OneDrive, Dropbox).
- LAN-dispatched inference: extends existing LAN transport with `InferenceDispatchProtocol` for same-user devices.
- Project merge flow — schema already multi-tenant with `workspace_id` + `project_id`.

### 14.3 V4 (document platform + thin relay)

- `documents.type` already supports `'form'`, `'signed'`.
- New tables: `form_fields`, `signatures`, `share_links`, `community_template_imports`.
- **Thin relay backend** is the first (and only) DocuMink-hosted component. Scope kept minimal:
  - `POST /blobs` (anonymous upload, returns content ID + expiry)
  - `GET /blobs/:id` (fetch, rate-limited)
  - `POST /templates` (signed template upload)
  - `GET /templates/:hash` (fetch)
  - `POST /relay/:device_fingerprint` (encrypted inference dispatch, opt-in Pro)
  - No user accounts; no persistence beyond expiry; object storage only.
  - E2E encryption throughout — server sees ciphertext only (except signed public template contents).

---

## 15. "Don't do" reference

This list prevents known failure modes. Violating any of these requires explicit ADR and sign-off.

1. **Don't use Piiranha v1** or any model trained on `ai4privacy/pii-masking-400k` — CC-BY-NC-ND.
2. **Don't use Hive** for vault — keys plaintext (NVISO 2024).
3. **Don't implement FF3/FF3-1** — NIST withdrew Feb 2025. FF1 only.
4. **Don't depend on Gemini Nano as primary** — foreground-only, quota-gated, device-restricted. Opportunistic enhancement.
5. **Don't sync plaintext** — ever. Not even in dev builds.
6. **Don't add Firebase Analytics** or any tracking SDK — violates product principles and Data Safety declaration.
7. **Don't store passphrases or plaintext in `shared_preferences`** — keys only in flutter_secure_storage.
8. **Don't bypass biometric gate** in dev builds with env flags that could leak.
9. **Don't use MediaPipe LLM Inference API** — deprecated on Android/iOS in 2025. Use LiteRT-LM via flutter_gemma.
10. **Don't use `sqflite_sqlcipher`** — lacks Windows binaries. Use drift + sqlcipher_flutter_libs.
11. **Don't use `android.permission.health.*`** unless required.
12. **Don't ship ONNX models without INT8 quantization verified.**
13. **Don't hard-code detection labels** — they live in `detection_labels.yaml`.
14. **Don't skip the license scanner in CI** — one transitive GPL dep poisons the release.
15. **Don't silently swap models.** Tier changes, variant switches, and model version updates must always prompt with before/after comparison.
16. **Don't skip manifest signature verification** — Ed25519 public key pinned in binary; verification failure blocks update.
17. **Don't add trillion-parameter MoE models** (Kimi K2.6-class) — ~500 GB on-device unrealistic.
18. **Don't let Mink bypass Project permissions** — denied tool calls must surface transparent refusal and write to audit_log.
19. **Don't let Mink read documents outside the active Project context** without explicit cross-project consent flow.
20. **Don't enable proactive suggestions by default to be intrusive** — V1 is reactive-only (post-action), in-context, dismissible, user-disableable.
21. **Don't auto-create background services** for Mink or inference — no foreground service in V1.
22. **Don't treat AI-scaffolded templates as Verified** — they must be clearly labeled and re-reviewable.
23. **Don't ship DocuMink with any cloud inference capability** — all inference on-device always. V4 relay is for encrypted-blob transport between the user's own devices or for one-author-many-recipients public templates; it never does inference itself.
24. **Don't store raw PII/PHI plaintext in Mink memory tables** — Semantic Memory references entities via HMAC-SHA256 fingerprints that point to the `tokens` vault. If a PR tries to write a name, address, MRN, or other sensitive string directly into `mink_semantic_memory`, `mink_episodic_memory`, `mink_core_memory`, or `mink_procedural_memory`, it's a bug. Memory-layer writes must be token-ref-safe. See memory.md §3.
25. **Don't swap SQLite for Postgres or any other server database on-device** — we evaluated this and rejected it; see §2.4 for the full rationale. If a contributor proposes this, point them at §2.4.
26. **Don't add specialized databases alongside SQLite on-device** (no separate vector DB, no separate time-series DB, no separate document DB, no Redis-equivalent). Every capability we need is available via SQLite extensions (sqlite-vec, FTS5, JSON1, cr-sqlite). One encrypted database, one backup artifact, one sync target.
27. **Don't run multi-agent Mink architectures** — ADR-012 commits to single-agent scoped-context. MIRIX's multi-agent memory pattern was adapted to a single-agent deterministic router for on-device tractability; see memory.md §4. If a PR proposes separate agents per memory type, reject with reference to ADR-012.
28. **Don't add or modify Tier 4 models without updating `docs/models.md`** — the catalog, quantization per family, SHA-256 hashes, license bundles, and hosting routes all live there. If you add a new model to the manifest, update models.md in the same PR. See models.md §9 for catalog-specific "don't do" rules.
29. **Don't host Tier 4 models on documink.ai for Android V1** — Play Asset Delivery is the primary distribution path (cost-free, Play-signed, mobile-native). Our own infrastructure only serves the signed `manifest.json` itself. See models.md §2.
30. **Don't run `build_runner` without `--force-jit` on Dart 3.10** — our dep tree pulls Build Hooks transitively (drift → sqlite3 → native_toolchain_c); the AOT codegen path fails with `'dart compile' does not support build hooks`. Always `dart run build_runner build --force-jit --delete-conflicting-outputs`. Do **not** downgrade deps or switch channels to dodge it. Tracking dart-lang/build#4343; full standing instruction in `.agents/rules/dart-toolchain.md` and CLAUDE.md "Known constraints".

---

*End of Blueprint.*
