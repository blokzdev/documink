import 'package:documink/data/app_database.dart';
import 'package:documink/features/audit/audit_event_type.dart';
import 'package:documink/features/audit/audit_log_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AuditLogRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = AuditLogRepository(db);
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws',
            name: 'W',
            createdAt: 0,
            kekVersion: 1,
          ),
        );
  });
  tearDown(() async => db.close());

  Future<void> rec(
    String id,
    String type,
    int at, {
    bool success = true,
    String? tool,
    Map<String, dynamic>? meta,
  }) => repo.record(
    id: id,
    workspaceId: 'ws',
    eventType: type,
    toolName: tool,
    success: success,
    metadata: meta,
    nowEpochMs: at,
  );

  test('records and reads newest-first', () async {
    await rec('a', AuditEventType.vaultUnlock, 1000);
    await rec('b', AuditEventType.decode, 2000);
    final entries = await repo.query('ws');
    expect(entries.map((e) => e.id), ['b', 'a']);
    expect(entries.first.eventType, AuditEventType.decode);
  });

  test('round-trips success flag and metadata', () async {
    await rec(
      't',
      AuditEventType.minkToolCall,
      1,
      success: false,
      tool: 'decode_token',
      meta: {'reason': 'denied', 'count': 3},
    );
    final e = (await repo.query('ws')).single;
    expect(e.success, isFalse);
    expect(e.toolName, 'decode_token');
    expect(e.metadata, {'reason': 'denied', 'count': 3});
  });

  test('filters by event type and time range', () async {
    await rec('a', AuditEventType.decode, 1000);
    await rec('b', AuditEventType.export, 2000);
    await rec('c', AuditEventType.decode, 3000);

    final decodes = await repo.query('ws', eventTypes: [AuditEventType.decode]);
    expect(decodes.map((e) => e.id), ['c', 'a']);

    final windowed = await repo.query(
      'ws',
      sinceEpochMs: 2000,
      untilEpochMs: 3000,
    );
    expect(windowed.map((e) => e.id), ['b']); // [2000,3000)
  });

  test('paginates with limit + offset', () async {
    for (var i = 0; i < 5; i++) {
      await rec('e$i', AuditEventType.export, i * 100);
    }
    final page1 = await repo.query('ws', limit: 2);
    final page2 = await repo.query('ws', limit: 2, offset: 2);
    expect(page1.map((e) => e.id), ['e4', 'e3']);
    expect(page2.map((e) => e.id), ['e2', 'e1']);
  });

  test('exports CSV with header and escaped fields', () async {
    await rec(
      'x',
      AuditEventType.export,
      1,
      tool: 'export_document',
      meta: {'note': 'has, comma and "quote"'},
    );
    final csv = AuditLogRepository.exportCsv(await repo.query('ws'));
    final lines = csv.trimRight().split('\n');
    expect(lines.first, startsWith('created_at,event_type,success'));
    expect(lines[1], startsWith('1,export,true')); // created_at,type,success
    expect(lines[1], contains('export_document'));
    // The metadata JSON has a comma + quotes → the field is RFC-4180 quoted
    // with internal double-quotes doubled.
    expect(lines[1], contains('""note""'));
  });
}
