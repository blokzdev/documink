import 'dart:io';

import 'package:documink/features/llm/ai_activation_service.dart';
import 'package:documink/features/llm/device_capability_profiler.dart'
    show noTier, FloorReason;
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/llm/model_manifest.dart';
import 'package:documink/features/llm/model_store.dart';
import 'package:documink/features/llm/profiler_state.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBackend implements LlmBackend {
  _FakeBackend(this.path);
  final String path;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async =>
      'ok';
}

ModelManifest _manifest({int version = 1}) => ModelManifest.fromJson({
  'version': version,
  'tiers': [
    {
      'tier': 'standard',
      'min_score': 55,
      'requires': {'min_ram_mb': 4096},
      'variants': {
        'balanced': {
          'model_id': 'gemma-std-bal',
          'runtime': 'litert_lm',
          'size_bytes': 1200000000,
          'sha256': 'a',
          'url': 'https://e/std-bal',
          'license_bundle': 'apache-2.0',
        },
      },
    },
  ],
  'detection_models': <dynamic>[],
});

ProfilerState _state({
  String tier = 'standard',
  String? modelId = 'gemma-std-bal',
  DownloadState downloadState = DownloadState.ready,
  int manifestVersion = 1,
  FloorReason? floorReason,
}) => ProfilerState(
  tier: tier,
  variant: VariantKind.balanced,
  modelId: modelId,
  manifestVersion: manifestVersion,
  downloadState: downloadState,
  score: 70,
  ranAtEpochMs: 0,
  optInAvailable: const [],
  floorReason: floorReason,
);

void main() {
  late Directory tmp;
  late ModelStore store;
  late ProfilerState? current;
  late List<(String, Map<String, dynamic>)> audits;
  late _FakeBackend? activated;

  AiActivationService make({int manifestVersion = 1}) {
    audits = [];
    activated = null;
    return AiActivationService(
      loadState: () async => current,
      saveState: (s) async => current = s,
      loadManifest: () async => _manifest(version: manifestVersion),
      modelStore: store,
      backendFactory: (path) => _FakeBackend(path),
      setActiveBackend: (b) => activated = b as _FakeBackend,
      recordAudit: (e, m) async => audits.add((e, m)),
    );
  }

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('ai_act_test');
    store = ModelStore(tmp);
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test(
    'ready + file present → restores the backend from the stored path',
    () async {
      await store.ensureDir();
      await store.fileFor('gemma-std-bal').writeAsString('bytes');
      current = _state();

      await make().restoreOnUnlock();

      expect(activated, isNotNull);
      expect(activated!.path, store.fileFor('gemma-std-bal').path);
    },
  );

  test('notDownloaded → does not restore', () async {
    current = _state(downloadState: DownloadState.notDownloaded);
    await make().restoreOnUnlock();
    expect(activated, isNull);
  });

  test('floor → does not restore', () async {
    current = _state(
      tier: noTier,
      modelId: null,
      floorReason: FloorReason.insufficientRam,
    );
    await make().restoreOnUnlock();
    expect(activated, isNull);
  });

  test('ready but file missing → marks notDownloaded, no restore', () async {
    current = _state(); // no file written
    await make().restoreOnUnlock();
    expect(activated, isNull);
    expect(current!.downloadState, DownloadState.notDownloaded);
  });

  test(
    'manifest version bump → audits manifestUpdate once + advances version',
    () async {
      await store.ensureDir();
      await store.fileFor('gemma-std-bal').writeAsString('bytes');
      current = _state(manifestVersion: 1);

      await make(manifestVersion: 2).restoreOnUnlock();

      expect(audits.single.$1, 'manifest_update');
      expect(audits.single.$2, {'from': 1, 'to': 2});
      expect(current!.manifestVersion, 2);
      expect(activated, isNotNull); // still restores the ready model
    },
  );

  test('no state → no-op', () async {
    current = null;
    await make().restoreOnUnlock();
    expect(activated, isNull);
    expect(audits, isEmpty);
  });
}
