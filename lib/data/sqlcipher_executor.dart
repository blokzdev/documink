import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Builds a SQLCipher-encrypted [QueryExecutor] for the vault at [file], keyed
/// with the raw 32-byte [rawKey] derived by KeyService (blueprint §8.2).
///
/// The encrypted SQLite build (SQLite3 Multiple Ciphers) is selected at compile
/// time via the `hooks.user_defines` block in `pubspec.yaml`, so no runtime
/// `open` override is required — the bundled encrypted library loads on every
/// isolate automatically. The raw key is supplied as a hex blob
/// (`PRAGMA key = "x'…'"`) so the cipher uses it directly instead of running a
/// passphrase KDF over our already-derived key.
///
/// The SQLCipher-compatible cipher is pinned (`PRAGMA cipher = 'sqlcipher'`) to
/// honor the blueprint's AES-256 SQLCipher intent (§2.4).
QueryExecutor openEncryptedExecutor({
  required File file,
  required Uint8List rawKey,
}) {
  if (rawKey.length != 32) {
    throw ArgumentError.value(
      rawKey.length,
      'rawKey.length',
      'Vault key must be 32 bytes (256-bit)',
    );
  }
  final keyHex = _hex(rawKey);
  return NativeDatabase.createInBackground(
    file,
    setup: (rawDb) {
      // Order matters: select the SQLCipher-compatible cipher, then key the
      // database, before any other statement runs on the connection.
      rawDb.execute("PRAGMA cipher = 'sqlcipher';");
      rawDb.execute('PRAGMA key = "x\'$keyHex\'";');
      // Guard: confirm an encrypted build is actually linked. Plain SQLite
      // silently ignores the cipher pragmas and reports no cipher_version.
      final result = rawDb.select('PRAGMA cipher_version;');
      if (result.isEmpty) {
        throw StateError(
          'Encrypted SQLite build not linked: PRAGMA cipher_version returned '
          'no rows. Verify the hooks.user_defines sqlite3 source in pubspec.yaml.',
        );
      }
    },
  );
}

String _hex(Uint8List bytes) {
  const digits = '0123456789abcdef';
  final buf = StringBuffer();
  for (final b in bytes) {
    buf.write(digits[(b >> 4) & 0xf]);
    buf.write(digits[b & 0xf]);
  }
  return buf.toString();
}
