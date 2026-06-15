# Gemma 3n / Gemma 4 E2B (on-device) — reference

**Source:** https://ai.google.dev/gemma/docs/gemma-3n — **fetched 2026-06-15.**
Vendored summary; not authoritative over `docs/` specs (`models.md` is the catalog authority).

The "E" = **effective** parameters (MatFormer + Per-Layer Embeddings).
- **E2B:** ~5B params loaded, but operates at an **effective ~1.91B** memory load.
- **E4B:** contains E2B's params; MatFormer allows intermediate 2B–4B sizes.
- **Context:** 32K tokens (per gemma-3n page; Gemma 4 small models elsewhere cited up to 128K —
  confirm against the exact model card we ship).
- **License:** Apache 2.0 (code samples); models "licensed for responsible commercial use" —
  consistent with `models.md` §1 ("Gemma 4 shipped Apache 2.0").
- **Runtimes:** LiteRT-LM, MediaPipe LLM Inference API, llama.cpp, MLX.
- **Memory levers:** PLE caching (cache per-layer-embedding params to fast local storage);
  conditional loading (skip audio/visual params) to cut RAM.

**DocuMink mapping:** `models.md` §3.1 lists Gemma 4 E2B int4 as **Standard-tier Balanced**
(`google/gemma-4-e2b-it-task`, ~1.2 GB disk, 4 GB min RAM gate). For `flutter_gemma`/LiteRT-LM
the `.litertlm` build (`litert-community/gemma-4-E2B-it-litert-lm`) may be preferred over `.task`
(NPU support, newer) — to confirm during the device session and reconcile in `models.md`.
