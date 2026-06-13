import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'anonymization_policy.dart';
import 'anonymizer.dart';

/// Path to the bundled default policy (blueprint §4.6).
const String defaultPolicyAsset = 'assets/policy/default_policy.yaml';

/// The default anonymization policy, parsed from the bundled asset. Per-workspace
/// / per-document overrides (from `vault_meta`) layer on via `policy.override(...)`
/// at the call site (wired with the editor UI in Phase 5).
final defaultPolicyProvider = FutureProvider<AnonymizationPolicy>((ref) async {
  final yaml = await rootBundle.loadString(defaultPolicyAsset);
  return AnonymizationPolicy.fromYaml(yaml);
});

/// The operator applier. Reversible operators are wired with the vault-backed
/// resolver in 3b/3c.
final anonymizerProvider = Provider<Anonymizer>((ref) => const Anonymizer());
