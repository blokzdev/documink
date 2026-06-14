import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documink/features/llm/manifest_verifier.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final signedJson = File(
    'assets/model_manifest/manifest.signed.json',
  ).readAsStringSync();

  group('ManifestVerifier', () {
    test('verifies + parses the shipped signed manifest', () async {
      final manifest = await ManifestVerifier().verifyAndParse(signedJson);
      expect(manifest.version, 1);

      final perf = manifest.catalog.tiers.firstWhere(
        (t) => t.tier == 'performance',
      );
      expect(perf.minScore, 90);
      expect(perf.variants[VariantKind.balanced]!.modelId, 'gemma-4-e4b-int4');

      // Tier 3 detection models ride the same manifest (ADR-022).
      final baseline = manifest.detectionModels.firstWhere(
        (m) => m.role == 'tier3_baseline_bundled',
      );
      expect(baseline.bundled, isTrue);
      expect(
        manifest.detectionModels.any((m) => m.role == 'tier3_upgrade'),
        isTrue,
      );
    });

    test('rejects a tampered body (signature no longer matches)', () async {
      final outer = jsonDecode(signedJson) as Map<String, dynamic>;
      final tamperedBody = (outer['body'] as String).replaceFirst(
        '"version": 1',
        '"version": 2',
      );
      final tampered = jsonEncode({...outer, 'body': tamperedBody});
      expect(
        () => ManifestVerifier().verifyAndParse(tampered),
        throwsA(isA<ManifestVerificationException>()),
      );
    });

    test('rejects a tampered signature', () async {
      final outer = jsonDecode(signedJson) as Map<String, dynamic>;
      final sig = base64.decode(outer['signature'] as String);
      sig[0] ^= 0xff;
      final tampered = jsonEncode({...outer, 'signature': base64.encode(sig)});
      expect(
        () => ManifestVerifier().verifyAndParse(tampered),
        throwsA(isA<ManifestVerificationException>()),
      );
    });

    test('rejects a valid signature under a different (attacker) key', () async {
      // Sign the body with a different key; the pinned key must still reject it.
      final outer = jsonDecode(signedJson) as Map<String, dynamic>;
      final body = outer['body'] as String;
      final attacker = await Ed25519().newKeyPairFromSeed(
        List<int>.generate(32, (i) => 200 + i),
      );
      final forged = await Ed25519().sign(utf8.encode(body), keyPair: attacker);
      final forgedJson = jsonEncode({
        'alg': 'ed25519',
        'signature': base64.encode(forged.bytes),
        'body': body,
      });
      expect(
        () => ManifestVerifier().verifyAndParse(forgedJson),
        throwsA(isA<ManifestVerificationException>()),
      );
    });

    test('rejects an unsupported algorithm', () async {
      final outer = jsonDecode(signedJson) as Map<String, dynamic>;
      final bad = jsonEncode({...outer, 'alg': 'rsa'});
      expect(
        () => ManifestVerifier().verifyAndParse(bad),
        throwsA(isA<ManifestVerificationException>()),
      );
    });

    test('rejects non-JSON input', () async {
      expect(
        () => ManifestVerifier().verifyAndParse('not json'),
        throwsA(isA<ManifestVerificationException>()),
      );
    });
  });
}
