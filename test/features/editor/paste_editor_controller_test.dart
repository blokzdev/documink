import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/custom_entities/custom_entity_definition.dart';
import 'package:documink/features/custom_entities/custom_entity_providers.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/editor/paste_editor_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_vault.dart';

void main() {
  late TestVault vault;
  late ProviderContainer container;

  PasteEditorController controller() =>
      container.read(pasteEditorControllerProvider.notifier);
  PasteEditorState state() => container.read(pasteEditorControllerProvider);

  setUp(() async {
    vault = await TestVault.unlocked();
    container = ProviderContainer(overrides: [vault.override]);
    addTearDown(container.dispose);
    addTearDown(vault.dispose);
  });

  test('starts idle and empty', () {
    expect(state().status, EditorStatus.idle);
    expect(state().entityCount, 0);
    expect(state().previewText, '');
  });

  test('detect finds Tier-1 entities and redacts them by default', () async {
    controller().setInput('Email me at alice@example.com please.');
    await controller().detect();

    final s = state();
    expect(s.status, EditorStatus.ready);
    expect(s.labels, contains(PiiLabels.email));
    expect(s.operators[PiiLabels.email], Operator.redact);
    expect(s.previewText, contains('[REDACTED]'));
    expect(s.previewText, isNot(contains('alice@example.com')));
  });

  test('Replace and Mask operators update the preview', () async {
    controller().setInput('Reach alice@example.com now.');
    await controller().detect();

    await controller().setOperator(PiiLabels.email, Operator.replace);
    expect(state().previewText, contains('<${PiiLabels.email}>'));

    await controller().setOperator(PiiLabels.email, Operator.mask);
    expect(state().previewText, contains('•'));
    expect(state().previewText, isNot(contains('alice@example.com')));
  });

  test('Token-Random yields a vault surrogate', () async {
    controller().setInput('Reach alice@example.com now.');
    await controller().detect();

    await controller().setOperator(PiiLabels.email, Operator.tokenRandom);
    expect(state().previewText, contains('<${PiiLabels.email}_'));
    expect(state().previewText, isNot(contains('alice@example.com')));
  });

  test('Encrypt yields an inline ciphertext wrapper', () async {
    controller().setInput('Reach alice@example.com now.');
    await controller().detect();

    await controller().setOperator(PiiLabels.email, Operator.encrypt);
    expect(state().previewText, contains('<ENC:'));
    expect(state().previewText, isNot(contains('alice@example.com')));
  });

  test('save persists the previewed document to the vault', () async {
    controller().setInput('Reach alice@example.com now.');
    await controller().detect();
    await controller().setOperator(PiiLabels.email, Operator.tokenRandom);

    final docId = await controller().save(name: 'My note');
    expect(docId, isNotNull);

    final db = vault.service.database;
    final docs = await db.select(db.documents).get();
    expect(docs.single.name, 'My note');
    // The previewed surrogate matches the persisted token value.
    final tokens = await db.select(db.tokens).get();
    expect(state().previewText, contains(tokens.single.tokenValue));
  });

  test('save returns null when there is nothing to save', () async {
    expect(await controller().save(), isNull);
  });

  test('detect picks up a saved custom entity type', () async {
    await container.read(documentRepositoryProvider).ensureDefaultWorkspace();
    await container
        .read(customEntityRepositoryProvider)
        .save(
          const CustomEntityDefinition(
            id: 'cet1',
            workspaceId: DocumentRepository.defaultWorkspaceId,
            label: 'TICKET',
            regexPattern: r'TKT-\d+',
            defaultOperator: Operator.redact,
            createdAtEpochMs: 0,
          ),
        );

    controller().setInput('Please see TKT-123 for details.');
    await controller().detect();

    expect(state().labels, contains('TICKET'));
    expect(state().previewText, isNot(contains('TKT-123')));
  });

  test('empty input detects nothing', () async {
    controller().setInput('   ');
    await controller().detect();
    expect(state().status, EditorStatus.idle);
    expect(state().entityCount, 0);
  });

  test('editor offers irreversible + Token-Random + Encrypt (no FPE)', () {
    expect(editorOperators, [
      Operator.redact,
      Operator.mask,
      Operator.replace,
      Operator.tokenRandom,
      Operator.encrypt,
    ]);
    expect(editorOperators, isNot(contains(Operator.fpe)));
  });
}
