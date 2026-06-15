# LiteRT-LM — reference

**Source:** https://github.com/google-ai-edge/LiteRT-LM — **fetched 2026-06-15.**
Vendored summary; not authoritative over `docs/` specs.

Google's cross-platform on-device LLM orchestration runtime (Android, iOS, Web, Desktop,
IoT); powers on-device GenAI in Chrome, Chromebook Plus, Pixel Watch.

- **Format:** `.litertlm` is the primary deployment format (e.g.
  `litert-community/gemma-4-E2B-it-litert-lm` on HuggingFace). Also reads MediaPipe `.task`.
- **Backends:** CPU, GPU (mobile + desktop), NPU (hardware-specific; Gemma support noted in
  v0.7 release notes). NPU is `.litertlm`-only (per flutter_gemma).
- **Models:** Gemma, Llama, Phi-4, Qwen. Gemma 4 with Multi-Token Prediction "up to 3× faster".
- **Android:** Kotlin API is stable (Kotlin Guide). Consumed in Flutter via `flutter_gemma`.
- Native runtime library sizes not stated upstream; measured via `flutter_gemma` (see that file)
  ≈ 34 MB core + GPU/WebGPU/constraint/RAG companions.
