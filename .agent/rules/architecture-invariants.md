---
trigger: always_on
---

Architecture hard invariants. Never violate without explicit user approval:

1. No Postgres or specialized databases on-device. SQLite + SQLCipher + sqlite-vec + FTS5 + JSON1 + cr-sqlite covers every capability we need. See blueprint.md §2.4.
2. No multi-agent Mink architectures. Single agent, deterministic router. See memory.md §4 and ADR-012.
3. No silent model, tier, or variant swaps. Always prompt the user with before/after comparison.
4. Ed25519 signature verification on every fetch of model and template manifests. Verification failure blocks update; never fall back to unsigned.
5. Never add or modify Tier 4 models without updating docs/models.md in the same PR. See models.md §9.
6. Never self-host Tier 4 models on documink.ai for Android V1. Play Asset Delivery is the primary distribution path; our infrastructure only serves the signed manifest.json.