import 'device_capability_profiler.dart';
import 'tier_catalog.dart';

/// Download lifecycle of the selected model (blueprint §4.7 `llm_download_state`).
enum DownloadState { notDownloaded, downloading, ready, failed }

/// Desktop-only response preference that nudges the recommendation ±1 tier at
/// onboarding (blueprint §4.7 `llm_user_preference`). Applied in the onboarding
/// UI (Phase 5); persisted here.
enum UserPreference { faster, balanced, accurate }

/// The persisted profiler outcome (blueprint §4.7 `vault_meta` additions),
/// stored as a single JSON document. Mirrors `TierSelection` plus download +
/// user-choice state.
class ProfilerState {
  const ProfilerState({
    required this.tier,
    required this.variant,
    required this.modelId,
    required this.manifestVersion,
    required this.downloadState,
    required this.score,
    required this.ranAtEpochMs,
    required this.optInAvailable,
    this.userPreference,
    this.optInTierEnabled = false,
    this.floorReason,
  });

  final String tier; // recommended tier id, or `noTier`
  final VariantKind variant;
  final String? modelId; // null at the floor
  final int manifestVersion;
  final DownloadState downloadState;
  final double score;
  final int ranAtEpochMs;
  final List<String> optInAvailable;
  final UserPreference? userPreference;
  final bool optInTierEnabled;
  final FloorReason? floorReason;

  bool get isFloor => tier == noTier;

  ProfilerState copyWith({
    DownloadState? downloadState,
    UserPreference? userPreference,
    bool? optInTierEnabled,
  }) => ProfilerState(
    tier: tier,
    variant: variant,
    modelId: modelId,
    manifestVersion: manifestVersion,
    downloadState: downloadState ?? this.downloadState,
    score: score,
    ranAtEpochMs: ranAtEpochMs,
    optInAvailable: optInAvailable,
    userPreference: userPreference ?? this.userPreference,
    optInTierEnabled: optInTierEnabled ?? this.optInTierEnabled,
    floorReason: floorReason,
  );

  Map<String, dynamic> toJson() => {
    'llm_tier': tier,
    'llm_variant': variant.id,
    'llm_model_id': modelId,
    'llm_model_version': manifestVersion,
    'llm_download_state': downloadState.name,
    'llm_profiler_score': score,
    'llm_profiler_ran_at': ranAtEpochMs,
    'llm_opt_in_available': optInAvailable,
    'llm_user_preference': userPreference?.name,
    'llm_opt_in_tier_enabled': optInTierEnabled,
    'llm_floor_reason': floorReason?.name,
  };

  factory ProfilerState.fromJson(Map<String, dynamic> json) => ProfilerState(
    tier: json['llm_tier'] as String,
    variant: VariantKind.fromId(json['llm_variant'] as String),
    modelId: json['llm_model_id'] as String?,
    manifestVersion: json['llm_model_version'] as int,
    downloadState: DownloadState.values.byName(
      json['llm_download_state'] as String,
    ),
    score: (json['llm_profiler_score'] as num).toDouble(),
    ranAtEpochMs: json['llm_profiler_ran_at'] as int,
    optInAvailable: [
      for (final t in (json['llm_opt_in_available'] as List<dynamic>))
        t as String,
    ],
    userPreference: json['llm_user_preference'] == null
        ? null
        : UserPreference.values.byName(json['llm_user_preference'] as String),
    optInTierEnabled: json['llm_opt_in_tier_enabled'] as bool? ?? false,
    floorReason: json['llm_floor_reason'] == null
        ? null
        : FloorReason.values.byName(json['llm_floor_reason'] as String),
  );
}
