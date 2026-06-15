import 'package:flutter_gemma/flutter_gemma.dart';

import 'llm_backend.dart';

/// Production [LlmBackend] backed by `flutter_gemma` (Google's LiteRT-LM),
/// running the profiler-selected model (e.g. Gemma 4 E2B at Standard tier) from
/// a downloaded `.task` file — the model is never bundled in the APK (models.md
/// §2). Loads the **active** model installed via `flutter_gemma`'s installer
/// (Phase 10c downloads + installs it; until then `isAvailable()` is false, so
/// the app degrades gracefully exactly like [UnavailableLlmBackend]).
///
/// **Device-only:** every call goes through platform channels into the native
/// runtime, so this adapter is **not** exercised by headless `flutter test` —
/// the orchestration that depends on the [LlmBackend] seam
/// (`DomainInferenceService`, Mink) is tested with a fake. Wired at bootstrap;
/// model load, inference correctness, memory and latency are device-verified
/// (VERIFICATION.md).
class FlutterGemmaLlmBackend implements LlmBackend {
  FlutterGemmaLlmBackend({
    String? modelFilePath,
    ModelType modelType = ModelType.gemmaIt,
    int maxTokens = 1024,
  }) : _modelFilePath = modelFilePath,
       _modelType = modelType,
       _maxTokens = maxTokens;

  /// Optional `.task` file to install + activate on first use (device
  /// verification before the 10c downloader exists). Normally null — the model
  /// is installed out-of-band and discovered via the active-model registry.
  final String? _modelFilePath;
  final ModelType _modelType;
  final int _maxTokens;

  InferenceModel? _model;

  Future<InferenceModel?> _ensureModel() async {
    if (_model != null) return _model;
    if (!FlutterGemma.hasActiveModel()) {
      final path = _modelFilePath;
      if (path == null) return null; // nothing installed and nothing to install
      await FlutterGemma.installModel(
        modelType: _modelType,
      ).fromFile(path).install();
    }
    return _model = await FlutterGemma.getActiveModel(maxTokens: _maxTokens);
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return FlutterGemma.hasActiveModel() || _modelFilePath != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    final model = await _ensureModel();
    if (model == null) throw const LlmUnavailableException();
    final session = await model.createSession();
    try {
      await session.addQueryChunk(Message.text(text: prompt, isUser: true));
      return await session.getResponse();
    } finally {
      await session.close();
    }
  }

  /// Releases the loaded model (and its weights). Call on app teardown.
  Future<void> dispose() async => _model?.close();
}
