import 'dart:typed_data';

import 'package:documink/data/app_database.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/documents/originals_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_vault.dart';

void main() {
  late TestVault vault;

  setUp(() async => vault = await TestVault.unlocked());
  tearDown(() => vault.dispose());

  AppDatabase db() => vault.service.database;

  OriginalsRepository repo() =>
      OriginalsRepository(db(), vault.service.tokenCrypto);

  DocumentRepository docs() => DocumentRepository(db());

  /// Inserts a minimal document row (FK target for an original).
  Future<String> seedDocument({String id = 'doc1'}) async {
    await docs().ensureDefaultWorkspace();
    await db()
        .into(db().documents)
        .insert(
          DocumentsCompanion.insert(
            id: id,
            workspaceId: DocumentRepository.defaultWorkspaceId,
            name: 'Doc',
            type: 'image',
            sourceHash: Uint8List(0),
            createdAt: 0,
            updatedAt: 0,
            status: 'redacted',
            metadataJson: const Value(null),
          ),
        );
    return id;
  }

  final bytes = Uint8List.fromList(List.generate(2048, (i) => i % 256));

  test('saveOriginal encrypts; originalFor + decrypt round-trips', () async {
    final id = await seedDocument();
    await repo().saveOriginal(documentId: id, bytes: bytes, mime: 'image/png');

    final original = await repo().originalFor(id);
    expect(original, isNotNull);
    expect(original!.mime, 'image/png');
    expect(original.sizeBytes, bytes.length);
    // Stored ciphertext is NOT the plaintext.
    expect(original.ciphertext, isNot(equals(bytes)));

    final decrypted = await repo().decryptOriginal(original);
    expect(decrypted, equals(bytes));
  });

  test('hasOriginal reflects presence', () async {
    final id = await seedDocument();
    expect(await repo().hasOriginal(id), isFalse);
    await repo().saveOriginal(documentId: id, bytes: bytes, mime: 'image/png');
    expect(await repo().hasOriginal(id), isTrue);
  });

  test(
    'saveOriginal replaces a prior original (one row per document)',
    () async {
      final id = await seedDocument();
      await repo().saveOriginal(
        documentId: id,
        bytes: bytes,
        mime: 'image/png',
      );
      final newBytes = Uint8List.fromList([1, 2, 3, 4]);
      await repo().saveOriginal(
        documentId: id,
        bytes: newBytes,
        mime: 'application/pdf',
      );

      final rows = await (db().select(
        db().documentOriginals,
      )..where((o) => o.documentId.equals(id))).get();
      expect(rows, hasLength(1));
      expect(rows.single.mime, 'application/pdf');
      expect(await repo().decryptOriginal(rows.single), equals(newBytes));
    },
  );

  test('deleteDocument cascades to the original', () async {
    final id = await seedDocument();
    await repo().saveOriginal(documentId: id, bytes: bytes, mime: 'image/png');

    await docs().deleteDocument(id);

    expect(await repo().originalFor(id), isNull);
  });

  test('decrypt under the wrong document id (AAD) fails', () async {
    final id = await seedDocument();
    await repo().saveOriginal(documentId: id, bytes: bytes, mime: 'image/png');
    final original = await repo().originalFor(id);

    // The ciphertext is bound to the document id via AAD.
    expect(
      vault.service.tokenCrypto.decryptBytes(
        original!.ciphertext,
        aad: 'someone-elses-doc',
      ),
      throwsA(anything),
    );
  });
}
