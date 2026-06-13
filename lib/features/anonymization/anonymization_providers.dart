import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/vault_providers.dart';
import 'anonymization_policy.dart';
import 'anonymization_service.dart';
import 'anonymizer.dart';
import 'reversible_operators.dart';

/// Path to the bundled default policy (blueprint §4.6).
const String defaultPolicyAsset = 'assets/policy/default_policy.yaml';

/// The default anonymization policy, parsed from the bundled asset. Per-workspace
/// / per-document overrides (from `vault_meta`) layer on via `policy.override(...)`
/// at the call site (wired with the editor UI in Phase 5).
final defaultPolicyProvider = FutureProvider<AnonymizationPolicy>((ref) async {
  final yaml = await rootBundle.loadString(defaultPolicyAsset);
  return AnonymizationPolicy.fromYaml(yaml);
});

/// The operator applier (irreversible operators).
final anonymizerProvider = Provider<Anonymizer>((ref) => const Anonymizer());

/// Reversible operators backed by the unlocked vault's `TokenCrypto`. Recomputes
/// on lock/unlock; reading it while the vault is locked throws (the vault getter
/// throws), matching `appDatabaseProvider`.
final reversibleOperatorsProvider = Provider<ReversibleOperators>((ref) {
  ref.watch(vaultServiceProvider);
  final crypto = ref.read(vaultServiceProvider.notifier).tokenCrypto;
  return ReversibleOperators(crypto);
});

/// End-to-end anonymization (irreversible + reversible). Requires an unlocked
/// vault for the reversible operators.
final anonymizationServiceProvider = Provider<AnonymizationService>((ref) {
  return AnonymizationService(
    ref.watch(anonymizerProvider),
    ref.watch(reversibleOperatorsProvider),
  );
});
