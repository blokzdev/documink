import 'dart:io';

import 'package:documink/features/llm/ai_model_controller.dart';
import 'package:documink/features/llm/device_capability_profiler.dart'
    show noTier, FloorReason;
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/llm/model_manifest.dart';
import 'package:documink/features/llm/model_store.dart';
import 'package:documink/features/llm/profiler_state.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBackend implements LlmBackend {
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
        'specialized': {
          'model_id': 'gemma-std-spec',
          'runtime': 'litert_lm',
          'size_bytes': 1300000000,
          'sha256': 'b',
          'url': 'https://e/std-spec',
          'license_bundle': 'apache-2.0',
          'benefit_label': 'Sharper redaction',
        },
      },
    },
    {
      'tier': 'performance',
      'min_score': 90,
      'opt_in_only': true,
      'requires': {'min_ram_mb': 8192},
      'variants': {
        'balanced': {
          'model_id': 'gemma-perf-bal',
          'runtime': 'litert_lm',
          'size_bytes': 4000000000,
          'sha256': 'c',
          'url': 'https://e/perf-bal',
          'license_bundle': 'apache-2.0',
        },
      },
    },
  ],
  'detection_models': <dynamic>[],
});

ProfilerState _state({
  String tier = 'standard',
  VariantKind variant = VariantKind.balanced,
  String? modelId = 'gemma-std-bal',
  DownloadState downloadState = DownloadState.notDownloaded,
  List<String> optInAvailable = const ['performance'],
  FloorReason? floorReason,
}) => ProfilerState(
  tier: tier,
  variant: variant,
  modelId: modelId,
  manifestVersion: 1,
  downloadState: downloadState,
  score: 70,
  ranAtEpochMs: 0,
  optInAvailable: optInAvailable,
  floorReason: floorReason,
);

void main() {
  late Directory tmp;
  late ModelStore store;
  late ProfilerState? current;
  late List<ModelVariant> activated;
  late List<(String, Map<String, dynamic>)> audits;
  late ProfilerState recheckResult;
  late _FakeBackend? lastSet;
  late bool cleared;

  AiModelController make() {
    activated = [];
    audits = [];
    lastSet = null;
    cleared = false;
    return AiModelController(
      loadManifest: () async => _manifest(),
      loadState: () async => current,
      saveState: (s) async => current = s,
      recheckProfile: (m) async {
        current = recheckResult;
        return recheckResult;
      },
      activate: (variant, {onProgress}) async {
        activated.add(variant);
        onProgress?.call(1.0);
        return _FakeBackend();
      },
      setActiveBackend: (b) => lastSet = b as _FakeBackend,
      clearActiveBackend: () => cleared = true,
      modelStore: store,
      recordAudit: (e, m) async => audits.add((e, m)),
    );
  }

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('ai_ctrl_test');
    store = ModelStore(tmp);
    current = _state();
    recheckResult = _state();
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test(
    'enableRecommended downloads, activates, persists ready, audits',
    () async {
      final c = make();
      final next = await c.enableRecommended();

      expect(activated.single.modelId, 'gemma-std-bal');
      expect(lastSet, isNotNull);
      expect(next.downloadState, DownloadState.ready);
      expect(current!.downloadState, DownloadState.ready);
      expect(audits.single.$1, 'model_install');
      expect(audits.single.$2['modelId'], 'gemma-std-bal');
    },
  );

  test(
    'floor device → enableRecommended throws, no audit/activation',
    () async {
      current = _state(
        tier: noTier,
        modelId: null,
        floorReason: FloorReason.insufficientRam,
      );
      final c = make();
      await expectLater(c.enableRecommended(), throwsStateError);
      expect(activated, isEmpty);
      expect(audits, isEmpty);
    },
  );

  test(
    'switchVariant audits variantChange + downloads the new model',
    () async {
      final c = make();
      final next = await c.switchVariant(VariantKind.specialized);

      expect(audits.first.$1, 'variant_change');
      expect(audits.first.$2['to'], 'specialized');
      expect(activated.single.modelId, 'gemma-std-spec');
      expect(next.variant, VariantKind.specialized);
      expect(next.modelId, 'gemma-std-spec');
      expect(next.downloadState, DownloadState.ready);
    },
  );

  test('switchVariant to the current kind is a no-op', () async {
    final c = make();
    final next = await c.switchVariant(VariantKind.balanced);
    expect(activated, isEmpty);
    expect(audits, isEmpty);
    expect(next.variant, VariantKind.balanced);
  });

  test('overrideTier audits tierChange + activates the new tier', () async {
    final c = make();
    final next = await c.overrideTier('performance');

    expect(audits.first.$1, 'tier_change');
    expect(audits.first.$2['to'], 'performance');
    expect(activated.single.modelId, 'gemma-perf-bal');
    expect(next.tier, 'performance');
    expect(next.modelId, 'gemma-perf-bal');
  });

  test('removeModel deletes file, clears backend, audits uninstall', () async {
    await store.ensureDir();
    final f = store.fileFor('gemma-std-bal');
    await f.writeAsString('model-bytes');
    current = _state(downloadState: DownloadState.ready);

    final c = make();
    final next = await c.removeModel();

    expect(await f.exists(), isFalse);
    expect(cleared, isTrue);
    expect(next.downloadState, DownloadState.notDownloaded);
    expect(audits.single.$1, 'model_uninstall');
  });

  test('recheck that changes tier audits tier_change', () async {
    current = _state(); // standard
    recheckResult = _state(
      tier: 'performance',
      modelId: 'gemma-perf-bal',
      optInAvailable: const [],
    );
    final c = make();
    final next = await c.recheck();

    expect(next.tier, 'performance');
    expect(audits.any((a) => a.$1 == 'tier_change'), isTrue);
  });

  test('recheck preserves a ready model when the pick is unchanged', () async {
    await store.ensureDir();
    await store.fileFor('gemma-std-bal').writeAsString('bytes');
    current = _state(downloadState: DownloadState.ready);
    recheckResult = _state(); // same pick, profiler reset to notDownloaded

    final c = make();
    final next = await c.recheck();

    expect(next.downloadState, DownloadState.ready);
    expect(audits, isEmpty); // unchanged tier + variant
  });

  test(
    'recheck does not resurrect ready when the model file is gone',
    () async {
      current = _state(downloadState: DownloadState.ready); // no file on disk
      recheckResult = _state();

      final c = make();
      final next = await c.recheck();

      expect(next.downloadState, DownloadState.notDownloaded);
    },
  );
}
