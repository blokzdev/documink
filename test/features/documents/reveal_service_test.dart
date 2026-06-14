import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymization_providers.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/detection_providers.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/documents/reveal_service.dart';
import 'package:documink/services/authenticator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_vault.dart';

class _FakeAuth implements Authenticator {
  _FakeAuth(this.approve);
  final bool approve;
  @override
  Future<bool> authenticate({required String reason}) async => approve;
}

void main() {
  late TestVault vault;

  setUp(() async => vault = await TestVault.unlocked());
  tearDown(() => vault.dispose());

  ProviderContainer makeContainer({required bool approve}) {
    final c = ProviderContainer(
      overrides: [
        vault.override,
        authenticatorProvider.overrideWithValue(_FakeAuth(approve)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<String> saveTokenDoc(ProviderContainer c) async {
    const text = 'Email alice@example.com now.';
    final detection = await c.read(detectionPipelineProvider).detect(text);
    const policy = AnonymizationPolicy({
      PiiLabels.email: Operator.tokenRandom,
    }, fallback: Operator.redact);
    final outcome = await c
        .read(anonymizationServiceProvider)
        .anonymize(detection.normalizedText, detection.spans, policy);
    return c
        .read(documentRepositoryProvider)
        .saveAnonymizedText(
          name: 'Doc',
          originalText: text,
          detection: detection,
          operators: const {PiiLabels.email: Operator.tokenRandom},
          outcome: outcome,
        );
  }

  test('reveal returns plaintext on approval and audits success', () async {
    final c = makeContainer(approve: true);
    final docId = await saveTokenDoc(c);

    final revealed = await c.read(revealServiceProvider).reveal(docId);
    expect(revealed, isNotNull);
    expect(revealed!.values, contains('alice@example.com'));

    final db = vault.service.database;
    final audit = await db.select(db.auditLog).get();
    final reveal = audit.firstWhere((a) => a.eventType == 'document_reveal');
    expect(reveal.success, 1);
    expect(reveal.biometricResult, 'success');
  });

  test('reveal returns null on denial and audits the failed attempt', () async {
    final c = makeContainer(approve: false);
    final docId = await saveTokenDoc(c);

    final revealed = await c.read(revealServiceProvider).reveal(docId);
    expect(revealed, isNull);

    final db = vault.service.database;
    final audit = await db.select(db.auditLog).get();
    final reveal = audit.firstWhere((a) => a.eventType == 'document_reveal');
    expect(reveal.success, 0);
    expect(reveal.biometricResult, 'failed');
  });
}
