import 'device_capabilities.dart';
import 'tier_catalog.dart';

/// Sentinel tier id when no tier auto-qualifies (the "floor" — Mink runs in
/// constrained informational mode; detection Tiers 1–3 still work, §4.7).
const String noTier = 'none';

/// Storage headroom multiplier over a tier's largest variant (§4.7: 20%).
const double storageHeadroom = 1.2;

/// Why no tier auto-qualified (drives the floor UX copy, §4.7).
enum FloorReason {
  /// Capability score below every non-opt-in tier's `min_score`.
  insufficientScore,

  /// Score met, but a tier's `min_ram_mb` gate failed.
  insufficientRam,

  /// Score met, but free storage (incl. 20% headroom) was too small.
  insufficientStorage,

  /// The catalog has no auto (non-opt-in) tiers at all.
  noQualifyingTier,
}

/// The profiler result persisted to `vault_meta` and shown at onboarding (§4.7).
class TierSelection {
  const TierSelection({
    required this.recommendedTier,
    required this.recommendedVariant,
    required this.optInAvailable,
    required this.deviceScore,
    this.floorReason,
  });

  final String recommendedTier;
  final VariantKind recommendedVariant;
  final List<String> optInAvailable;
  final double deviceScore;

  /// Non-null only when [recommendedTier] is [noTier].
  final FloorReason? floorReason;

  bool get isFloor => recommendedTier == noTier;
}

/// Device-agnostic, no-ceiling tier selection (blueprint §4.7). Pure logic over
/// locally collected [DeviceCapabilities] and a (verified) [TierCatalog]; the
/// native signal collection and the Ed25519 manifest verification live in their
/// own layers.
class DeviceCapabilityProfiler {
  const DeviceCapabilityProfiler();

  /// Selects the highest auto-qualifying tier (Balanced variant) and surfaces
  /// any opt-in tiers, per §4.7's algorithm.
  TierSelection selectTier(DeviceCapabilities caps, TierCatalog catalog) {
    final score = caps.capabilityScore;

    final qualifying = catalog.tiers.where((t) {
      return score >= t.minScore &&
          caps.meetsHardRequirements(t.requires) &&
          caps.freeStorageBytes >= t.largestVariantBytes * storageHeadroom;
    }).toList();

    final auto = qualifying.where((t) => !t.optInOnly).toList()
      ..sort((a, b) => b.minScore.compareTo(a.minScore));
    final autoTier = auto.isEmpty ? null : auto.first;

    final optIn = qualifying.where((t) => t.optInOnly).toList()
      ..sort((a, b) => b.minScore.compareTo(a.minScore));

    return TierSelection(
      recommendedTier: autoTier?.tier ?? noTier,
      recommendedVariant: VariantKind.balanced, // always default to Balanced
      optInAvailable: optIn.map((t) => t.tier).toList(growable: false),
      deviceScore: score,
      floorReason: autoTier == null ? _floorReason(caps, catalog, score) : null,
    );
  }

  /// Diagnoses why no auto tier qualified, against the easiest-to-qualify
  /// (lowest `min_score`) non-opt-in tier.
  FloorReason _floorReason(
    DeviceCapabilities caps,
    TierCatalog catalog,
    double score,
  ) {
    final autoTiers = catalog.tiers.where((t) => !t.optInOnly).toList()
      ..sort((a, b) => a.minScore.compareTo(b.minScore));
    if (autoTiers.isEmpty) return FloorReason.noQualifyingTier;

    final lowest = autoTiers.first;
    if (score < lowest.minScore) return FloorReason.insufficientScore;

    // Score met but the lowest tier still didn't qualify: requirements/storage.
    final req = lowest.requires;
    if (req.minRamMb != null && caps.ramBytes < req.minRamMb! * 1e6) {
      return FloorReason.insufficientRam;
    }
    if (caps.freeStorageBytes < lowest.largestVariantBytes * storageHeadroom) {
      return FloorReason.insufficientStorage;
    }
    if (req.minStorageMb != null &&
        caps.freeStorageBytes < req.minStorageMb! * 1e6) {
      return FloorReason.insufficientStorage;
    }
    return FloorReason.noQualifyingTier;
  }
}
