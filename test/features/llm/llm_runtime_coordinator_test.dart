import 'package:documink/features/llm/device_capability_profiler.dart'
    show noTier;
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/llm/llm_runtime_coordinator.dart';
import 'package:documink/features/llm/model_manifest.dart';
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

ModelManifest _manifest() => ModelManifest.fromJson({
  'version': 1,
  'tiers': [
    {
      'tier': 'standard',
      'min_score': 55,
      'requires': {'min_ram_mb': 4096},
      'variants': {
        'balanced': {
          'model_id': 'gemma-4-e2b-int4',
          'runtime': 'litert_lm',
          'size_bytes': 1200000000,
          'sha256': 'abc123',
          'url': 'https://example/model',
          'license_bundle': 'apache-2.0',
        },
      },
    },
  ],
  'detection_models': <dynamic>[],
});

ProfilerState _state({
  String tier = 'standard',
  String? modelId = 'gemma-4-e2b-int4',
}) => ProfilerState(
  tier: tier,
  variant: VariantKind.balanced,
  modelId: modelId,
  manifestVersion: 1,
  downloadState: DownloadState.notDownloaded,
  score: 60,
  ranAtEpochMs: 0,
  optInAvailable: const [],
);

void main() {
  late List<ModelVariant> ensured;
  late List<String> built;

  LlmRuntimeCoordinator make({ProfilerState? state, ModelManifest? manifest}) {
    ensured = [];
    built = [];
    return LlmRuntimeCoordinator(
      loadState: () async => state,
      loadManifest: () async => manifest ?? _manifest(),
      ensureModel: (variant, {onProgress}) async {
        ensured.add(variant);
        onProgress?.call(1.0);
        return '/models/${variant.modelId}';
      },
      backendFactory: (path) {
        built.add(path);
        return _FakeBackend();
      },
    );
  }

  test(
    'eligible device → downloads selected variant and builds backend',
    () async {
      final c = make(state: _state());
      final backend = await c.activate();

      expect(backend, isA<_FakeBackend>());
      expect(ensured.single.modelId, 'gemma-4-e2b-int4');
      expect(built.single, '/models/gemma-4-e2b-int4');
    },
  );

  test('no profiler state → Unavailable, nothing downloaded', () async {
    final c = make(state: null);
    expect(await c.activate(), isA<UnavailableLlmBackend>());
    expect(ensured, isEmpty);
  });

  test('floor device → Unavailable', () async {
    final c = make(state: _state(tier: noTier, modelId: null));
    expect(await c.activate(), isA<UnavailableLlmBackend>());
    expect(ensured, isEmpty);
  });

  test('selected tier missing from manifest → Unavailable', () async {
    final c = make(state: _state(tier: 'performance'));
    expect(await c.activate(), isA<UnavailableLlmBackend>());
    expect(ensured, isEmpty);
  });

  test('isEligible reflects the persisted state', () async {
    expect(await make(state: _state()).isEligible(), isTrue);
    expect(await make(state: null).isEligible(), isFalse);
    expect(
      await make(state: _state(tier: noTier, modelId: null)).isEligible(),
      isFalse,
    );
  });

  test('activateVariant downloads + builds for an explicit variant', () async {
    final c = make(state: _state());
    final variant = LlmRuntimeCoordinator.variantIn(
      _manifest(),
      'standard',
      VariantKind.balanced,
    )!;
    final backend = await c.activateVariant(variant);
    expect(backend, isA<_FakeBackend>());
    expect(ensured.single.modelId, 'gemma-4-e2b-int4');
  });
}
