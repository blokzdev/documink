import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:documink/features/llm/model_hash_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const verifier = ModelHashVerifier();
  final bytes = utf8.encode('pretend model file');
  final expected = sha256.convert(bytes).toString();

  test('matches the correct hash (case-insensitive)', () {
    expect(verifier.matches(bytes, expected), isTrue);
    expect(verifier.matches(bytes, expected.toUpperCase()), isTrue);
  });

  test('verifyOrThrow passes on match, throws on mismatch', () {
    verifier.verifyOrThrow(bytes, expected); // no throw
    expect(
      () => verifier.verifyOrThrow(utf8.encode('different'), expected),
      throwsA(isA<ModelHashMismatchException>()),
    );
  });
}
