import 'dart:io';

import 'model_hash_verifier.dart';
import 'model_source.dart';
import 'model_store.dart';
import 'profiler_repository.dart';
import 'profiler_state.dart';
import 'tier_catalog.dart';

/// Ensures the profiler-selected Tier-4 model file is present locally and
/// **SHA-256-verified** before the runtime loads it (blueprint §4.7 / models.md
/// §2). Transport-agnostic: fetching goes through the [ModelSource] seam (PAD on
/// Android, HTTP on Windows). Persists [DownloadState] via [ProfilerRepository]
/// so the UI and the LLM backend can gate on readiness.
class ModelDownloadService {
  ModelDownloadService({
    required ModelSource source,
    required ModelStore store,
    required ProfilerRepository profiler,
    ModelHashVerifier verifier = const ModelHashVerifier(),
  }) : _source = source,
       _store = store,
       _profiler = profiler,
       _verifier = verifier;

  final ModelSource _source;
  final ModelStore _store;
  final ProfilerRepository _profiler;
  final ModelHashVerifier _verifier;

  /// Returns the local path of the verified model file for [variant], fetching
  /// it via the [ModelSource] if needed. Skips the download when the file is
  /// already present and hash-verified. On hash mismatch or any fetch error the
  /// partial file is removed, [DownloadState.failed] is persisted, and the error
  /// rethrows — an unverified model is **never** activated.
  Future<String> ensureModel(
    ModelVariant variant, {
    void Function(double progress)? onProgress,
  }) async {
    final expected = variant.sha256;
    if (expected == null || expected.isEmpty) {
      throw StateError(
        'Model ${variant.modelId} has no SHA-256 in the manifest',
      );
    }
    await _store.ensureDir();
    final dest = _store.fileFor(variant.modelId);

    // Already downloaded and verified — nothing to do.
    if (await dest.exists() && await _verifier.matchesFile(dest, expected)) {
      await _setState(DownloadState.ready);
      return dest.path;
    }

    await _setState(DownloadState.downloading);
    try {
      final fetchedPath = await _source.fetch(
        variant,
        onProgress: (received, total) =>
            onProgress?.call(total <= 0 ? 0 : received / total),
      );
      final fetched = File(fetchedPath);

      if (!await _verifier.matchesFile(fetched, expected)) {
        await _deleteQuietly(fetched);
        await _setState(DownloadState.failed);
        throw ModelHashMismatchException(
          expected: expected.toLowerCase(),
          actual: 'mismatch',
        );
      }

      // Move the verified file into the store path (if not already there).
      if (fetched.absolute.path != dest.absolute.path) {
        await _deleteQuietly(dest);
        try {
          await fetched.rename(dest.path);
        } on FileSystemException {
          // rename() fails across filesystems (e.g. temp dir → app-support on a
          // different mount); fall back to copy + delete.
          await fetched.copy(dest.path);
          await _deleteQuietly(fetched);
        }
      }
      await _setState(DownloadState.ready);
      return dest.path;
    } catch (_) {
      await _setState(DownloadState.failed);
      rethrow;
    }
  }

  Future<void> _setState(DownloadState state) async {
    final current = await _profiler.load();
    if (current == null) return; // profiler hasn't run yet — nothing to update
    if (current.downloadState == state) return;
    await _profiler.save(current.copyWith(downloadState: state));
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // best-effort cleanup
    }
  }
}
