import 'package:yaml/yaml.dart';

import 'operator.dart';

/// Maps entity-type labels to [Operator]s (blueprint §4.6). A user-configurable
/// default policy ships as an asset; per-workspace and per-document overrides
/// layer on top via [override].
class AnonymizationPolicy {
  const AnonymizationPolicy(this._byLabel, {this.fallback = Operator.redact});

  final Map<String, Operator> _byLabel;

  /// Operator for labels not explicitly mapped (privacy-safe default: redact).
  final Operator fallback;

  /// The operator for [label], or [fallback] if unmapped.
  Operator operatorFor(String label) => _byLabel[label] ?? fallback;

  /// All explicit label→operator mappings (unmodifiable).
  Map<String, Operator> get mappings => Map.unmodifiable(_byLabel);

  /// Parses a policy from YAML — a top-level `LABEL: operator_name` map. An
  /// optional `DEFAULT:` key sets [fallback]. Throws [FormatException] on an
  /// unknown operator or malformed document.
  factory AnonymizationPolicy.fromYaml(String source) {
    final doc = loadYaml(source);
    if (doc is! YamlMap) {
      throw const FormatException(
        'Policy YAML must be a map of LABEL: operator',
      );
    }
    final byLabel = <String, Operator>{};
    var fallback = Operator.redact;
    for (final entry in doc.nodes.entries) {
      final label = (entry.key as YamlScalar).value.toString();
      final opName = entry.value.value.toString();
      final op = Operator.fromPolicyName(opName);
      if (label == 'DEFAULT') {
        fallback = op;
      } else {
        byLabel[label] = op;
      }
    }
    return AnonymizationPolicy(byLabel, fallback: fallback);
  }

  /// Returns a new policy with [overrides] layered on top (and an optional new
  /// [fallback]); used for per-workspace / per-document policy.
  AnonymizationPolicy override(
    Map<String, Operator> overrides, {
    Operator? fallback,
  }) {
    return AnonymizationPolicy({
      ..._byLabel,
      ...overrides,
    }, fallback: fallback ?? this.fallback);
  }
}
