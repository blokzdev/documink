import 'package:crypto/crypto.dart';

/// Verifies a downloaded model file's bytes against the SHA-256 in the (already
/// Ed25519-verified) manifest (blueprint §4.7 / models.md §2: "SHA-256 verified
/// post-download against manifest hash"; on mismatch, surface an error — never
/// activate an unverified model).
class ModelHashVerifier {
  const ModelHashVerifier();

  /// Whether [bytes] hash to [expectedSha256Hex] (case-insensitive hex).
  bool matches(List<int> bytes, String expectedSha256Hex) =>
      sha256.convert(bytes).toString() == expectedSha256Hex.toLowerCase();

  /// Throws [ModelHashMismatchException] if [bytes] don't match the hash.
  void verifyOrThrow(List<int> bytes, String expectedSha256Hex) {
    if (!matches(bytes, expectedSha256Hex)) {
      throw ModelHashMismatchException(
        expected: expectedSha256Hex.toLowerCase(),
        actual: sha256.convert(bytes).toString(),
      );
    }
  }
}

/// Raised when a downloaded model file's SHA-256 doesn't match the manifest.
class ModelHashMismatchException implements Exception {
  const ModelHashMismatchException({
    required this.expected,
    required this.actual,
  });
  final String expected;
  final String actual;
  @override
  String toString() =>
      'ModelHashMismatchException: expected $expected, got $actual';
}
