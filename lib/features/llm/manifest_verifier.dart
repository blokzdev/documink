import 'dart:convert';

import '../security/signed_manifest.dart';
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
    : _pinnedPublicKeyBase64 = pinnedPublicKeyBase64 ?? defaultPublicKeyBase64;

  /// The pinned manifest **public** key (Ed25519, base64). This is a
  /// development/review key; the production key is pinned at release. Key
  /// rotation requires an app update (models.md §5).
  static const String defaultPublicKeyBase64 =
      'ebVWLo/mVPlAeLES6KmLp5AfhTrmlb7X4OORC60ElmQ=';

  final String _pinnedPublicKeyBase64;

  /// Verifies [signedJson] and returns the parsed [ModelManifest]. Throws
  /// [ManifestVerificationException] on any signature/format failure — never
  /// returns an unverified manifest. Delegates signature verification to the
  /// shared [verifyEd25519SignedManifest] core (the single audited path used by
  /// both the model and templates manifests).
  Future<ModelManifest> verifyAndParse(String signedJson) async {
    final String body;
    try {
      body = await verifyEd25519SignedManifest(
        signedJson,
        pinnedPublicKeyBase64: _pinnedPublicKeyBase64,
      );
    } on SignedManifestException catch (e) {
      throw ManifestVerificationException(e.message);
    }

    try {
      return ModelManifest.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (e) {
      throw ManifestVerificationException('verified body failed to parse: $e');
    }
  }
}
