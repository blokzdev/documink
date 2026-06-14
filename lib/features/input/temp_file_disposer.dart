import 'dart:io';

/// Deletes a transient file we created (e.g. a rasterized PDF page rendered only
/// to feed OCR). Behind an interface so the ingestion orchestrator can assert
/// cleanup in tests with a recording fake.
///
/// Privacy: rasterized PDF pages contain PII. They live in the app-private cache
/// ([getTemporaryDirectory]) but must not linger there after OCR — they are
/// removed immediately (the orchestrator calls this in a `finally`).
abstract interface class TempFileDisposer {
  Future<void> dispose(String path);
}

/// Real [TempFileDisposer] (default). Best-effort delete: a missing file is a
/// no-op and any I/O error is swallowed — cleanup must never break ingestion.
class IoTempFileDisposer implements TempFileDisposer {
  const IoTempFileDisposer();

  @override
  Future<void> dispose(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort: the OS will eventually evict the cache entry anyway.
    }
  }
}
