import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_service_providers.dart';
import 'vault_service.dart';

/// The vault database file. Has no default: production wires it at bootstrap
/// (Phase 5, via `path_provider`'s application-support directory) and tests
/// override it with a temp file. Reading it before an override is wired is a
/// programming error.
final vaultFileProvider = Provider<File>((ref) {
  throw UnimplementedError(
    'vaultFileProvider must be overridden with the vault DB file path '
    '(Phase 5 bootstrap, or a temp file in tests).',
  );
});

/// The vault lock/unlock state machine (blueprint §8.2).
final vaultServiceProvider = StateNotifierProvider<VaultService, VaultState>((
  ref,
) {
  return VaultService(
    keyService: ref.watch(keyServiceProvider),
    vaultFile: ref.watch(vaultFileProvider),
  );
});

/// Whether the vault is currently unlocked. The router gates all screens behind
/// this (locked → unlock screen). Overridable in widget tests to bypass the gate
/// without constructing the full vault stack.
final appUnlockedProvider = Provider<bool>(
  (ref) => ref.watch(vaultServiceProvider).isUnlocked,
);

/// Whether a vault has already been initialized (a salt exists) — decides the
/// unlock screen's create-vs-unlock mode.
final vaultExistsProvider = FutureProvider<bool>(
  (ref) => ref.watch(vaultServiceProvider.notifier).vaultExists(),
);
