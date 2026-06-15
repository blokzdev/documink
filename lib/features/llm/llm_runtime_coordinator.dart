import 'llm_backend.dart';
import 'model_manifest.dart';
import 'profiler_state.dart';
import 'tier_catalog.dart';

/// Brings the Tier-4 engine to a ready state on demand (blueprint §4.7): resolve
/// a [ModelVariant] from the verified manifest → ensure the model file is
/// downloaded + SHA-256-verified → build the on-device [LlmBackend]. Returns
/// [UnavailableLlmBackend] (graceful) for floor/no-tier devices or a missing
/// variant. Pure-Dart + fully fake-tested; the real download + `flutter_gemma`
/// backend are injected at bootstrap.
class LlmRuntimeCoordinator {
  LlmRuntimeCoordinator({
    required Future<ProfilerState?> Function() loadState,
    required Future<ModelManifest> Function() loadManifest,
    required Future<String> Function(
      ModelVariant variant, {
      void Function(double progress)? onProgress,
    })
    ensureModel,
    required LlmBackend Function(String modelPath) backendFactory,
  }) : _loadState = loadState,
       _loadManifest = loadManifest,
       _ensureModel = ensureModel,
       _backendFactory = backendFactory;

  final Future<ProfilerState?> Function() _loadState;
  final Future<ModelManifest> Function() _loadManifest;
  final Future<String> Function(
    ModelVariant variant, {
    void Function(double progress)? onProgress,
  })
  _ensureModel;
  final LlmBackend Function(String) _backendFactory;

  /// Builds an [LlmBackend] from a local model path (the bootstrap-wired
  /// `flutter_gemma` factory). Exposed so [AiActivationService] can rebuild the
  /// backend on unlock without re-downloading.
  LlmBackend Function(String modelPath) get backendFactory => _backendFactory;

  /// Whether a Tier-4 model is selected for this device (not floor). Cheap —
  /// reads the persisted profiler state only.
  Future<bool> isEligible() async {
    final state = await _loadState();
    return state != null && !state.isFloor && state.modelId != null;
  }

  /// Profiler-driven activation: pick the selected tier+variant and activate it.
  /// Returns [UnavailableLlmBackend] when ineligible or the variant is missing.
  Future<LlmBackend> activate({
    void Function(double progress)? onProgress,
  }) async {
    final state = await _loadState();
    if (state == null || state.isFloor || state.modelId == null) {
      return const UnavailableLlmBackend();
    }
    final manifest = await _loadManifest();
    final variant = _variantFor(manifest.catalog, state);
    if (variant == null) return const UnavailableLlmBackend();
    return activateVariant(variant, onProgress: onProgress);
  }

  /// Activates a specific [variant]: download + verify the model, then build the
  /// backend. (Used directly by the device-verification flow that targets a
  /// known tier without the profiler.) May transfer ~1 GB on first run.
  Future<LlmBackend> activateVariant(
    ModelVariant variant, {
    void Function(double progress)? onProgress,
  }) async {
    final path = await _ensureModel(variant, onProgress: onProgress);
    return _backendFactory(path);
  }

  /// The [ModelVariant] for [tier]+[variant] in the verified manifest, or null.
  static ModelVariant? variantIn(
    ModelManifest manifest,
    String tier,
    VariantKind variant,
  ) {
    for (final t in manifest.catalog.tiers) {
      if (t.tier == tier) return t.variants[variant];
    }
    return null;
  }

  ModelVariant? _variantFor(TierCatalog catalog, ProfilerState state) {
    for (final tier in catalog.tiers) {
      if (tier.tier == state.tier) return tier.variants[state.variant];
    }
    return null;
  }
}
