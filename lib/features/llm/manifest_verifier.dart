import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'model_manifest.dart';

/// Raised when a signed manifest fails verification or is malformed. The app
/// **never** falls back to an unsigned/invalid manifest (blueprint §4.7,
/// §6.4: "Signature verification failure blocks update; never falls back to
/// unsigned").
class ManifestVerificationException implements Exception {
  const ManifestVerificationException(this.message);
  final String message;
  @override
  String toString() => 'ManifestVerificationException: $message';
}

/// Verifies the Ed25519 signature over a `manifest.signed.json` blob against a
/// **pinned** public key, then parses the verified body (blueprint §4.7,
/// models.md §5). Signing covers the exact UTF-8 bytes of the embedded `body`
/// string, so verification is independent of any JSON re-serialization.
class ManifestVerifier {
  ManifestVerifier({String? pinnedPublicKeyBase64})
    : _publicKeyBytes = base64.decode(
        pinnedPublicKeyBase64 ?? defaultPublicKeyBase64,
      );

  /// The pinned manifest **public** key (Ed25519, base64). This is a
  /// development/review key; the production key is pinned at release. Key
  /// rotation requires an app update (models.md §5).
  static const String defaultPublicKeyBase64 =
      'ebVWLo/mVPlAeLES6KmLp5AfhTrmlb7X4OORC60ElmQ=';

  final List<int> _publicKeyBytes;
  final Ed25519 _algorithm = Ed25519();

  /// Verifies [signedJson] and returns the parsed [ModelManifest]. Throws
  /// [ManifestVerificationException] on any signature/format failure — never
  /// returns an unverified manifest.
  Future<ModelManifest> verifyAndParse(String signedJson) async {
    final Map<String, dynamic> outer;
    try {
      outer = jsonDecode(signedJson) as Map<String, dynamic>;
    } catch (_) {
      throw const ManifestVerificationException('signed manifest is not JSON');
    }

    if (outer['alg'] != 'ed25519') {
      throw ManifestVerificationException(
        'unsupported signature algorithm: ${outer['alg']}',
      );
    }
    final signatureB64 = outer['signature'];
    final body = outer['body'];
    if (signatureB64 is! String || body is! String) {
      throw const ManifestVerificationException(
        'malformed signed manifest (missing signature/body)',
      );
    }

    final publicKey = SimplePublicKey(
      _publicKeyBytes,
      type: KeyPairType.ed25519,
    );
    final List<int> signatureBytes;
    try {
      signatureBytes = base64.decode(signatureB64);
    } catch (_) {
      throw const ManifestVerificationException('signature is not base64');
    }

    final valid = await _algorithm.verify(
      utf8.encode(body),
      signature: Signature(signatureBytes, publicKey: publicKey),
    );
    if (!valid) {
      throw const ManifestVerificationException(
        'signature verification failed (pinned key mismatch or tampered body)',
      );
    }

    try {
      return ModelManifest.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (e) {
      throw ManifestVerificationException('verified body failed to parse: $e');
    }
  }
}
