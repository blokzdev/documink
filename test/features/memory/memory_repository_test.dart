import 'package:documink/data/app_database.dart';
import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/detection/recognizers/email_recognizer.dart';
import 'package:documink/features/detection/recognizers/ssn_recognizer.dart';
import 'package:documink/features/memory/memory_guard.dart';
import 'package:documink/features/memory/memory_pii_scanner.dart';
import 'package:documink/features/memory/memory_repository.dart';
import 'package:documink/features/memory/token_reference.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MemoryRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final guard = MemoryWriteGuard(
      MemoryPiiScanner(DetectionPipeline([EmailRecognizer(), SsnRecognizer()])),
    );
    repo = MemoryRepository(db, guard);
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
    for (final p in ['p1', 'p2']) {
      await db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              id: p,
              workspaceId: 'ws',
              name: p,
              manifestJson: '{}',
              createdAt: 0,
              updatedAt: 0,
            ),
          );
    }
  });
  tearDown(() async => db.close());

  group('Core memory', () {
    test('writes clean value and recalls it', () async {
      await repo.writeCore(
        id: 'c1',
        workspaceId: 'ws',
        key: 'user_preferred_tone',
        value: 'formal',
        provenance: 'user',
        nowEpochMs: 10,
      );
      final entries = await repo.recallCore('ws');
      expect(entries.single.key, 'user_preferred_tone');
      expect(entries.single.value, 'formal');
    });

    test('rejects a write containing unreferenced PII', () async {
      expect(
        () => repo.writeCore(
          id: 'c2',
          workspaceId: 'ws',
          key: 'contact',
          value: {'note': 'reach at a@b.com'},
          provenance: 'user',
          nowEpochMs: 10,
        ),
        throwsA(isA<MemoryPiiLeakError>()),
      );
      expect(await repo.recallCore('ws'), isEmpty); // nothing persisted
    });

    test('accepts token-referenced value', () async {
      await repo.writeCore(
        id: 'c3',
        workspaceId: 'ws',
        key: 'primary_doctor',
        value: const TokenRef(
          tokenId: 'tok_x',
          displayFallbackType: 'PERSON',
        ).toJson(),
        provenance: 'mink',
        nowEpochMs: 10,
      );
      expect(await repo.recallCore('ws'), hasLength(1));
    });

    test('recall scoping: globals + current project only', () async {
      await repo.writeCore(
        id: 'g',
        workspaceId: 'ws',
        key: 'k',
        value: 'global',
        provenance: 'user',
        nowEpochMs: 1,
      );
      await repo.writeCore(
        id: 'a',
        workspaceId: 'ws',
        projectId: 'p1',
        key: 'k',
        value: 'p1',
        provenance: 'user',
        nowEpochMs: 1,
      );
      await repo.writeCore(
        id: 'b',
        workspaceId: 'ws',
        projectId: 'p2',
        key: 'k',
        value: 'p2',
        provenance: 'user',
        nowEpochMs: 1,
      );
      expect((await repo.recallCore('ws')).map((e) => e.id), ['g']);
      expect(
        (await repo.recallCore('ws', projectId: 'p1')).map((e) => e.id).toSet(),
        {'g', 'a'},
      );
    });
  });

  group('Episodic memory', () {
    Future<void> episode(String id, int at, {String type = 'scan'}) =>
        repo.writeEpisodic(
          id: id,
          workspaceId: 'ws',
          occurredAt: at,
          summary: 'did something at $at',
          episodeType: type,
          nowEpochMs: at,
        );

    test('recalls newest-first with since/type/limit filters', () async {
      await episode('e1', 1000);
      await episode('e2', 2000);
      await episode('e3', 3000, type: 'export');

      final recent = await repo.recallEpisodic('ws', sinceEpochMs: 2000);
      expect(recent.map((e) => e.id), ['e3', 'e2']); // desc

      final exports = await repo.recallEpisodic('ws', episodeType: 'export');
      expect(exports.map((e) => e.id), ['e3']);

      final capped = await repo.recallEpisodic('ws', limit: 1);
      expect(capped.map((e) => e.id), ['e3']);
    });

    test('rejects PII in the summary', () async {
      expect(
        () => repo.writeEpisodic(
          id: 'bad',
          workspaceId: 'ws',
          occurredAt: 1,
          summary: 'mailed SSN 123-45-6789',
          episodeType: 'note',
          nowEpochMs: 1,
        ),
        throwsA(isA<MemoryPiiLeakError>()),
      );
    });

    test('allows token markers in the summary', () async {
      await repo.writeEpisodic(
        id: 'ok',
        workspaceId: 'ws',
        occurredAt: 1,
        summary: 'found 14 mentions of <<tok_01HXJ4>>',
        episodeType: 'recall',
        tokenRefs: const ['tok_01HXJ4'],
        nowEpochMs: 1,
      );
      final e = (await repo.recallEpisodic('ws')).single;
      expect(e.tokenRefs, ['tok_01HXJ4']);
    });
  });

  test('forget removes entries', () async {
    await repo.writeCore(
      id: 'c',
      workspaceId: 'ws',
      key: 'k',
      value: 'v',
      provenance: 'user',
      nowEpochMs: 1,
    );
    await repo.forgetCore('c');
    expect(await repo.recallCore('ws'), isEmpty);
  });
}
