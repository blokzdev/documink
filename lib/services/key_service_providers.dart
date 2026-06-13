import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_service.dart';
import 'secure_key_store.dart';

/// The pre-unlock secure store (Argon2id salt). Backed by the platform secure
/// store in production; overridden with an in-memory fake in tests.
final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return FlutterSecureKeyStore();
});

/// The vault key-hierarchy service (blueprint §8.1). Stateless aside from the
/// [secureKeyStoreProvider] it reads the salt from; `VaultService` (1c) drives
/// it to open and lock the vault.
final keyServiceProvider = Provider<KeyService>((ref) {
  return KeyService(ref.watch(secureKeyStoreProvider));
});
