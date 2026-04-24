---
trigger: always_on
---

Privacy-first hard invariants. Never violate without explicit user approval:

1. No cloud inference. All LLM calls run on-device via flutter_gemma, fllama, ML Kit GenAI, or Windows AI APIs. Never add an HTTP client call to an LLM API.
2. No third-party analytics. Never import firebase_analytics, mixpanel, amplitude, segment, or google_analytics.
3. No plaintext sync. Sync deltas are AES-GCM-encrypted.
4. No raw PII/PHI in memory tables. mink_core_memory, mink_episodic_memory, mink_semantic_memory, mink_procedural_memory store token references or HMAC-SHA256 fingerprints only. See memory.md §3.
5. Project isolation enforced at repository layer via workspace_id/project_id filtering. Cross-project access goes through the AuditedCrossProjectAccess API.
6. Every Mink tool call writes to audit_log — including permission denials and biometric-gate outcomes.