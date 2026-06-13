import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'ff1.dart';

/// Format-preserving encryption of digit strings (blueprint §7.1) via [Ff1]
/// (radix 10). Non-digit characters (spaces, dashes) are preserved in place, so
/// `4111 1111 1111 1111` re-encrypts to another `dddd dddd dddd dddd` string.
/// Deterministic given key + tweak, so reversal is `decryptDigits` with the
/// same tweak — no stored state.
class FpeOperator {
  FpeOperator(Uint8List key) : _ff1 = Ff1(key: key, radix: 10);

  final Ff1 _ff1;

  /// Encrypts the digits of [text], preserving non-digits and the last
  /// [keepClear] digits (e.g. card "keep last 4"). Throws [ArgumentError] if
  /// fewer than 2 digits would be encrypted (FF1's minimum).
  String encryptDigits(
    String text, {
    required Uint8List tweak,
    int keepClear = 0,
  }) => _transform(text, tweak: tweak, keepClear: keepClear, encrypting: true);

  /// Reverses [encryptDigits] with the same [tweak]/[keepClear].
  String decryptDigits(
    String text, {
    required Uint8List tweak,
    int keepClear = 0,
  }) => _transform(text, tweak: tweak, keepClear: keepClear, encrypting: false);

  String _transform(
    String text, {
    required Uint8List tweak,
    required int keepClear,
    required bool encrypting,
  }) {
    final units = text.codeUnits;
    final digitPositions = <int>[];
    for (var i = 0; i < units.length; i++) {
      if (units[i] >= 0x30 && units[i] <= 0x39) digitPositions.add(i);
    }
    final encryptable = digitPositions.length - keepClear;
    if (encryptable < 2) {
      throw ArgumentError(
        'FPE needs at least 2 encryptable digits (got $encryptable)',
      );
    }
    final numerals = [
      for (var i = 0; i < encryptable; i++) units[digitPositions[i]] - 0x30,
    ];
    final out = encrypting
        ? _ff1.encrypt(numerals, tweak: tweak)
        : _ff1.decrypt(numerals, tweak: tweak);

    final result = List<int>.from(units);
    for (var i = 0; i < encryptable; i++) {
      result[digitPositions[i]] = out[i] + 0x30;
    }
    return String.fromCharCodes(result);
  }

  /// Derives the FF1 tweak from the entity type + workspace id (blueprint §7.1:
  /// "tweak = entity_type + workspace_id hash") as a domain-separated SHA-256.
  /// A 0x00 byte separates the two fields so the encoding is injective.
  static Uint8List tweakFor(String entityType, String workspaceId) {
    final input = <int>[
      ...utf8.encode(entityType),
      0,
      ...utf8.encode(workspaceId),
    ];
    return Uint8List.fromList(sha256.convert(input).bytes);
  }
}
