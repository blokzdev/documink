import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:documink/data/app_database.dart';
import 'package:documink/features/llm/model_download_service.dart';
import 'package:documink/features/llm/model_hash_verifier.dart';
import 'package:documink/features/llm/model_source.dart';
import 'package:documink/features/llm/model_store.dart';
import 'package:documink/features/llm/profiler_repository.dart';
import 'package:documink/features/llm/profiler_state.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [ModelSource] that writes fixed bytes to a temp file and returns its path,
/// recording how many times it was invoked.
class _FakeModelSource implements ModelSource {
  _FakeModelSource(this._bytes, this._dir);
  final List<int> _bytes;
  final Directory _dir;
  int calls = 0;

  @override
  Future<String> fetch(
    ModelVariant variant, {
    void Function(int received, int total)? onProgress,
  }) async {
    calls++;
    onProgress?.call(_bytes.length, _bytes.length);
    final src = File('${_dir.path}/fetched_${variant.modelId}');
    await src.writeAsBytes(_bytes);
    return src.path;
  }
}

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late ProfilerRepository profiler;
  late ModelStore store;

  final bytes = utf8.encode('hello documink gemma model bytes');
  final goodHash = sha256.convert(bytes).toString();

  ModelVariant variant({String? sha}) => ModelVariant(
    modelId: 'gemma-4-e2b-int4',
    runtime: 'litert_lm',
    sizeBytes: bytes.length,
    licenseBundle: 'apache-2.0',
    sha256: sha,
  );

  Future<void> seedProfiler(DownloadState state) => profiler.save(
    ProfilerState(
      tier: 'standard',
      variant: VariantKind.balanced,
      modelId: 'gemma-4-e2b-int4',
      manifestVersion: 1,
      downloadState: state,
      score: 60,
      ranAtEpochMs: 0,
      optInAvailable: const [],
    ),
  );

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('dm_model_dl');
    db = AppDatabase(NativeDatabase.memory());
    profiler = ProfilerRepository(db);
    store = ModelStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  ModelDownloadService service(_FakeModelSource source) =>
      ModelDownloadService(source: source, store: store, profiler: profiler);

  test('downloads, verifies, stores, and marks ready', () async {
    await seedProfiler(DownloadState.notDownloaded);
    final source = _FakeModelSource(bytes, tempDir);

    final path = await service(source).ensureModel(variant(sha: goodHash));

    expect(path, store.fileFor('gemma-4-e2b-int4').path);
    expect(await File(path).readAsBytes(), bytes);
    expect(source.calls, 1);
    expect((await profiler.load())!.downloadState, DownloadState.ready);
  });

  test('skips the download when already present and verified', () async {
    await seedProfiler(DownloadState.notDownloaded);
    await store.ensureDir();
    await store.fileFor('gemma-4-e2b-int4').writeAsBytes(bytes);
    final source = _FakeModelSource(bytes, tempDir);

    final path = await service(source).ensureModel(variant(sha: goodHash));

    expect(path, store.fileFor('gemma-4-e2b-int4').path);
    expect(source.calls, 0); // never fetched
    expect((await profiler.load())!.downloadState, DownloadState.ready);
  });

  test('hash mismatch → deletes partial, marks failed, throws', () async {
    await seedProfiler(DownloadState.notDownloaded);
    final source = _FakeModelSource(bytes, tempDir);

    await expectLater(
      service(source).ensureModel(variant(sha: 'deadbeef' * 8)),
      throwsA(isA<ModelHashMismatchException>()),
    );
    expect(await store.fileFor('gemma-4-e2b-int4').exists(), isFalse);
    expect(
      await File('${tempDir.path}/fetched_gemma-4-e2b-int4').exists(),
      isFalse,
    );
    expect((await profiler.load())!.downloadState, DownloadState.failed);
  });

  test(
    'a null manifest hash is rejected (never activate unverified)',
    () async {
      await seedProfiler(DownloadState.notDownloaded);
      expect(
        service(_FakeModelSource(bytes, tempDir)).ensureModel(variant()),
        throwsStateError,
      );
    },
  );

  test('forwards fractional progress', () async {
    await seedProfiler(DownloadState.notDownloaded);
    final seen = <double>[];
    await service(
      _FakeModelSource(bytes, tempDir),
    ).ensureModel(variant(sha: goodHash), onProgress: seen.add);
    expect(seen, contains(1.0)); // fake reports full bytes
  });

  group('ModelHashVerifier.matchesFile (streaming)', () {
    test('matches the correct hash and rejects a wrong one', () async {
      final f = File('${tempDir.path}/blob')..writeAsBytesSync(bytes);
      const verifier = ModelHashVerifier();
      expect(await verifier.matchesFile(f, goodHash), isTrue);
      expect(await verifier.matchesFile(f, 'aa' * 32), isFalse);
    });
  });
}
