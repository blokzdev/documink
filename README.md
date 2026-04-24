# DocuMink

Privacy-first, local-first document redactor plus on-device AI assistant.

- **Platforms:** Android V1, Windows V2. iOS/macOS deferred past V4.
- **Stack:** Flutter ≥3.24, Dart ≥3.5, Riverpod, drift+SQLCipher, sqlite-vec, flutter_gemma, fllama, cr-sqlite.
- **Domain:** documink.ai
- **Hard rules:** No cloud inference. No user accounts. No third-party analytics. No plaintext sync. No PII/PHI in memory tables.

## Authoritative specs

All architectural decisions live in `docs/`:

- `docs/PRD.md` — product requirements; what we're building and why
- `docs/blueprint.md` — technical architecture; how we're building it
- `docs/memory.md` — Mink memory subsystem specification
- `docs/models.md` — Tier 4 LLM catalog, sources, quantization, and hosting strategy
- `docs/roadmap.md` — milestones → phases → tasks

**Precedence when specs disagree:**
- PRD defines *what*; blueprint defines *how*.
- memory.md is authoritative on memory behavior.
- models.md is authoritative on Tier 4 model-level detail (sources, quantization, hosting).
- If blueprint and models.md disagree on a model detail, models.md wins and blueprint is updated to match.

## For AI agents working in this repo

Before starting any task:

1. Read the relevant Roadmap phase in `docs/roadmap.md`. V1 has 17 phases in dependency order.
2. Check blueprint.md §15 "Don't do" rules before proposing architectural changes. These encode researched failure modes.
3. For memory-layer work, read memory.md §3 (PII-safe reference model) and §12 (memory-specific "don't do" rules).
4. For Tier 4 model work, read models.md — catalog, quantization choices, hosting strategy, and §9 catalog-specific rules.
5. Flag any proposed deviation from the docs explicitly. Either the implementation should change, or the docs should be updated — but not silently.

See `.agents/rules.md` for workspace-wide conventions. Agent-facing rules also live in the AntiGravity Customizations → Rules → Workspace panel.

## Build status

Pre-V0 Phase 1. Project scaffold not yet initialized.
