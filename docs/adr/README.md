# Architecture Decision Records

This directory holds DocuMink's Architecture Decision Records (ADRs). Each ADR captures one
significant architectural decision: its context, what was decided, why, and the consequences.

## Conventions

- **One file per decision**, named `ADR-0NN.md`, numbered sequentially.
- **Status** is one of `Proposed` / `Accepted` / `Superseded by ADR-0NN` / `Deprecated`.
  ADR-001…ADR-017 were recorded in **V0 Phase 3** and are **Accepted** — they formalize
  decisions already embedded in the authoritative specs (`docs/PRD.md`, `docs/blueprint.md`,
  `docs/memory.md`, `docs/models.md`).
- **ADRs cite the specs; they do not replace them.** Precedence is unchanged: PRD defines
  *what*, blueprint defines *how*, `memory.md` wins on memory behavior, `models.md` wins on
  Tier 4 detail. Where an ADR summarizes a spec (notably **ADR-016 → `memory.md`** and
  **ADR-017 → `models.md`**), the cited spec remains the source of truth.
- New decisions append the next number. Reversing a past decision adds a new ADR that marks the
  old one `Superseded by ADR-0NN` (ADRs are immutable history, not edited away).

## Template

```
# ADR-0NN: <title>

- Status: Accepted
- Date: YYYY-MM-DD
- Context: <phase/PR in which recorded>

## Context        — the problem and forces
## Decision       — what was chosen
## Rationale       — why; grounded in the cited specs
## Alternatives considered / rejected   — where applicable
## Consequences    — implications and constraints imposed
## References      — spec sections (file §section)
## Related ADRs    — cross-links
```

## Index

| ADR | Title | Status |
|---|---|---|
| [001](ADR-001.md) | Flutter as cross-platform framework | Accepted |
| [002](ADR-002.md) | ONNX Runtime via `flutter_onnxruntime` as primary inference runtime for encoders | Accepted |
| [003](ADR-003.md) | SQLCipher + drift for vault | Accepted |
| [004](ADR-004.md) | GLiNER-PII-Edge as primary Tier 3 detection model | Accepted |
| [005](ADR-005.md) | Argon2id + Keystore/DPAPI for key management | Accepted |
| [006](ADR-006.md) | FF1 (not FF3) for format-preserving encryption | Accepted |
| [007](ADR-007.md) | Multi-tenant schema from day one | Accepted |
| [008](ADR-008.md) | No third-party analytics | Accepted |
| [009](ADR-009.md) | cr-sqlite for CRDT sync | Accepted |
| [010](ADR-010.md) | BYOC (Google Drive) + LAN mDNS as V1 sync | Accepted |
| [011](ADR-011.md) | Device-capability-tiered Tier 4 LLM (Balanced/Specialized, signed catalog, no silent swaps) | Accepted |
| [012](ADR-012.md) | Mink as a single-agent-per-user scoped-context model (not multi-agent) | Accepted |
| [013](ADR-013.md) | Projects as declarative domain-agnostic harnesses via signed remote manifest | Accepted |
| [014](ADR-014.md) | V4 thin relay backend as the first and only hosted component | Accepted |
| [015](ADR-015.md) | iOS/macOS deferred until after V4 | Accepted |
| [016](ADR-016.md) | Mink memory architecture — six typed stores, PII-safe refs (defers to memory.md) | Accepted |
| [017](ADR-017.md) | Tier 4 model hosting — PAD / HuggingFace / Ed25519 manifest (defers to models.md) | Accepted |
| [018](ADR-018.md) | Defer the `mink_embeddings` vec0 virtual table to V1.2 (amends ADR-003) | Accepted |
| [019](ADR-019.md) | Encrypted vault via `package:sqlite3` v3 `source: sqlite3mc` user-define (amends ADR-003) | Accepted |
| [020](ADR-020.md) | Key-storage layout — salt + biometric KEK in secure storage, dedicated DB-key subkey (refines ADR-005) | Accepted |
| [021](ADR-021.md) | BIP-39 recovery phrase as a 256-bit entropy codec (entropy path, not seed); recover-orchestration deferred to Phase 5 | Accepted |
| [022](ADR-022.md) | Tier 3 detection model — hybrid bundled-baseline + device-tiered downloaded upgrade via signed manifest (extends ADR-004) | Accepted |
