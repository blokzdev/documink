import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/app_database.dart';
import '../../data/id_generator.dart';
import '../audit/audit_event_type.dart';
import '../audit/audit_log_repository.dart';
import '../documents/document_repository.dart';
import 'personal_template.dart';

/// Persists a user's personal Project templates (blueprint §6.5) to `vault_meta`,
/// one row per template under the `personal_templates:<id>` key (mirrors
/// [ProfilerRepository]'s single-blob convention). No drift table / schema bump —
/// these are small JSON blobs that live in the encrypted vault.
///
/// Saving/deleting is audited (`personal_template_saved` / `_deleted`) with the
/// template id only — never the manifest body or any document content (it holds
/// config, not PII). CRDT sync of these is deferred (V3).
class PersonalTemplateRepository {
  PersonalTemplateRepository(
    this._db, {
    IdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final IdGenerator _newId;
  final DateTime Function() _clock;

  static const String _keyPrefix = 'personal_templates:';

  String _key(String id) => '$_keyPrefix$id';

  /// Saves [template] (insert or replace by id) and audits the write.
  Future<void> save(PersonalTemplate template) async {
    // The audit row FKs the workspace; ensure it (idempotent — mirrors
    // ProjectRepository) so a first write doesn't trip the constraint.
    await DocumentRepository(_db, clock: _clock).ensureDefaultWorkspace();
    final blob = Uint8List.fromList(utf8.encode(template.encode()));
    await _db.transaction(() async {
      await _db
          .into(_db.vaultMeta)
          .insertOnConflictUpdate(
            VaultMetaCompanion.insert(key: _key(template.id), value: blob),
          );
      await AuditLogRepository(_db).record(
        id: _newId(),
        workspaceId: DocumentRepository.defaultWorkspaceId,
        eventType: AuditEventType.personalTemplateSaved,
        success: true,
        metadata: {'templateId': template.id, 'origin': template.origin.name},
        nowEpochMs: _clock().millisecondsSinceEpoch,
      );
    });
  }

  /// All saved personal templates, newest-created first.
  Future<List<PersonalTemplate>> list() async {
    final rows = await (_db.select(
      _db.vaultMeta,
    )..where((t) => t.key.like('$_keyPrefix%'))).get();
    final templates = [
      for (final row in rows) PersonalTemplate.decode(utf8.decode(row.value)),
    ]..sort((a, b) => b.createdAtEpochMs.compareTo(a.createdAtEpochMs));
    return templates;
  }

  /// A single personal template by id, or null if absent.
  Future<PersonalTemplate?> getById(String id) async {
    final row = await (_db.select(
      _db.vaultMeta,
    )..where((t) => t.key.equals(_key(id)))).getSingleOrNull();
    if (row == null) return null;
    return PersonalTemplate.decode(utf8.decode(row.value));
  }

  /// Deletes a personal template and audits the removal.
  Future<void> delete(String id) async {
    await DocumentRepository(_db, clock: _clock).ensureDefaultWorkspace();
    await _db.transaction(() async {
      await (_db.delete(
        _db.vaultMeta,
      )..where((t) => t.key.equals(_key(id)))).go();
      await AuditLogRepository(_db).record(
        id: _newId(),
        workspaceId: DocumentRepository.defaultWorkspaceId,
        eventType: AuditEventType.personalTemplateDeleted,
        success: true,
        metadata: {'templateId': id},
        nowEpochMs: _clock().millisecondsSinceEpoch,
      );
    });
  }
}
