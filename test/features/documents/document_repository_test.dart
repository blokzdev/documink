import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymization_providers.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/detection_providers.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_vault.dart';

void main() {
  late TestVault vault;
  late ProviderContainer container;

  setUp(() async {
    vault = await TestVault.unlocked();
    container = ProviderContainer(overrides: [vault.override]);
    addTearDown(container.dispose);
    addTearDown(vault.dispose);
  });

  test(
    'persists document + entities + reversible tokens, and audits',
    () async {
      const text = 'Email alice@example.com now.';
      final detection = await container
          .read(detectionPipelineProvider)
          .detect(text);
      expect(detection.spans, isNotEmpty);

      const policy = AnonymizationPolicy({
        PiiLabels.email: Operator.tokenRandom,
      }, fallback: Operator.redact);
      final outcome = await container
          .read(anonymizationServiceProvider)
          .anonymize(detection.normalizedText, detection.spans, policy);

      final repo = container.read(documentRepositoryProvider);
      final docId = await repo.saveAnonymizedText(
        name: 'Test doc',
        originalText: text,
        detection: detection,
        operators: {PiiLabels.email: Operator.tokenRandom},
        outcome: outcome,
      );

      final db = vault.service.database;
      final docs = await db.select(db.documents).get();
      expect(docs, hasLength(1));
      expect(docs.single.id, docId);
      expect(docs.single.status, 'redacted');

      final entities = await db.select(db.entities).get();
      expect(entities.any((e) => e.entityType == PiiLabels.email), isTrue);

      final tokens = await db.select(db.tokens).get();
      expect(tokens, hasLength(1));

      // The persisted token is reversible to the original plaintext.
      final plaintext = await vault.service.tokenCrypto.decrypt(
        tokens.single.ciphertext,
        tokenValue: tokens.single.tokenValue,
      );
      expect(plaintext, 'alice@example.com');

      // Default workspace + audit entry written.
      final workspaces = await db.select(db.workspaces).get();
      expect(workspaces.single.id, DocumentRepository.defaultWorkspaceId);
      final audit = await db.select(db.auditLog).get();
      expect(audit.any((a) => a.eventType == 'document_saved'), isTrue);
    },
  );

  test('ensureDefaultWorkspace is idempotent', () async {
    final repo = container.read(documentRepositoryProvider);
    await repo.ensureDefaultWorkspace();
    await repo.ensureDefaultWorkspace();
    final db = vault.service.database;
    expect(await db.select(db.workspaces).get(), hasLength(1));
  });
}
