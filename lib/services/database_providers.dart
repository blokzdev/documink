import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';

/// The app's single encrypted database.
///
/// This provider has no default: the vault cannot be opened until the user has
/// unlocked it and a key-derived, SQLCipher-backed [AppDatabase] is available.
/// It is overridden:
///   * in production at bootstrap, once `VaultService` unlocks the vault and
///     supplies the keyed executor (Phase 1c), and
///   * in tests, with an in-memory `AppDatabase(NativeDatabase.memory())`.
///
/// Reading it before an override is wired is a programming error.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with a keyed AppDatabase once the '
    'vault is unlocked (see VaultService, V1 Phase 1c).',
  );
});
