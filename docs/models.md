# DocuMink — Tier 4 LLM Catalog & Hosting Strategy

**Scope:** authoritative specification for the Tier 4 LLM catalog, model sourcing, quantization choices, hosting strategy, and distribution mechanics
**Status:** active for V1 implementation; hosting strategy is Android-specific and evolves for Windows V2
**Related:** Blueprint §2.3 (tier tables), §4.4 (Tier 4 detection), §4.7 (Device Capability Profiler + manifest), §11.1 (Android packaging); Roadmap V1 Phases 9–11
**Audience:** engineering, AI coding agents implementing Tier 4 model download, verification, and dispatch

This document is the source of truth for which models we ship, from where, in what quantization format, signed how, and hosted on which infrastructure. If Blueprint §2.3 and this document disagree on specifics, this document wins for model-level detail and the Blueprint should be updated to match.

---

## 1. Design goals

- **Zero ongoing bandwidth cost for Android V1.** Models distributed via Google Play Asset Delivery (PAD), which is cost-free to us; Google absorbs egress.
- **Ed25519-signed manifest as single source of truth.** The app reads `manifest.json`, not this document. This document explains the manifest; the manifest drives code.
- **SHA-256 pinning for every model file.** Download verification blocks any byte mismatch. Replay protection against bit-flip corruption or MITM-modified downloads.
- **Licensing hygiene.** Every model in the catalog is Apache 2.0 or MIT. No Gemma Terms exceptions (Gemma 4 shipped Apache 2.0). No Qwen Research License. No Llama Community License.
- **Quantization consistency per model family.** Gemma 4 uses LiteRT `.task` int4 QAT; Qwen, SmolLM, and Phi use GGUF `q4_k_m`. One quantization decision per family — no mixing.
- **No silent URL or version swaps.** Manifest updates bump the manifest `version` field and trigger user-facing before/after comparison UX in-app.

---

## 2. Hosting strategy per platform

### 2.1 Android V1 — Google Play Asset Delivery (PAD)

**Why PAD:** Google absorbs bandwidth cost at any scale, native Android integration for resume-on-failure, cryptographically verified by Play Store, familiar to end users, no egress on our infrastructure. For a freemium app with uncertain user growth, this is the category-correct choice.

**Pack organization:**
- Each tier+variant combination is one asset pack (or a split pack for files >1 GB — PAD's per-pack limit).
- Pack delivery types:
  - **Install-time packs:** Standard-tier Balanced (Gemma 4 E2B, ~1.2 GB). User can skip install-time download but defaults to include.
  - **On-demand packs:** all other tiers and variants. Downloaded when user selects that tier/variant in Settings or during onboarding.
- Pack naming convention: `tier_<tier>_variant_<balanced|specialized>_v<manifest_version>`. Example: `tier_standard_variant_balanced_v6`.
- Split packs (files >1 GB): Performance Specialized (Qwen 3.5-9B at ~5 GB) splits into 5 sub-packs downloaded sequentially; manifest entry declares the pack list.

**Integrity verification:**
- Play Store's own package signing verifies the pack itself on delivery.
- Our app additionally SHA-256 verifies the extracted model file against the hash in `manifest.json`. Double-verification handles the (unlikely) case where a pack is Play-signed but contains a different model file than expected.

**Update flow:**
- Manifest version bump (e.g., new model release, security patch) → in-app prompt with before/after comparison → user accepts → old pack uninstalled, new pack downloaded via PAD → SHA-256 verified → tier switched.

### 2.2 Windows V2 — Direct HuggingFace downloads

**Why HuggingFace direct:** PAD doesn't exist outside the Play Store ecosystem. Setting up our own CDN for Windows distribution costs money and scales with user growth. HuggingFace's CDN is mature, free, and all our models are publicly hosted there anyway. The Windows user base is smaller and typically has better bandwidth than mobile users.

**Distribution mechanics:**
- Each model's download URL points to the specific quantized file on HuggingFace (not the repo root — the exact file).
- Example: `https://huggingface.co/Qwen/Qwen3.5-0.8B-Instruct-GGUF/resolve/main/qwen3.5-0.8b-instruct-q4_k_m.gguf`.
- Resume-capable via HTTP range requests.
- SHA-256 verified post-download against manifest hash.
- On hash mismatch: retry once; on second failure, surface user-facing error with "Report this" link (manifest may be stale relative to HuggingFace's current file; we'd ship an updated manifest).

**Fallback considerations:**
- If HuggingFace is temporarily unreachable, downloads fail gracefully with retry UX.
- If a HuggingFace repo is taken down or renamed (unlikely for Apache 2.0 / MIT models but theoretically possible), we ship a manifest update pointing to an alternate source (we maintain a mirror on `documink.ai/models/` only as an emergency fallback, not as the primary distribution — the cost profile makes primary self-hosting infeasible for V1-V3 user scales).

### 2.3 What we host on documink.ai ourselves

Only two things live on our infrastructure for the model system:

1. **`manifest.json`** — tiny (few KB), Ed25519-signed, hosted at `documink.ai/models/manifest.json`. Fetched weekly with exponential backoff. This is the *only* always-our-infrastructure artifact for model distribution.
2. **Emergency mirrors** (not normally used) — reserved for scenarios where HuggingFace or Play Asset Delivery is unavailable. These are cold-storage R2 buckets that only get activated if a manifest update flag points to them. Not a distribution primary.

---

## 3. Tier catalog (authoritative)

Each tier has one or two variants. **Balanced is auto-selected by the profiler; Specialized is user-switchable.** Minimum and System-provided are single-option.

All models are **Apache 2.0 or MIT licensed** — no exceptions in the live catalog.

### 3.1 Auto-recommendable tiers (profiler picks highest qualifying, Balanced variant)

| Tier | Variant | Model | HF ID | Quantization | Runtime | Disk (INT4) | Min RAM | License | Sources |
|---|---|---|---|---|---|---|---|---|---|
| **System-provided (Android)** | — | Gemini Nano via ML Kit GenAI | System | System-managed | `mlkit_genai` | 0 MB (OS) | — | System | [ML Kit GenAI docs](https://developers.google.com/ml-kit/genai) |
| **System-provided (Windows)** | — | Phi Silica via Windows AI APIs | System | System-managed | `windows_ai` | 0 MB (OS) | — | System | [Windows AI APIs docs](https://learn.microsoft.com/windows/ai/apis/) |
| **Performance** | Balanced | Gemma 4 E4B int4 QAT | `google/gemma-4-e4b-it-task` | LiteRT `.task` int4 QAT | `litert_lm` | ~1.8 GB | 6 GB | Apache 2.0 | [HF repo](https://huggingface.co/google/gemma-4-e4b-it-task) |
| **Performance** | Specialized | Qwen 3.5-9B Instruct | `Qwen/Qwen3.5-9B-Instruct-GGUF` | GGUF `q4_k_m` | `fllama` | ~5.0 GB | 6 GB | Apache 2.0 | [HF repo](https://huggingface.co/Qwen/Qwen3.5-9B-Instruct-GGUF) |
| **Standard** *(Pixel 6-class default)* | Balanced | Gemma 4 E2B int4 QAT | `google/gemma-4-e2b-it-task` | LiteRT `.task` int4 QAT | `litert_lm` | ~1.2 GB | 4 GB | Apache 2.0 | [HF repo](https://huggingface.co/google/gemma-4-e2b-it-task) |
| **Standard** | Specialized | Qwen 3.5-4B Instruct | `Qwen/Qwen3.5-4B-Instruct-GGUF` | GGUF `q4_k_m` | `fllama` | ~2.2 GB | 4 GB | Apache 2.0 | [HF repo](https://huggingface.co/Qwen/Qwen3.5-4B-Instruct-GGUF) |
| **Light** | Balanced | Qwen 3.5-2B Instruct | `Qwen/Qwen3.5-2B-Instruct-GGUF` | GGUF `q4_k_m` | `fllama` | ~1.2 GB | 4 GB | Apache 2.0 | [HF repo](https://huggingface.co/Qwen/Qwen3.5-2B-Instruct-GGUF) |
| **Light** | Specialized | SmolLM3-3B | `HuggingFaceTB/SmolLM3-3B-GGUF` | GGUF `q4_k_m` | `fllama` | ~1.8 GB | 4 GB | Apache 2.0 | [HF repo](https://huggingface.co/HuggingFaceTB/SmolLM3-3B-GGUF) |
| **Ultra-light** | Balanced | Qwen 3.5-0.8B Instruct | `Qwen/Qwen3.5-0.8B-Instruct-GGUF` | GGUF `q4_k_m` | `fllama` | ~600 MB | 3 GB | Apache 2.0 | [HF repo](https://huggingface.co/Qwen/Qwen3.5-0.8B-Instruct-GGUF) |
| **Ultra-light** | Specialized | Qwen 2.5-0.5B Instruct | `Qwen/Qwen2.5-0.5B-Instruct-GGUF` | GGUF `q4_k_m` | `fllama` | ~330 MB | 3 GB | Apache 2.0 | [HF repo](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF) |
| **Minimum** *(floor, single option)* | — | SmolLM2-360M Instruct | `HuggingFaceTB/SmolLM2-360M-Instruct-GGUF` | GGUF `q4_k_m` | `fllama` | ~220 MB | 2 GB | Apache 2.0 | [HF repo](https://huggingface.co/HuggingFaceTB/SmolLM2-360M-Instruct-GGUF) |

### 3.2 Opt-in only tiers (never auto-recommended; desktop-class hardware)

| Tier | Variant | Model | HF ID | Quantization | Runtime | Disk (INT4) | Min RAM | License | Sources |
|---|---|---|---|---|---|---|---|---|---|
| **Professional** | Balanced | Gemma 4 26B A4B MoE | `google/gemma-4-26b-a4b-it-gguf` | GGUF `q4_k_m` | `fllama` | ~9 GB | 12 GB | Apache 2.0 | [HF repo](https://huggingface.co/google/gemma-4-26b-a4b-it-gguf) |
| **Professional** | Specialized | Phi-4 14B | `microsoft/phi-4-gguf` | GGUF `q4_k_m` | `fllama` | ~8.5 GB | 12 GB | MIT | [HF repo](https://huggingface.co/microsoft/phi-4-gguf) |
| **Workstation** | Balanced | Gemma 4 31B dense | `google/gemma-4-31b-it-gguf` | GGUF `q4_k_m` | `fllama` | ~18 GB | 32 GB | Apache 2.0 | [HF repo](https://huggingface.co/google/gemma-4-31b-it-gguf) |
| **Workstation** | Specialized | Qwen 3.6-27B dense | `Qwen/Qwen3.6-27B-Instruct-GGUF` | GGUF `q4_k_m` | `fllama` | ~16 GB | 32 GB | Apache 2.0 | [HF repo](https://huggingface.co/Qwen/Qwen3.6-27B-Instruct-GGUF) |

### 3.3 Floor state — no tier

Devices below Minimum tier requirements (<2 GB RAM or <250 MB free storage) get no Tier 4. Mink UI replaced with informational screen per Blueprint §4.7. Detection pipeline Tiers 1–3 continue working unchanged.

### 3.4 Tier 3 detection models (this manifest also serves them — ADR-022)

The same signed manifest + SHA-256 + PAD/download path serves the **Tier 3 PII NER** models, not
just Tier 4 LLMs. Strategy (ADR-022): **bundle** the smallest `knowledgator/gliner-pii-*` variant
(edge/small, Apache-2.0, ~100 MB INT8) as an offline baseline, and offer a **device-tiered
downloaded upgrade** (base ≈ UINT8 197 MB / FP16 330 MB, F1 81.0%; large, F1 83.3%) on capable
devices, with graceful degradation to Tiers 1–2. The concrete Tier 3 catalog (chosen variants,
quantization per device class, sizes) is finalized when Tier 3 delivery is implemented (Phase 9).

---

## 4. Quantization decisions (authoritative per family)

**Rule: one quantization per model family. No mixing within a family.** Consistent quantization simplifies the manifest, simplifies benchmarking, simplifies user expectations.

### 4.1 Gemma 4 family → LiteRT `.task` int4 QAT

**Why:** Gemma 4 is Google's flagship on-device model family with quantization-aware training (QAT) as the supported path. QAT produces int4 quantization with measurably better quality than post-training quantization at the same size, and is delivered via Google's LiteRT-LM runtime in `.task` format. `flutter_gemma` package consumes this directly.

**Applies to:** Gemma 4 E2B, E4B, 26B A4B MoE, 31B dense.

### 4.2 Qwen 3.5 / 3.6 / 2.5 family → GGUF `q4_k_m`

**Why:** Qwen models are distributed primarily as safetensors; `llama.cpp`-compatible GGUF quantizations are a second-party ecosystem (maintained by Qwen team + community). `q4_k_m` is the standard mid-quality 4-bit quantization — balanced quality vs. size, widely benchmarked, supported by `fllama` on Android/Windows. Alternatives (`q5_k_m` for more quality at larger size, `q4_0` for smaller at worse quality) are not used — one quantization per family is the rule.

**Applies to:** Qwen 3.5-0.8B, 3.5-2B, 3.5-4B, 3.5-9B, 3.6-27B, 2.5-0.5B.

### 4.3 SmolLM family → GGUF `q4_k_m`

**Why:** SmolLM (HuggingFace TB) is distributed as safetensors with community GGUF quantizations. Same reasoning as Qwen.

**Applies to:** SmolLM2-360M-Instruct, SmolLM3-3B.

### 4.4 Phi-4 → GGUF `q4_k_m`

**Why:** Microsoft distributes Phi-4 as safetensors; GGUF quantizations come from the llama.cpp community. `q4_k_m` is the standard.

**Applies to:** Phi-4 14B (Professional Specialized).

### 4.5 System-provided models → OS-managed

Gemini Nano (Android) and Phi Silica (Windows) are delivered and managed by the OS. Quantization is handled by ML Kit GenAI and Windows AI APIs respectively; we don't configure it.

---

## 5. Manifest schema and authorship

The manifest lives at `assets/model_manifest/manifest.json` in the repo (for development and review) and is served from `https://documink.ai/models/manifest.json` in production.

**Authoring flow:**
1. Developer or agent adds/updates a model entry in `assets/model_manifest/manifest.json`.
2. Downloads the model locally, computes SHA-256 hash, updates manifest.
3. CI verifies the hash against the downloaded file.
4. Signing: manifest is signed with the Ed25519 production key (held in secure key management; see Blueprint §4.7); signed blob is committed to `assets/model_manifest/manifest.signed.json`.
5. Deploy step uploads the signed manifest to `documink.ai/models/manifest.json`.

**Manifest schema reference** is in Blueprint §4.7. Key requirement: every variant entry must include `model_id`, `runtime`, `size_bytes`, `sha256`, `url` (or `pad_pack_name` for Android install-time packs), `license_bundle`, and (for Specialized variants) `benefit_label`.

**Manifest versioning:**
- `version` field increments monotonically per release.
- `signed_at` is ISO 8601 timestamp.
- Signature covers the entire manifest body.
- Public key is pinned in the app binary; key rotation is a major event requiring app update.

---

## 6. Model update flow (end-to-end)

When we want to ship a new model or replace an existing one:

1. **Evaluation.** New candidate model is benchmarked against our PII disambiguation held-out set (Roadmap V1 Phase 10). Must meet F1 ≥0.90 and latency p95 ≤ 1.3x of existing model (regression gate).
2. **Licensing check.** CI verifies the model is Apache 2.0 or MIT (never a research-only or custom license).
3. **Quantization.** Gemma family → LiteRT `.task`; all others → GGUF `q4_k_m`.
4. **Host.** Android: build new PAD pack with new model file. Windows: ensure the HuggingFace URL resolves.
5. **Manifest update.** Bump `version`, add new variant entry with URL/pack name, SHA-256, size, license bundle, benefit_label. Sign with Ed25519 key.
6. **In-app prompt.** App fetches new manifest on weekly refresh, notices version bump, shows comparison UX ("New model available: Gemma 4 E2B v2 → v3 — size 1.2 GB (unchanged), speed +8%, F1 +0.4"). User accepts or defers.
7. **Download + verify.** New model downloaded via PAD (Android) or HuggingFace (Windows), SHA-256 verified, old model uninstalled, new tier active.

**No silent swaps.** Per Blueprint §4.7 and §15 rule 15, every model update prompts the user explicitly.

---

## 7. Model testing and benchmarking

Per Roadmap V1 Phase 10, every catalog model goes through:

- **Functional test:** loads and produces valid output on Pixel 6, Pixel 9, Galaxy A-series (Android reference devices).
- **Latency benchmark:** first-token latency p50, p95 and decode tok/s measured on reference devices.
- **Quality benchmark:** F1 score on held-out 1000-document PII disambiguation set.
- **Memory profile:** peak RAM during inference, measured on reference devices. Must fit within the Min RAM column of §3.
- **Thermal profile:** sustained 10-minute inference test. Models that cause reference devices to thermal-throttle fail the gate.

Benchmarks run in CI against emulator (baseline) and physical reference devices (pre-release). Results committed to `benchmarks/tier4/<model_id>.json` for transparency and regression comparison.

---

## 8. Licensing bundle per model

Every model ships with its license text bundled in the app (at `assets/licenses/<model_id>.txt`). Mink's Settings → About → Licenses screen enumerates every model currently installed + its license.

**Apache 2.0 models** (Gemma 4 family, Qwen family, SmolLM family, Qwen 3.6):
- License text from HuggingFace repo's `LICENSE` file bundled verbatim.
- Required: attribution notice + copy of Apache 2.0 license text.
- No restrictions on commercial use, no user-count caps.

**MIT models** (Phi-4):
- License text from `LICENSE` file bundled verbatim.
- Required: attribution notice + copy of MIT license text.
- No restrictions.

**System-provided models:**
- Not bundled; covered by OS ToS on the end-user's device.

---

## 9. "Don't do" reference (catalog-specific)

1. **Don't add a model to the catalog without verifying its license.** License must be Apache 2.0 or MIT. Run license check in CI; reject PR on non-compliance.
2. **Don't add a model that requires a custom attribution obligation** (e.g., Llama Community License's 700M MAU cap + "Built with Llama"). Apache 2.0 / MIT only.
3. **Don't mix quantization formats within a family.** Gemma 4 is `.task`; Qwen / SmolLM / Phi are GGUF `q4_k_m`. No exceptions.
4. **Don't ship a model without SHA-256 pinning in the manifest.** Unverified downloads are a supply-chain vulnerability.
5. **Don't host primary distribution on documink.ai for Android V1.** PAD is the primary distribution path; our servers only host the signed manifest.
6. **Don't put download URLs directly in Dart code.** URLs come from the manifest, which is signed and versioned. Hard-coding URLs in app code bypasses the manifest's security guarantees.
7. **Don't skip the benefit_label** on Specialized variants. The Balanced vs. Specialized choice must always be meaningful and labeled.
8. **Don't add an auto-recommendable tier that requires >6 GB RAM.** Professional and Workstation are opt-in only. Auto-recommendation floor is Minimum tier (2 GB RAM); ceiling is Performance tier (6 GB RAM).
9. **Don't bypass the Ed25519 signature verification** on manifest fetch. If signature is invalid, abort update and keep the current manifest. Never fall back to unsigned.
10. **Don't auto-download opt-in tier models.** Professional and Workstation require explicit user consent with disk-space confirmation.

---

*End of Models & Hosting Spec.*
