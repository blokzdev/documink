import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A minimal key/value store for **pre-unlock** secrets that must be readable
/// before the encrypted vault is open.
///
/// The Argon2id salt lives here (blueprint §8.1, as corrected in V1 P1b): it is
/// needed to derive the Master Key, which in turn derives the key that opens the
/// SQLCipher database — so it cannot live inside that database (`vault_meta`
/// would be unreadable until after unlock). Post-unlock key material (the
/// wrapped DEK, `key_version`) stays in `vault_meta` instead.
///
/// This is a thin abstraction over [FlutterSecureStorage] (Android Keystore /
/// Windows DPAPI-backed) so that pure-Dart unit tests can inject an in-memory
/// fake — the real plugin needs platform channels that aren't available under
/// `flutter test`.
abstract interface class SecureKeyStore {
  /// Returns the stored value for [key], or `null` if absent.
  Future<String?> read(String key);

  /// Persists [value] under [key], overwriting any existing value.
  Future<void> write(String key, String value);

  /// Removes [key] if present.
  Future<void> delete(String key);

  /// Whether a value is stored under [key].
  Future<bool> containsKey(String key);
}

/// Production [SecureKeyStore] backed by the platform secure store.
///
/// Uses [FlutterSecureStorage]'s v10 secure defaults (Android Keystore-backed
/// encryption; Windows DPAPI). No custom options are passed: the defaults are
/// the hardware-backed path on the V1 targets.
class FlutterSecureKeyStore implements SecureKeyStore {
  FlutterSecureKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<bool> containsKey(String key) => _storage.containsKey(key: key);
}
