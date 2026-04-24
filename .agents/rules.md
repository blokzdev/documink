# DocuMink Agent Rules

These rules apply to every agent working in this workspace. The AntiGravity Customizations → Rules → Workspace panel contains a condensed version that is auto-loaded into agent system prompts; this file is the full human-readable source.

## Before starting a task

- Read the relevant section(s) of `docs/roadmap.md` for phase context.
- Read `docs/blueprint.md` §15 "Don't do" rules. Violating these without explicit user consent is a task-stopping condition.
- For memory-layer work, also read `docs/memory.md` §3 and §12.
- For Tier 4 model work, also read `docs/models.md` §9.

## Hard invariants (never violate)

1. **No cloud inference.** All LLM calls run on-device via flutter_gemma, fllama, ML Kit GenAI, or Windows AI APIs. Never add an HTTP client call to an LLM API.
2. **No third-party analytics.** CI enforces this. Do not import firebase_analytics, mixpanel, amplitude, segment, or google_analytics.
3. **No plaintext sync.** Sync deltas are AES-GCM-encrypted. Never write user data to BYOC or LAN transport without encryption.
4. **No PII/PHI in memory tables.** `mink_core_memory`, `mink_episodic_memory`, `mink_semantic_memory`, `mink_procedural_memory` store token references or HMAC-SHA256 fingerprints — never raw sensitive strings.
5. **No Postgres or specialized databases on-device.** SQLite + SQLCipher + sqlite-vec + FTS5 + JSON1 + cr-sqlite covers every capability we need. See blueprint.md §2.4 for rejected-alternatives rationale.
6. **No multi-agent Mink architectures.** Single agent, deterministic router. See ADR-012 and memory.md §4.
7. **No silent model swaps, tier changes, or variant changes.** Always prompt the user with before/after comparison.
8. **Every Mink tool call writes to `audit_log`.** No exceptions, including permission-denials and biometric-gate outcomes.
9. **Ed25519 manifest signature verification** on every fetch of model and template manifests. Verification failure blocks update; never fall back to unsigned.
10. **Project isolation is a hard invariant.** `workspace_id` / `project_id` filtering enforced at repository layer. Cross-project access goes through AuditedCrossProjectAccess API.
11. **No adding/modifying Tier 4 models without updating `docs/models.md`** — the catalog, quantization per family, SHA-256 hashes, license bundles, and hosting routes all live there. If you add a new model to the manifest, update models.md in the same PR.
12. **No self-hosting Tier 4 models on documink.ai for Android V1.** Play Asset Delivery is the primary distribution path. Our infrastructure only serves the signed `manifest.json` itself.

## License hygiene

- Allow-list: Apache 2.0, MIT, BSD (2/3-clause), ISC, Zlib, Unlicense, CC0.
- Deny-list: GPL, AGPL, CC-BY-NC*, CC-BY-NC-ND*, Qwen Research License, Falcon Research License, Gemma Terms (legacy — Gemma 4 is Apache 2.0 and fine), Llama Community License.
- CI enforces this via the license scanner. Do not disable it or add exceptions without explicit user approval.

## Deviation protocol

If you believe the spec docs are wrong or incomplete, stop and surface it to the user with:

1. What you were trying to do
2. Which spec section appears to conflict
3. Your proposed reading of what the spec intends
4. Whether you're proposing to change the implementation or the spec

Do not silently deviate. Do not "work around" a constraint in the specs without explicit user confirmation.

## Commit hygiene

- One feature or one phase per PR.
- Reference the Roadmap phase in the commit message (e.g., "V0 Phase 1: Flutter project scaffold").
- Update spec docs in the same PR if the implementation revealed a spec-level issue.
- Never commit secrets, keys, API tokens, or sample PII.
