import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';

import 'llm_backend.dart';

/// Real on-device [LlmBackend] backed by `flutter_gemma` (LiteRT-LM), running the
/// profiler-selected Gemma 4 model from a local file (models.md §3.1).
///
/// **Device-only:** every call goes through the native LiteRT runtime, so this
/// adapter is **not** exercised by headless `flutter test` — the orchestration
/// that uses it ([LlmRuntimeCoordinator], `DomainInferenceService`) is tested
/// with fakes. Composed at bootstrap on a qualifying device once the model file
/// is downloaded + SHA-256-verified ([ModelDownloadService] → [ModelStore]);
/// inference correctness / memory / latency are device-verified (VERIFICATION.md).
///
/// `FlutterGemma.initialize()` must have run once at app startup.
class FlutterGemmaLlmBackend implements LlmBackend {
  FlutterGemmaLlmBackend({
    required this.modelPath,
    this.modelType = ModelType.gemma4,
    this.fileType = ModelFileType.task,
    this.maxTokens = 2048,
    this.preferredBackend,
  });

  /// Path to the verified model file on disk (from [ModelStore]).
  final String modelPath;
  final ModelType modelType;
  final ModelFileType fileType;
  final int maxTokens;
  final PreferredBackend? preferredBackend;

  InferenceModel? _model;
  bool _installed = false;

  @override
  Future<bool> isAvailable() async => File(modelPath).existsSync();

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    final model = await _ensureModel();
    final session = await model.createSession();
    try {
      await session.addQueryChunk(Message.text(text: prompt, isUser: true));
      return await session.getResponse();
    } finally {
      await session.close();
    }
  }

  /// Installs the model file (idempotent) and loads it into an [InferenceModel].
  Future<InferenceModel> _ensureModel() async {
    if (!File(modelPath).existsSync()) {
      throw const LlmUnavailableException('model file is not present on disk');
    }
    if (!_installed) {
      await FlutterGemma.installModel(
        modelType: modelType,
        fileType: fileType,
      ).fromFile(modelPath).install();
      _installed = true;
    }
    return _model ??= await FlutterGemma.getActiveModel(
      maxTokens: maxTokens,
      preferredBackend: preferredBackend,
    );
  }

  /// Releases the native model. Safe to call repeatedly.
  Future<void> dispose() async {
    await _model?.close();
    _model = null;
  }
}
