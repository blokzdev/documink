import 'device_capabilities.dart';

/// The two variant slots every qualifying tier offers (blueprint §4.7). The
/// recommendation always defaults to [balanced]; [specialized] is opt-in.
enum VariantKind {
  balanced('balanced'),
  specialized('specialized');

  const VariantKind(this.id);

  final String id;

  static VariantKind fromId(String id) => values.firstWhere(
    (v) => v.id == id,
    orElse: () => throw FormatException('Unknown variant kind: $id'),
  );
}

/// One downloadable model variant within a tier (blueprint §4.7 / models.md §5).
class ModelVariant {
  const ModelVariant({
    required this.modelId,
    required this.runtime,
    required this.sizeBytes,
    required this.licenseBundle,
    this.sha256,
    this.url,
    this.padPackName,
    this.benefitLabel,
  });

  final String modelId;
  final String runtime;
  final int sizeBytes;
  final String licenseBundle;

  /// SHA-256 of the model file (absent only for system-passthrough, size 0).
  final String? sha256;

  /// HTTP source (Windows / mirror) or the Android install-time pack name.
  final String? url;
  final String? padPackName;

  /// Required for Specialized variants (the "what you gain" copy).
  final String? benefitLabel;

  factory ModelVariant.fromJson(Map<String, dynamic> json) => ModelVariant(
    modelId: json['model_id'] as String,
    runtime: json['runtime'] as String,
    sizeBytes: json['size_bytes'] as int,
    licenseBundle: json['license_bundle'] as String,
    sha256: json['sha256'] as String?,
    url: json['url'] as String?,
    padPackName: json['pad_pack_name'] as String?,
    benefitLabel: json['benefit_label'] as String?,
  );
}

/// A capability tier with its score gate, hard requirements, and variants.
class CatalogTier {
  const CatalogTier({
    required this.tier,
    required this.minScore,
    required this.requires,
    required this.optInOnly,
    required this.variants,
  });

  final String tier;
  final int minScore;
  final TierRequirements requires;
  final bool optInOnly;
  final Map<VariantKind, ModelVariant> variants;

  /// Bytes of the largest variant — what the storage-headroom check must clear.
  int get largestVariantBytes =>
      variants.values.map((v) => v.sizeBytes).reduce((a, b) => a > b ? a : b);

  factory CatalogTier.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'] as Map<String, dynamic>;
    return CatalogTier(
      tier: json['tier'] as String,
      minScore: json['min_score'] as int,
      requires: json['requires'] == null
          ? TierRequirements.none
          : TierRequirements.fromJson(json['requires'] as Map<String, dynamic>),
      optInOnly: json['opt_in_only'] as bool? ?? false,
      variants: {
        for (final entry in rawVariants.entries)
          VariantKind.fromId(entry.key): ModelVariant.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      },
    );
  }
}

/// The signed tier catalog (blueprint §4.7 manifest). JSON parsing + Ed25519
/// verification land in 9b; this holds the in-memory shape selection runs on.
class TierCatalog {
  const TierCatalog({required this.version, required this.tiers});

  final int version;
  final List<CatalogTier> tiers;

  factory TierCatalog.fromJson(Map<String, dynamic> json) => TierCatalog(
    version: json['version'] as int,
    tiers: [
      for (final t in (json['tiers'] as List<dynamic>))
        CatalogTier.fromJson(t as Map<String, dynamic>),
    ],
  );
}
