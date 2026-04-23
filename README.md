# DocuMink

Privacy-first, local-first document redactor plus on-device AI assistant.

- **Platforms:** Android V1, Windows V2. iOS/macOS deferred past V4.
- **Stack:** Flutter ≥3.24, Dart ≥3.5, Riverpod, drift+SQLCipher, sqlite-vec, flutter_gemma, fllama, cr-sqlite.
- **Domain:** documink.ai
- **Hard rules:** No cloud inference. No user accounts. No third-party analytics. No plaintext sync. No PII/PHI in memory tables.

## Authoritative specs

All architectural decisions live in `docs/`:

- `docs/DocuMink-PRD.md` — product requirements; what we're building and why
- `docs/DocuMink-Blueprint.md` — technical architecture; how we're building it
- `docs/DocuMink-Memory.md` — Mink memory subsystem specification
- `docs/DocuMink-Roadmap.md` — milestones → phases → tasks

**If the PRD and Blueprint disagree, the PRD defines what, the Blueprint defines how. If anything conflicts with DocuMink-Memory.md about memory behavior, DocuMink-Memory.md wins.**

## For AI agents working in this repo

Before starting any task:

1. Read the relevant Roadmap phase in `docs/DocuMink-Roadmap.md`. V1 has 17 phases in dependency order.
2. Check Blueprint §15 "Don't do" rules before proposing architectural changes. These encode researched failure modes.
3. For memory-layer work, read DocuMink-Memory.md §3 (PII-safe reference model) and §12 (memory-specific "don't do" rules).
4. Flag any proposed deviation from the docs explicitly. Either the implementation should change, or the docs should be updated — but not silently.

See `.agents/rules.md` for workspace-wide agent behavior rules.

## Build status

Pre-V0. Project scaffold not yet initialized.
