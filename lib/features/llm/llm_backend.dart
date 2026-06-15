/// Thrown when no on-device LLM is available — either no Tier-4 runtime is wired
/// (the bare core) or the device is below the model floor (§4.7). Callers must
/// degrade gracefully (e.g. fall back to a non-AI path), never crash.
class LlmUnavailableException implements Exception {
  const LlmUnavailableException([
    this.message = 'No on-device LLM is available',
  ]);
  final String message;
  @override
  String toString() => 'LlmUnavailableException: $message';
}

/// The on-device text-generation seam (blueprint §2.3 Tier 4; models.md). The
/// real adapter — `flutter_gemma` / LiteRT running the profiler-selected model
/// (e.g. Gemma 4 E2B at Standard tier) — is wired at bootstrap and
/// device-verified. Pure-Dart code (orchestrators, tests) depends only on this
/// interface, so the whole Tier-4 surface is testable headlessly with fakes.
abstract interface class LlmBackend {
  /// Whether an on-device model is loaded and ready to generate.
  Future<bool> isAvailable();

  /// Generates a completion for [prompt]. Throws [LlmUnavailableException] when
  /// no model is available — never returns a silently-empty result.
  Future<String> generate(String prompt, {int maxOutputTokens});
}

/// The safe default until a Tier-4 runtime is composed at bootstrap: reports
/// unavailable and refuses generation (fails loud). Mirrors the other native
/// seams' "deny by default" stance (e.g. `UnavailableOcrRecognizer`).
class UnavailableLlmBackend implements LlmBackend {
  const UnavailableLlmBackend();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async =>
      throw const LlmUnavailableException();
}
