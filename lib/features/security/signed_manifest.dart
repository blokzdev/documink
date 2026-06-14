import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Raised when a signed manifest blob is malformed or fails Ed25519
/// verification. Callers must **never** act on an unverified body — verification
/// failure blocks the update (blueprint §4.7/§6.4: "never falls back to
/// unsigned"). Both the model manifest (Phase 9) and the templates manifest
/// (Phase 14) share this single, audited verification path.
class SignedManifestException implements Exception {
  const SignedManifestException(this.message);
  final String message;
  @override
  String toString() => 'SignedManifestException: $message';
}

/// Verifies the Ed25519 signature over a `{alg, key_id, signature, body}`
/// wrapper against [pinnedPublicKeyBase64] and returns the verified `body`
/// string. Throws [SignedManifestException] on any malformation or signature
/// failure. The signature covers the exact UTF-8 bytes of the embedded `body`
/// string, so verification is independent of any JSON re-serialization.
Future<String> verifyEd25519SignedManifest(
  String signedJson, {
  required String pinnedPublicKeyBase64,
}) async {
  final Map<String, dynamic> outer;
  try {
    outer = jsonDecode(signedJson) as Map<String, dynamic>;
  } catch (_) {
    throw const SignedManifestException('signed manifest is not JSON');
  }

  if (outer['alg'] != 'ed25519') {
    throw SignedManifestException(
      'unsupported signature algorithm: ${outer['alg']}',
    );
  }
  final signatureB64 = outer['signature'];
  final body = outer['body'];
  if (signatureB64 is! String || body is! String) {
    throw const SignedManifestException(
      'malformed signed manifest (missing signature/body)',
    );
  }

  final List<int> signatureBytes;
  try {
    signatureBytes = base64.decode(signatureB64);
  } catch (_) {
    throw const SignedManifestException('signature is not base64');
  }

  final publicKey = SimplePublicKey(
    base64.decode(pinnedPublicKeyBase64),
    type: KeyPairType.ed25519,
  );
  final valid = await Ed25519().verify(
    utf8.encode(body),
    signature: Signature(signatureBytes, publicKey: publicKey),
  );
  if (!valid) {
    throw const SignedManifestException(
      'signature verification failed (pinned key mismatch or tampered body)',
    );
  }

  return body;
}
