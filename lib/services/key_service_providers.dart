import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_service.dart';
import 'salt_store.dart';
import 'secure_key_store.dart';

/// The plaintext file the (non-secret) Argon2id salt is persisted to. No
/// default: production wires it at bootstrap (sibling of `vault.db`); tests
/// override it with a temp file.
final saltFileProvider = Provider<File>((ref) {
  throw UnimplementedError(
    'saltFileProvider must be overridden with the salt file path '
    '(bootstrap, or a temp file in tests).',
  );
});

/// Where the (non-secret) Argon2id salt lives: a plaintext app-private file,
/// off the platform Keystore (see [SaltStore]).
final saltStoreProvider = Provider<SaltStore>((ref) {
  return FileSaltStore(ref.watch(saltFileProvider));
});

/// The pre-unlock secure store. Reserved for the Phase-5 biometric-gated wrapped
/// KEK; in V1 it is used only as a one-way **migration read-fallback** for the
/// salt (see [KeyService]). Overridden with an in-memory fake in tests.
final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return FlutterSecureKeyStore();
});

/// The vault key-hierarchy service (blueprint §8.1). Reads the salt from the
/// [saltStoreProvider]; `VaultService` (1c) drives it to open and lock the vault.
final keyServiceProvider = Provider<KeyService>((ref) {
  return KeyService(
    ref.watch(saltStoreProvider),
    legacyStore: ref.watch(secureKeyStoreProvider),
  );
});
