import 'llm_backend.dart';
import 'model_manifest.dart';
import 'profiler_state.dart';
import 'tier_catalog.dart';

/// Brings the Tier-4 engine to a ready state on demand (blueprint §4.7): resolve
/// the profiler-selected [ModelVariant] from the verified manifest → ensure the
/// model file is downloaded + SHA-256-verified → build the on-device
/// [LlmBackend]. Returns [UnavailableLlmBackend] (graceful) for floor/no-tier
/// devices or when no selection exists. Pure-Dart + fully fake-tested; the real
/// download + `flutter_gemma` backend are injected at bootstrap.
class LlmRuntimeCoordinator {
  LlmRuntimeCoordinator({
    required Future<ProfilerState?> Function() loadState,
    required Future<ModelManifest> Function() loadManifest,
    required Future<String> Function(ModelVariant variant) ensureModel,
    required LlmBackend Function(String modelPath) backendFactory,
  }) : _loadState = loadState,
       _loadManifest = loadManifest,
       _ensureModel = ensureModel,
       _backendFactory = backendFactory;

  final Future<ProfilerState?> Function() _loadState;
  final Future<ModelManifest> Function() _loadManifest;
  final Future<String> Function(ModelVariant) _ensureModel;
  final LlmBackend Function(String) _backendFactory;

  /// Whether a Tier-4 model is selected for this device (not floor). Cheap —
  /// reads the persisted profiler state only.
  Future<bool> isEligible() async {
    final state = await _loadState();
    return state != null && !state.isFloor && state.modelId != null;
  }

  /// Downloads/verifies the model if needed and returns a ready [LlmBackend], or
  /// [UnavailableLlmBackend] when the device is ineligible / the variant is
  /// missing from the manifest. May transfer ~1 GB on first run — call from an
  /// explicit user action ("Enable on-device AI"), not at startup.
  Future<LlmBackend> activate() async {
    final state = await _loadState();
    if (state == null || state.isFloor || state.modelId == null) {
      return const UnavailableLlmBackend();
    }
    final manifest = await _loadManifest();
    final variant = _variantFor(manifest.catalog, state);
    if (variant == null) return const UnavailableLlmBackend();

    final path = await _ensureModel(variant);
    return _backendFactory(path);
  }

  /// Finds the [ModelVariant] for the profiler's selected tier + variant.
  ModelVariant? _variantFor(TierCatalog catalog, ProfilerState state) {
    for (final tier in catalog.tiers) {
      if (tier.tier == state.tier) return tier.variants[state.variant];
    }
    return null;
  }
}
