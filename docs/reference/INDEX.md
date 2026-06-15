# Vendored reference docs (post-cutoff tech)

These are **snapshotted summaries** of authoritative external docs for technology that
post-dates the coding agent's training cutoff (Gemma 4 / Gemma 3n, `flutter_gemma`,
LiteRT-LM, Flutter deferred components, ML Kit GenAI). They exist to **guide the Tier-4
on-device-LLM implementation** (Roadmap Phases 10–11) without re-fetching, and to record
what we learned.

**Status:** reference only. These do **not** override the authoritative specs in `docs/`
(`PRD.md`, `blueprint.md`, `models.md`, `memory.md`). Where they inform a decision, that
decision is logged in `docs/DECISIONS.md`. Each file headers its source URL + fetch date;
re-fetch to refresh.

| File | Source | Why it matters |
|---|---|---|
| `flutter_deferred_components.md` | docs.flutter.dev/perf/deferred-components | Whether/how the LiteRT runtime can be delivered on-demand |
| `flutter_gemma.md` | pub.dev/packages/flutter_gemma | The runtime package: model install/session API, native libs, size guidance |
| `litert_lm.md` | github.com/google-ai-edge/LiteRT-LM | The inference engine + `.litertlm`/`.task` formats |
| `gemma_3n_e2b.md` | ai.google.dev/gemma/docs/gemma-3n | The model: effective params, RAM, context, license |

**Fetched:** 2026-06-15.

## ⚠ Key finding (drove a plan pivot — see DECISIONS.md)

Per the Flutter deferred-components doc: **a plugin's native libraries (`.so`) cannot be
deferred individually** — they are packaged into the module whose Dart uses them, and
Flutter's plugin tooling targets the **base** app module. So delivering `flutter_gemma`'s
LiteRT `.so` (~110 MB arm64) via a Play **dynamic feature module** is **not a
toolchain-supported path** without fragile custom Gradle surgery. `flutter_gemma`'s own
guidance is instead: **don't bundle the model** (download it — already our 10c design) and
**restrict to `arm64-v8a`** (its `.litertlm`/FFI features are arm64-only). Combined with
trimming unused native libs (qdrant_edge RAG, WebGPU accelerator, constraint provider), the
base lands ~170 MB arm64 — **under Play's ~200 MB base-APK limit, no feature module needed.**
