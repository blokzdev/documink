import 'dart:typed_data';

import 'package:documink/data/app_database.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/documents/original_reveal_service.dart';
import 'package:documink/features/documents/originals_repository.dart';
import 'package:documink/features/audit/audit_log_repository.dart';
import 'package:documink/services/authenticator.dart';
import 'package:drift/drift.dart' show Value;
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

  AppDatabase db() => vault.service.database;
  final bytes = Uint8List.fromList(List.generate(512, (i) => i % 256));

  Future<String> seedWithOriginal() async {
    final docs = DocumentRepository(db());
    await docs.ensureDefaultWorkspace();
    await db()
        .into(db().documents)
        .insert(
          DocumentsCompanion.insert(
            id: 'doc1',
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
    await OriginalsRepository(
      db(),
      vault.service.tokenCrypto,
    ).saveOriginal(documentId: 'doc1', bytes: bytes, mime: 'image/png');
    return 'doc1';
  }

  OriginalRevealService service(bool approve) => OriginalRevealService(
    originals: OriginalsRepository(db(), vault.service.tokenCrypto),
    audit: AuditLogRepository(db()),
    authenticator: _FakeAuth(approve),
  );

  test('reveal returns bytes + mime on approval and audits success', () async {
    final id = await seedWithOriginal();

    final revealed = await service(true).reveal(id);

    expect(revealed, isNotNull);
    expect(revealed!.bytes, equals(bytes));
    expect(revealed.mime, 'image/png');

    final audit = await db().select(db().auditLog).get();
    final row = audit.firstWhere(
      (a) => a.eventType == 'document_original_revealed',
    );
    expect(row.success, 1);
    expect(row.biometricResult, 'success');
  });

  test('reveal returns null on denial and audits the failed attempt', () async {
    final id = await seedWithOriginal();

    final revealed = await service(false).reveal(id);

    expect(revealed, isNull);
    final audit = await db().select(db().auditLog).get();
    final row = audit.firstWhere(
      (a) => a.eventType == 'document_original_revealed',
    );
    expect(row.success, 0);
    expect(row.biometricResult, 'failed');
  });

  test(
    'reveal of a document with no original returns null, no prompt',
    () async {
      final docs = DocumentRepository(db());
      await docs.ensureDefaultWorkspace();
      // No original stored, and no document needed — reveal short-circuits.
      final revealed = await service(true).reveal('missing');
      expect(revealed, isNull);
      final audit = await db().select(db().auditLog).get();
      expect(
        audit.where((a) => a.eventType == 'document_original_revealed'),
        isEmpty,
      );
    },
  );
}
