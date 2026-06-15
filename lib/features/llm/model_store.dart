import 'dart:io';

/// Resolves on-device storage paths for downloaded Tier-4 model files. Lives in
/// the app-support directory (not the cache dir — the OS must not evict a ~1 GB
/// model the user explicitly downloaded). Injectable with a temp dir in tests.
class ModelStore {
  ModelStore(this._baseDir);

  final Directory _baseDir;

  /// The directory holding model files (`<base>/models`).
  Directory get modelsDir => Directory('${_baseDir.path}/models');

  /// The on-device file for [modelId] (not guaranteed to exist).
  File fileFor(String modelId) => File('${modelsDir.path}/$modelId');

  /// Ensures the models directory exists; returns it.
  Future<Directory> ensureDir() => modelsDir.create(recursive: true);
}
