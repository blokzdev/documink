import 'tier_catalog.dart';

/// Thrown when no model transport is wired (the bare core) or a fetch fails.
class ModelSourceUnavailableException implements Exception {
  const ModelSourceUnavailableException([
    this.message = 'No model source is available',
  ]);
  final String message;
  @override
  String toString() => 'ModelSourceUnavailableException: $message';
}

/// Transport seam for fetching a Tier-4 model file onto the device
/// (models.md §2). The transport is environment-specific — Android = Play Asset
/// Delivery (`padPackName`), Windows V2 = HTTP (`url`) — and device/Play-bound,
/// so the real adapters are composed at bootstrap and device-verified. Pure-Dart
/// orchestration ([ModelDownloadService]) depends only on this interface.
abstract interface class ModelSource {
  /// Fetches [variant]'s model file to a local path and returns it. The returned
  /// file is **unverified** — the caller SHA-256-checks it. [onProgress] reports
  /// received/total bytes (total may be 0 if unknown). Throws
  /// [ModelSourceUnavailableException] on failure.
  Future<String> fetch(
    ModelVariant variant, {
    void Function(int received, int total)? onProgress,
  });
}

/// The safe default until a platform transport is composed at bootstrap: refuses
/// to fetch (fails loud). Mirrors `UnavailableLlmBackend`.
class UnavailableModelSource implements ModelSource {
  const UnavailableModelSource();

  @override
  Future<String> fetch(
    ModelVariant variant, {
    void Function(int received, int total)? onProgress,
  }) async => throw const ModelSourceUnavailableException();
}
