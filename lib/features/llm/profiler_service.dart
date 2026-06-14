import 'device_capability_profiler.dart';
import 'device_signal_collector.dart';
import 'model_manifest.dart';
import 'profiler_repository.dart';
import 'profiler_state.dart';
import 'tier_catalog.dart';

/// Orchestrates the device-capability profiler run (blueprint §4.7): collect
/// local signals → select a tier against the verified manifest → persist the
/// outcome. Runs once at onboarding and on the Settings "Re-check my device"
/// action. The manifest is passed in already Ed25519-verified (9b).
class ProfilerService {
  ProfilerService({
    required DeviceSignalCollector collector,
    required ProfilerRepository repository,
    DeviceCapabilityProfiler profiler = const DeviceCapabilityProfiler(),
  }) : _collector = collector,
       _repository = repository,
       _profiler = profiler;

  final DeviceSignalCollector _collector;
  final ProfilerRepository _repository;
  final DeviceCapabilityProfiler _profiler;

  /// Collects signals, selects a tier, persists and returns the new state.
  /// [now] is injectable for deterministic tests.
  Future<ProfilerState> runProfile(
    ModelManifest manifest, {
    DateTime? now,
  }) async {
    final caps = await _collector.collect();
    final selection = _profiler.selectTier(caps, manifest.catalog);

    final state = ProfilerState(
      tier: selection.recommendedTier,
      variant: selection.recommendedVariant,
      modelId: _balancedModelId(manifest, selection.recommendedTier),
      manifestVersion: manifest.version,
      downloadState: DownloadState.notDownloaded,
      score: selection.deviceScore,
      ranAtEpochMs: (now ?? DateTime.now()).millisecondsSinceEpoch,
      optInAvailable: selection.optInAvailable,
      floorReason: selection.floorReason,
    );
    await _repository.save(state);
    return state;
  }

  /// Alias for the Settings "Re-check my device" action (§4.7).
  Future<ProfilerState> recheck(ModelManifest manifest, {DateTime? now}) =>
      runProfile(manifest, now: now);

  /// The last persisted state, or null if the profiler hasn't run.
  Future<ProfilerState?> loadState() => _repository.load();

  String? _balancedModelId(ModelManifest manifest, String tierId) {
    if (tierId == noTier) return null;
    final tier = manifest.catalog.tiers
        .where((t) => t.tier == tierId)
        .firstOrNull;
    return tier?.variants[VariantKind.balanced]?.modelId;
  }
}

extension<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
