import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../../data/tokens_dao.dart';

/// The vault material for a reversible **Token-Random** replacement — exactly
/// the columns a `tokens` row needs (blueprint §3.1/§7.1). The detection→vault
/// persistence step (pipeline) writes these with the owning entity; this layer
/// only produces them.
class TokenRecord {
  const TokenRecord({
    required this.surrogate,
    required this.ciphertext,
    required this.fingerprint,
  });

  /// The surface token, e.g. `<PERSON_a1B2c3>` (also `tokens.token_value`).
  final String surrogate;

  /// AES-256-GCM ciphertext of the plaintext, bound to [surrogate] as AAD.
  final Uint8List ciphertext;

  /// Keyed HMAC-SHA256 fingerprint of the plaintext (for dedup/lookup).
  final Uint8List fingerprint;
}

/// Produces and reverses the reversible operators (blueprint §7.1) on top of
/// 1c's [TokenCrypto]: **Token-Random** (random surrogate + stored ciphertext)
/// and **Encrypt** (stateless inline ciphertext, no vault row). FF1 FPE is 3c.
///
/// Intra-document dedup (same plaintext → same surrogate, via fingerprint
/// match) is the pipeline's responsibility when it persists rows; this layer
/// mints a fresh surrogate per call.
class ReversibleOperators {
  ReversibleOperators(this._crypto, {Random? random})
    : _random = random ?? Random.secure();

  final TokenCrypto _crypto;
  final Random _random;

  static const int _surrogateLength = 6;
  static const String _base62 =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  /// Inline-encrypt wrapper: `<ENC:base64(nonce‖ct‖mac)>`.
  static final RegExp _inlinePattern = RegExp(r'^<ENC:([A-Za-z0-9+/=]+)>$');
  // Domain-separated AAD for stateless inline encryption (no surrogate).
  static const String _inlineAad = 'documink:inline-encrypt:v1';

  // --- Token-Random ------------------------------------------------------

  /// Mints `<LABEL_xxxxxx>` and encrypts [plaintext] (AAD = surrogate) so the
  /// pair can be persisted and later reversed by surrogate lookup.
  Future<TokenRecord> tokenize(String plaintext, String label) async {
    final surrogate = randomSurrogate(label);
    final ciphertext = await _crypto.encrypt(plaintext, tokenValue: surrogate);
    final fingerprint = await _crypto.fingerprint(plaintext);
    return TokenRecord(
      surrogate: surrogate,
      ciphertext: ciphertext,
      fingerprint: fingerprint,
    );
  }

  /// Reverses a [TokenRecord] (the data a `tokens` row holds) to plaintext.
  Future<String> revealToken(TokenRecord record) =>
      _crypto.decrypt(record.ciphertext, tokenValue: record.surrogate);

  /// A `<LABEL_xxxxxx>` surrogate with 6 Base62 random chars from a CSPRNG.
  String randomSurrogate(String label) {
    final buffer = StringBuffer('<')
      ..write(label)
      ..write('_');
    for (var i = 0; i < _surrogateLength; i++) {
      buffer.write(_base62[_random.nextInt(_base62.length)]);
    }
    return (buffer..write('>')).toString();
  }

  // --- Encrypt (stateless, inline) --------------------------------------

  /// Encrypts [plaintext] into a self-contained `<ENC:base64>` wrapper with no
  /// vault row — for the "encrypt, don't tokenize" choice (§7.1).
  Future<String> encryptInline(String plaintext) async {
    final blob = await _crypto.encrypt(plaintext, tokenValue: _inlineAad);
    return '<ENC:${base64.encode(blob)}>';
  }

  /// Whether [text] is an inline-encrypt wrapper.
  bool isInline(String text) => _inlinePattern.hasMatch(text);

  /// Reverses [encryptInline]. Throws [FormatException] if [wrapper] is malformed.
  Future<String> revealInline(String wrapper) async {
    final match = _inlinePattern.firstMatch(wrapper);
    if (match == null) {
      throw const FormatException('Not an inline-encrypt wrapper');
    }
    final blob = Uint8List.fromList(base64.decode(match.group(1)!));
    return _crypto.decrypt(blob, tokenValue: _inlineAad);
  }
}
