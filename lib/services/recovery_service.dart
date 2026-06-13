import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;

/// Encodes/decodes the 256-bit Master Key as a BIP-39 24-word recovery phrase
/// (blueprint §8.4).
///
/// **Deliberate use of BIP-39 as a checksummed 256-bit codec, not a seed
/// generator.** We use the *entropy* path (`entropyToMnemonic` /
/// `mnemonicToEntropy`) so the exact Master Key bytes round-trip — NOT the
/// PBKDF2 `mnemonicToSeed` path, which would derive a *different* 512-bit seed
/// and could never reproduce the MK. The MK is 256-bit (AES-256 / HKDF-32),
/// which is exactly BIP-39's maximum entropy → 24 words. If the MK is ever
/// redefined to be larger than 256 bits this mapping breaks and must be
/// revisited (STOP-and-surface).
///
/// This service is storage-free: it neither reads nor holds the vault. The
/// recover→reset-passphrase orchestration (using a restored MK to open the
/// vault and re-key) is onboarding/UI work and lands in Phase 5.
class RecoveryService {
  /// Master Key length in bytes (256-bit).
  static const int masterKeyLength = 32;

  /// Number of words for a 256-bit phrase.
  static const int wordCount = 24;

  /// Encodes [masterKey] as a 24-word recovery phrase. Throws [ArgumentError]
  /// unless [masterKey] is exactly 32 bytes.
  String encodeMasterKey(Uint8List masterKey) {
    if (masterKey.length != masterKeyLength) {
      throw ArgumentError.value(
        masterKey.length,
        'masterKey.length',
        'Recovery phrase encodes a 256-bit (32-byte) master key',
      );
    }
    return bip39.entropyToMnemonic(_hexEncode(masterKey));
  }

  /// Decodes a 24-word recovery phrase back to the 32-byte Master Key. Throws
  /// [FormatException] if the phrase fails checksum/wordlist validation or does
  /// not encode a 256-bit key.
  Uint8List decodeMnemonic(String mnemonic) {
    final normalized = _normalize(mnemonic);
    if (!bip39.validateMnemonic(normalized)) {
      throw const FormatException(
        'Invalid recovery phrase (failed checksum or wordlist validation)',
      );
    }
    final masterKey = _hexDecode(bip39.mnemonicToEntropy(normalized));
    if (masterKey.length != masterKeyLength) {
      throw const FormatException(
        'Recovery phrase does not encode a 256-bit master key',
      );
    }
    return masterKey;
  }

  /// Whether [mnemonic] is a valid 24-word recovery phrase (checksum + length).
  bool isValid(String mnemonic) {
    final normalized = _normalize(mnemonic);
    return bip39.validateMnemonic(normalized) &&
        normalized.split(' ').length == wordCount;
  }

  /// Confirm-by-re-entry (blueprint §8.4): the re-typed [mnemonic] must decode
  /// to the same [expectedMasterKey]. Compared in constant time.
  bool confirms(String mnemonic, Uint8List expectedMasterKey) {
    if (!isValid(mnemonic)) return false;
    return _constantTimeEquals(decodeMnemonic(mnemonic), expectedMasterKey);
  }

  /// BIP-39 words are lowercase and single-space separated; tolerate stray
  /// casing/whitespace on re-entry.
  String _normalize(String mnemonic) =>
      mnemonic.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String _hexEncode(Uint8List bytes) {
    const digits = '0123456789abcdef';
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(digits[(b >> 4) & 0xf]);
      buffer.write(digits[b & 0xf]);
    }
    return buffer.toString();
  }

  static Uint8List _hexDecode(String hex) {
    final out = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return out;
  }

  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
