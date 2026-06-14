import 'package:drift/drift.dart';

import '../../data/app_database.dart';
import '../../data/id_generator.dart';
import '../anonymization/operator.dart';
import '../audit/audit_event_type.dart';
import '../audit/audit_log_repository.dart';
import '../custom_entities/custom_entity_definition.dart';
import '../custom_entities/custom_entity_repository.dart';
import '../documents/document_repository.dart';
import 'project_manifest.dart';

/// CRUD for Projects (blueprint §6) against the unlocked vault. A Project is a
/// declarative, isolated workspace defined by a versioned [ProjectManifest]
/// stored in `projects.manifest_json`. Creation seeds the manifest's custom
/// entity types as Project-scoped rows; every mutation is audited
/// (`project_created` / `project_modified` / `project_archived`).
///
/// Isolation (§6.7) is enforced at the repository layer: callers scope reads by
/// `workspaceId` (+ `projectId` where applicable). Cross-Project access is a
/// later, explicitly-audited API (blueprint §6.7) — not part of 14a.
class ProjectRepository {
  ProjectRepository(
    this._db, {
    IdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final IdGenerator _newId;
  final DateTime Function() _clock;

  /// Creates a Project from a manifest JSON string. Inserts the `projects` row
  /// (version 1), seeds the manifest's custom entity types as Project-scoped
  /// rows, and audits `project_created`. Returns the new Project id.
  Future<String> create({
    required String name,
    required String manifestJson,
    String? templateId,
    String workspaceId = DocumentRepository.defaultWorkspaceId,
  }) async {
    // Reuse the canonical workspace-ensure so the FK holds before insert.
    await DocumentRepository(_db, clock: _clock).ensureDefaultWorkspace();
    final manifest = ProjectManifest.parse(manifestJson);
    final now = _clock().millisecondsSinceEpoch;
    final projectId = _newId();

    await _db.transaction(() async {
      await _db
          .into(_db.projects)
          .insert(
            ProjectsCompanion.insert(
              id: projectId,
              workspaceId: workspaceId,
              name: name,
              templateId: Value(templateId ?? manifest.templateId),
              manifestJson: manifestJson,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final customEntities = CustomEntityRepository(_db);
      for (final seed in manifest.customEntitySeeds) {
        await customEntities.save(
          _seedToDefinition(
            seed,
            workspaceId: workspaceId,
            projectId: projectId,
            now: now,
          ),
        );
      }

      await AuditLogRepository(_db).record(
        id: _newId(),
        workspaceId: workspaceId,
        projectId: projectId,
        eventType: AuditEventType.projectCreated,
        success: true,
        metadata: {
          'templateId': templateId ?? manifest.templateId,
          'manifestVersion': 1,
          'seededEntityCount': manifest.customEntitySeeds.length,
        },
        nowEpochMs: now,
      );
    });

    return projectId;
  }

  /// A single Project by id, or null if absent.
  Future<Project?> getById(String id) => (_db.select(
    _db.projects,
  )..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Active (non-archived) Projects in the workspace, most-recently-updated
  /// first.
  Future<List<Project>> listActive({
    String workspaceId = DocumentRepository.defaultWorkspaceId,
  }) {
    return (_db.select(_db.projects)
          ..where((p) => p.workspaceId.equals(workspaceId))
          ..where((p) => p.archived.equals(0))
          ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)]))
        .get();
  }

  /// Replaces a Project's manifest, bumping `manifest_version` and `updated_at`,
  /// and audits `project_modified` (version delta only — never PII).
  Future<void> updateManifest(String id, String manifestJson) async {
    await _db.transaction(() async {
      final current = await getById(id);
      if (current == null) {
        throw StateError('No such project: $id');
      }
      final nextVersion = current.manifestVersion + 1;
      final now = _clock().millisecondsSinceEpoch;
      await (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
        ProjectsCompanion(
          manifestJson: Value(manifestJson),
          manifestVersion: Value(nextVersion),
          updatedAt: Value(now),
        ),
      );
      await AuditLogRepository(_db).record(
        id: _newId(),
        workspaceId: current.workspaceId,
        projectId: id,
        eventType: AuditEventType.projectModified,
        success: true,
        metadata: {
          'fromVersion': current.manifestVersion,
          'toVersion': nextVersion,
        },
        nowEpochMs: now,
      );
    });
  }

  /// Archives or restores a Project (soft-delete; its data is preserved), and
  /// audits `project_archived`.
  Future<void> setArchived(String id, bool archived) async {
    await _db.transaction(() async {
      final current = await getById(id);
      if (current == null) {
        throw StateError('No such project: $id');
      }
      final now = _clock().millisecondsSinceEpoch;
      await (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
        ProjectsCompanion(
          archived: Value(archived ? 1 : 0),
          updatedAt: Value(now),
        ),
      );
      await AuditLogRepository(_db).record(
        id: _newId(),
        workspaceId: current.workspaceId,
        projectId: id,
        eventType: AuditEventType.projectArchived,
        success: true,
        metadata: {'archived': archived},
        nowEpochMs: now,
      );
    });
  }

  /// Maps a raw manifest `custom_entity_types` seed into a [CustomEntityDefinition].
  /// Defensive: unknown/unsupported validators fall back to `none` and a missing
  /// operator falls back to redact, so a manifest never aborts creation. (V1
  /// supports `none`/`luhn`; richer validators like `luhn_npi` need an enum
  /// extension — tracked in DECISIONS.md for the verified-templates work, 14b.)
  CustomEntityDefinition _seedToDefinition(
    Map<String, dynamic> seed, {
    required String workspaceId,
    required String projectId,
    required int now,
  }) {
    return CustomEntityDefinition(
      id: _newId(),
      workspaceId: workspaceId,
      projectId: projectId,
      label: seed['label'] as String,
      regexPattern: (seed['regex'] ?? seed['regex_pattern'] ?? '') as String,
      validator: _validatorFromSeed(seed['validator'] as String?),
      examples: [
        for (final e in (seed['examples'] as List<dynamic>? ?? const []))
          e as String,
      ],
      defaultOperator: _operatorFromSeed(seed['default_operator'] as String?),
      createdAtEpochMs: now,
    );
  }

  CustomValidator _validatorFromSeed(String? id) {
    try {
      return CustomValidator.fromId(id);
    } on FormatException {
      return CustomValidator.none;
    }
  }

  Operator _operatorFromSeed(String? name) {
    if (name == null) return Operator.redact;
    try {
      return Operator.fromPolicyName(name);
    } catch (_) {
      return Operator.redact;
    }
  }
}
