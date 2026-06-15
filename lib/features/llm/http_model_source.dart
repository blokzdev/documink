import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'model_source.dart';
import 'tier_catalog.dart';

/// [ModelSource] that streams a model file over HTTP from the manifest `url`
/// (models.md §2.2 — Windows/dev/mirror path; also used for the on-device
/// verification spike on Android). Streams to a temp file and reports progress;
/// the caller ([ModelDownloadService]) SHA-256-verifies and moves it into
/// [ModelStore]. **Device/desktop-only** (real network + filesystem) — not
/// exercised by headless tests; the orchestration is fake-tested.
class HttpModelSource implements ModelSource {
  const HttpModelSource();

  @override
  Future<String> fetch(
    ModelVariant variant, {
    void Function(int received, int total)? onProgress,
  }) async {
    final url = variant.url;
    if (url == null || url.isEmpty) {
      throw const ModelSourceUnavailableException(
        'variant has no download url',
      );
    }
    final tmpDir = await getTemporaryDirectory();
    final dest = File('${tmpDir.path}/${variant.modelId}.download');

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw ModelSourceUnavailableException('HTTP ${response.statusCode}');
      }
      final total = response.contentLength; // -1 if unknown
      var received = 0;
      final sink = dest.openWrite();
      try {
        await for (final chunk in response) {
          received += chunk.length;
          sink.add(chunk);
          onProgress?.call(received, total < 0 ? 0 : total);
        }
      } finally {
        await sink.close();
      }
      return dest.path;
    } finally {
      client.close();
    }
  }
}
