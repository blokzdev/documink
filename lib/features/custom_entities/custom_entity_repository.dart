import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/app_database.dart';
import '../anonymization/operator.dart';
import 'custom_entity_definition.dart';

/// Persists [CustomEntityDefinition]s to the `custom_entity_types` table
/// (blueprint §3.1, roadmap §6). Project-scoped rows carry a `projectId`;
/// workspace-global rows leave it null. Requires the unlocked vault DB.
class CustomEntityRepository {
  CustomEntityRepository(this._db);

  final AppDatabase _db;

  Future<void> save(CustomEntityDefinition def) async {
    await _db
        .into(_db.customEntityTypes)
        .insertOnConflictUpdate(_toCompanion(def));
  }

  Future<void> delete(String id) async {
    await (_db.delete(
      _db.customEntityTypes,
    )..where((t) => t.id.equals(id))).go();
  }

  /// All definitions in scope: the workspace-global ones plus, when
  /// [projectId] is given, that Project's own (roadmap §6 / §6.7 isolation).
  Future<List<CustomEntityDefinition>> listInScope(
    String workspaceId, {
    String? projectId,
  }) async {
    final query = _db.select(_db.customEntityTypes)
      ..where((t) => t.workspaceId.equals(workspaceId))
      ..where(
        (t) => projectId == null
            ? t.projectId.isNull()
            : t.projectId.isNull() | t.projectId.equals(projectId),
      );
    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  CustomEntityTypesCompanion _toCompanion(CustomEntityDefinition d) =>
      CustomEntityTypesCompanion.insert(
        id: d.id,
        workspaceId: d.workspaceId,
        projectId: Value(d.projectId),
        label: d.label,
        regexPattern: Value(d.regexPattern),
        validator: Value(d.validator.id),
        examplesJson: Value(jsonEncode(d.examples)),
        defaultOperator: d.defaultOperator.policyName,
        createdAt: d.createdAtEpochMs,
      );

  CustomEntityDefinition _fromRow(CustomEntityType row) =>
      CustomEntityDefinition(
        id: row.id,
        workspaceId: row.workspaceId,
        projectId: row.projectId,
        label: row.label,
        regexPattern: row.regexPattern ?? '',
        validator: CustomValidator.fromId(row.validator),
        examples: row.examplesJson == null
            ? const []
            : (jsonDecode(row.examplesJson!) as List<dynamic>).cast<String>(),
        defaultOperator: Operator.fromPolicyName(row.defaultOperator),
        createdAtEpochMs: row.createdAt,
      );
}
