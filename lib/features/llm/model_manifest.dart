import 'tier_catalog.dart';

/// A Tier 3 PII-NER detection model served by the same signed manifest
/// (ADR-022 / models.md §3.4). The smallest variant is bundled as an offline
/// baseline; larger variants are device-tiered downloaded upgrades.
class DetectionModel {
  const DetectionModel({
    required this.modelId,
    required this.role,
    required this.runtime,
    required this.sizeBytes,
    required this.licenseBundle,
    this.sha256,
    this.url,
    this.bundled = false,
    this.minScore,
  });

  final String modelId;

  /// e.g. `tier3_baseline_bundled` or `tier3_upgrade`.
  final String role;
  final String runtime;
  final int sizeBytes;
  final String licenseBundle;
  final String? sha256;
  final String? url;
  final bool bundled;

  /// Capability score required to offer this upgrade (null for the baseline).
  final int? minScore;

  factory DetectionModel.fromJson(Map<String, dynamic> json) => DetectionModel(
    modelId: json['model_id'] as String,
    role: json['role'] as String,
    runtime: json['runtime'] as String,
    sizeBytes: json['size_bytes'] as int,
    licenseBundle: json['license_bundle'] as String,
    sha256: json['sha256'] as String?,
    url: json['url'] as String?,
    bundled: json['bundled'] as bool? ?? false,
    minScore: json['min_score'] as int?,
  );
}

/// The verified model manifest body (blueprint §4.7 / models.md §5): the Tier 4
/// LLM [TierCatalog] plus the Tier 3 [DetectionModel]s. Only constructed after
/// Ed25519 verification (see `ManifestVerifier`).
class ModelManifest {
  const ModelManifest({required this.catalog, required this.detectionModels});

  final TierCatalog catalog;
  final List<DetectionModel> detectionModels;

  int get version => catalog.version;

  factory ModelManifest.fromJson(Map<String, dynamic> json) => ModelManifest(
    catalog: TierCatalog.fromJson(json),
    detectionModels: [
      for (final m in (json['detection_models'] as List<dynamic>? ?? []))
        DetectionModel.fromJson(m as Map<String, dynamic>),
    ],
  );
}
