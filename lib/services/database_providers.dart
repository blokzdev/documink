import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import 'vault_providers.dart';

/// The app's single encrypted database, sourced from the unlocked vault.
///
/// Derives from [vaultServiceProvider]: it recomputes on every lock/unlock
/// transition and exposes the keyed [AppDatabase] that `VaultService` opened.
/// Reading it while the vault is **locked** throws [StateError] — callers must
/// unlock first (UI gating arrives in Phase 5). Tests may either drive a real
/// `VaultService` or override this provider directly with an in-memory
/// `AppDatabase(NativeDatabase.memory())`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  ref.watch(vaultServiceProvider); // recompute when the vault locks/unlocks
  return ref.read(vaultServiceProvider.notifier).database; // throws if locked
});
