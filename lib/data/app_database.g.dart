// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kekVersionMeta = const VerificationMeta(
    'kekVersion',
  );
  @override
  late final GeneratedColumn<int> kekVersion = GeneratedColumn<int>(
    'kek_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, kekVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('kek_version')) {
      context.handle(
        _kekVersionMeta,
        kekVersion.isAcceptableOrUnknown(data['kek_version']!, _kekVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_kekVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      kekVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kek_version'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final String id;
  final String name;
  final int createdAt;
  final int kekVersion;
  const Workspace({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.kekVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['kek_version'] = Variable<int>(kekVersion);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      kekVersion: Value(kekVersion),
    );
  }

  factory Workspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      kekVersion: serializer.fromJson<int>(json['kekVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'kekVersion': serializer.toJson<int>(kekVersion),
    };
  }

  Workspace copyWith({
    String? id,
    String? name,
    int? createdAt,
    int? kekVersion,
  }) => Workspace(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    kekVersion: kekVersion ?? this.kekVersion,
  );
  Workspace copyWithCompanion(WorkspacesCompanion data) {
    return Workspace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      kekVersion: data.kekVersion.present
          ? data.kekVersion.value
          : this.kekVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('kekVersion: $kekVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, kekVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.kekVersion == this.kekVersion);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> kekVersion;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.kekVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    required int kekVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       kekVersion = Value(kekVersion);
  static Insertable<Workspace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? kekVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (kekVersion != null) 'kek_version': kekVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? kekVersion,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      kekVersion: kekVersion ?? this.kekVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (kekVersion.present) {
      map['kek_version'] = Variable<int>(kekVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('kekVersion: $kekVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manifestJsonMeta = const VerificationMeta(
    'manifestJson',
  );
  @override
  late final GeneratedColumn<String> manifestJson = GeneratedColumn<String>(
    'manifest_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manifestVersionMeta = const VerificationMeta(
    'manifestVersion',
  );
  @override
  late final GeneratedColumn<int> manifestVersion = GeneratedColumn<int>(
    'manifest_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<int> archived = GeneratedColumn<int>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    name,
    templateId,
    manifestJson,
    manifestVersion,
    createdAt,
    updatedAt,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('manifest_json')) {
      context.handle(
        _manifestJsonMeta,
        manifestJson.isAcceptableOrUnknown(
          data['manifest_json']!,
          _manifestJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manifestJsonMeta);
    }
    if (data.containsKey('manifest_version')) {
      context.handle(
        _manifestVersionMeta,
        manifestVersion.isAcceptableOrUnknown(
          data['manifest_version']!,
          _manifestVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      manifestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_json'],
      )!,
      manifestVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manifest_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String workspaceId;
  final String name;
  final String? templateId;
  final String manifestJson;
  final int manifestVersion;
  final int createdAt;
  final int updatedAt;
  final int archived;
  const Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.templateId,
    required this.manifestJson,
    required this.manifestVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['manifest_json'] = Variable<String>(manifestJson);
    map['manifest_version'] = Variable<int>(manifestVersion);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['archived'] = Variable<int>(archived);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      name: Value(name),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      manifestJson: Value(manifestJson),
      manifestVersion: Value(manifestVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archived: Value(archived),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      manifestJson: serializer.fromJson<String>(json['manifestJson']),
      manifestVersion: serializer.fromJson<int>(json['manifestVersion']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      archived: serializer.fromJson<int>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'templateId': serializer.toJson<String?>(templateId),
      'manifestJson': serializer.toJson<String>(manifestJson),
      'manifestVersion': serializer.toJson<int>(manifestVersion),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'archived': serializer.toJson<int>(archived),
    };
  }

  Project copyWith({
    String? id,
    String? workspaceId,
    String? name,
    Value<String?> templateId = const Value.absent(),
    String? manifestJson,
    int? manifestVersion,
    int? createdAt,
    int? updatedAt,
    int? archived,
  }) => Project(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    templateId: templateId.present ? templateId.value : this.templateId,
    manifestJson: manifestJson ?? this.manifestJson,
    manifestVersion: manifestVersion ?? this.manifestVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archived: archived ?? this.archived,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      manifestJson: data.manifestJson.present
          ? data.manifestJson.value
          : this.manifestJson,
      manifestVersion: data.manifestVersion.present
          ? data.manifestVersion.value
          : this.manifestVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('templateId: $templateId, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('manifestVersion: $manifestVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    name,
    templateId,
    manifestJson,
    manifestVersion,
    createdAt,
    updatedAt,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.templateId == this.templateId &&
          other.manifestJson == this.manifestJson &&
          other.manifestVersion == this.manifestVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archived == this.archived);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String?> templateId;
  final Value<String> manifestJson;
  final Value<int> manifestVersion;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> archived;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.templateId = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.manifestVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String workspaceId,
    required String name,
    this.templateId = const Value.absent(),
    required String manifestJson,
    this.manifestVersion = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name),
       manifestJson = Value(manifestJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? templateId,
    Expression<String>? manifestJson,
    Expression<int>? manifestVersion,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (templateId != null) 'template_id': templateId,
      if (manifestJson != null) 'manifest_json': manifestJson,
      if (manifestVersion != null) 'manifest_version': manifestVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String?>? templateId,
    Value<String>? manifestJson,
    Value<int>? manifestVersion,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? archived,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      manifestJson: manifestJson ?? this.manifestJson,
      manifestVersion: manifestVersion ?? this.manifestVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (manifestJson.present) {
      map['manifest_json'] = Variable<String>(manifestJson.value);
    }
    if (manifestVersion.present) {
      map['manifest_version'] = Variable<int>(manifestVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<int>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('templateId: $templateId, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('manifestVersion: $manifestVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<Uint8List> sourceHash = GeneratedColumn<Uint8List>(
    'source_hash',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _redactedArtifactPathMeta =
      const VerificationMeta('redactedArtifactPath');
  @override
  late final GeneratedColumn<String> redactedArtifactPath =
      GeneratedColumn<String>(
        'redacted_artifact_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    name,
    type,
    sourceHash,
    createdAt,
    updatedAt,
    redactedArtifactPath,
    status,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('redacted_artifact_path')) {
      context.handle(
        _redactedArtifactPathMeta,
        redactedArtifactPath.isAcceptableOrUnknown(
          data['redacted_artifact_path']!,
          _redactedArtifactPathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}source_hash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      redactedArtifactPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redacted_artifact_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String name;
  final String type;
  final Uint8List sourceHash;
  final int createdAt;
  final int updatedAt;
  final String? redactedArtifactPath;
  final String status;
  final String? metadataJson;
  const Document({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.name,
    required this.type,
    required this.sourceHash,
    required this.createdAt,
    required this.updatedAt,
    this.redactedArtifactPath,
    required this.status,
    this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['source_hash'] = Variable<Uint8List>(sourceHash);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || redactedArtifactPath != null) {
      map['redacted_artifact_path'] = Variable<String>(redactedArtifactPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      name: Value(name),
      type: Value(type),
      sourceHash: Value(sourceHash),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      redactedArtifactPath: redactedArtifactPath == null && nullToAbsent
          ? const Value.absent()
          : Value(redactedArtifactPath),
      status: Value(status),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      sourceHash: serializer.fromJson<Uint8List>(json['sourceHash']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      redactedArtifactPath: serializer.fromJson<String?>(
        json['redactedArtifactPath'],
      ),
      status: serializer.fromJson<String>(json['status']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'sourceHash': serializer.toJson<Uint8List>(sourceHash),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'redactedArtifactPath': serializer.toJson<String?>(redactedArtifactPath),
      'status': serializer.toJson<String>(status),
      'metadataJson': serializer.toJson<String?>(metadataJson),
    };
  }

  Document copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    String? name,
    String? type,
    Uint8List? sourceHash,
    int? createdAt,
    int? updatedAt,
    Value<String?> redactedArtifactPath = const Value.absent(),
    String? status,
    Value<String?> metadataJson = const Value.absent(),
  }) => Document(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    name: name ?? this.name,
    type: type ?? this.type,
    sourceHash: sourceHash ?? this.sourceHash,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    redactedArtifactPath: redactedArtifactPath.present
        ? redactedArtifactPath.value
        : this.redactedArtifactPath,
    status: status ?? this.status,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      redactedArtifactPath: data.redactedArtifactPath.present
          ? data.redactedArtifactPath.value
          : this.redactedArtifactPath,
      status: data.status.present ? data.status.value : this.status,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('redactedArtifactPath: $redactedArtifactPath, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    name,
    type,
    $driftBlobEquality.hash(sourceHash),
    createdAt,
    updatedAt,
    redactedArtifactPath,
    status,
    metadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.type == this.type &&
          $driftBlobEquality.equals(other.sourceHash, this.sourceHash) &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.redactedArtifactPath == this.redactedArtifactPath &&
          other.status == this.status &&
          other.metadataJson == this.metadataJson);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String> name;
  final Value<String> type;
  final Value<Uint8List> sourceHash;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> redactedArtifactPath;
  final Value<String> status;
  final Value<String?> metadataJson;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.redactedArtifactPath = const Value.absent(),
    this.status = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String name,
    required String type,
    required Uint8List sourceHash,
    required int createdAt,
    required int updatedAt,
    this.redactedArtifactPath = const Value.absent(),
    required String status,
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name),
       type = Value(type),
       sourceHash = Value(sourceHash),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       status = Value(status);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<Uint8List>? sourceHash,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? redactedArtifactPath,
    Expression<String>? status,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (sourceHash != null) 'source_hash': sourceHash,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (redactedArtifactPath != null)
        'redacted_artifact_path': redactedArtifactPath,
      if (status != null) 'status': status,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String>? name,
    Value<String>? type,
    Value<Uint8List>? sourceHash,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? redactedArtifactPath,
    Value<String>? status,
    Value<String?>? metadataJson,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      type: type ?? this.type,
      sourceHash: sourceHash ?? this.sourceHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      redactedArtifactPath: redactedArtifactPath ?? this.redactedArtifactPath,
      status: status ?? this.status,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sourceHash.present) {
      map['source_hash'] = Variable<Uint8List>(sourceHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (redactedArtifactPath.present) {
      map['redacted_artifact_path'] = Variable<String>(
        redactedArtifactPath.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('redactedArtifactPath: $redactedArtifactPath, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntitiesTable extends Entities with TableInfo<$EntitiesTable, Entity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id)',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectorMeta = const VerificationMeta(
    'detector',
  );
  @override
  late final GeneratedColumn<String> detector = GeneratedColumn<String>(
    'detector',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spanStartMeta = const VerificationMeta(
    'spanStart',
  );
  @override
  late final GeneratedColumn<int> spanStart = GeneratedColumn<int>(
    'span_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spanEndMeta = const VerificationMeta(
    'spanEnd',
  );
  @override
  late final GeneratedColumn<int> spanEnd = GeneratedColumn<int>(
    'span_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operatorAppliedMeta = const VerificationMeta(
    'operatorApplied',
  );
  @override
  late final GeneratedColumn<String> operatorApplied = GeneratedColumn<String>(
    'operator_applied',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    documentId,
    entityType,
    detector,
    spanStart,
    spanEnd,
    confidence,
    operatorApplied,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('detector')) {
      context.handle(
        _detectorMeta,
        detector.isAcceptableOrUnknown(data['detector']!, _detectorMeta),
      );
    } else if (isInserting) {
      context.missing(_detectorMeta);
    }
    if (data.containsKey('span_start')) {
      context.handle(
        _spanStartMeta,
        spanStart.isAcceptableOrUnknown(data['span_start']!, _spanStartMeta),
      );
    } else if (isInserting) {
      context.missing(_spanStartMeta);
    }
    if (data.containsKey('span_end')) {
      context.handle(
        _spanEndMeta,
        spanEnd.isAcceptableOrUnknown(data['span_end']!, _spanEndMeta),
      );
    } else if (isInserting) {
      context.missing(_spanEndMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('operator_applied')) {
      context.handle(
        _operatorAppliedMeta,
        operatorApplied.isAcceptableOrUnknown(
          data['operator_applied']!,
          _operatorAppliedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operatorAppliedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      detector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detector'],
      )!,
      spanStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}span_start'],
      )!,
      spanEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}span_end'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      operatorApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_applied'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EntitiesTable createAlias(String alias) {
    return $EntitiesTable(attachedDatabase, alias);
  }
}

class Entity extends DataClass implements Insertable<Entity> {
  final String id;
  final String workspaceId;
  final String documentId;
  final String entityType;
  final String detector;
  final int spanStart;
  final int spanEnd;
  final double confidence;
  final String operatorApplied;
  final int createdAt;
  const Entity({
    required this.id,
    required this.workspaceId,
    required this.documentId,
    required this.entityType,
    required this.detector,
    required this.spanStart,
    required this.spanEnd,
    required this.confidence,
    required this.operatorApplied,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['document_id'] = Variable<String>(documentId);
    map['entity_type'] = Variable<String>(entityType);
    map['detector'] = Variable<String>(detector);
    map['span_start'] = Variable<int>(spanStart);
    map['span_end'] = Variable<int>(spanEnd);
    map['confidence'] = Variable<double>(confidence);
    map['operator_applied'] = Variable<String>(operatorApplied);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  EntitiesCompanion toCompanion(bool nullToAbsent) {
    return EntitiesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      documentId: Value(documentId),
      entityType: Value(entityType),
      detector: Value(detector),
      spanStart: Value(spanStart),
      spanEnd: Value(spanEnd),
      confidence: Value(confidence),
      operatorApplied: Value(operatorApplied),
      createdAt: Value(createdAt),
    );
  }

  factory Entity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entity(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      detector: serializer.fromJson<String>(json['detector']),
      spanStart: serializer.fromJson<int>(json['spanStart']),
      spanEnd: serializer.fromJson<int>(json['spanEnd']),
      confidence: serializer.fromJson<double>(json['confidence']),
      operatorApplied: serializer.fromJson<String>(json['operatorApplied']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'documentId': serializer.toJson<String>(documentId),
      'entityType': serializer.toJson<String>(entityType),
      'detector': serializer.toJson<String>(detector),
      'spanStart': serializer.toJson<int>(spanStart),
      'spanEnd': serializer.toJson<int>(spanEnd),
      'confidence': serializer.toJson<double>(confidence),
      'operatorApplied': serializer.toJson<String>(operatorApplied),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Entity copyWith({
    String? id,
    String? workspaceId,
    String? documentId,
    String? entityType,
    String? detector,
    int? spanStart,
    int? spanEnd,
    double? confidence,
    String? operatorApplied,
    int? createdAt,
  }) => Entity(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    documentId: documentId ?? this.documentId,
    entityType: entityType ?? this.entityType,
    detector: detector ?? this.detector,
    spanStart: spanStart ?? this.spanStart,
    spanEnd: spanEnd ?? this.spanEnd,
    confidence: confidence ?? this.confidence,
    operatorApplied: operatorApplied ?? this.operatorApplied,
    createdAt: createdAt ?? this.createdAt,
  );
  Entity copyWithCompanion(EntitiesCompanion data) {
    return Entity(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      detector: data.detector.present ? data.detector.value : this.detector,
      spanStart: data.spanStart.present ? data.spanStart.value : this.spanStart,
      spanEnd: data.spanEnd.present ? data.spanEnd.value : this.spanEnd,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      operatorApplied: data.operatorApplied.present
          ? data.operatorApplied.value
          : this.operatorApplied,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entity(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('documentId: $documentId, ')
          ..write('entityType: $entityType, ')
          ..write('detector: $detector, ')
          ..write('spanStart: $spanStart, ')
          ..write('spanEnd: $spanEnd, ')
          ..write('confidence: $confidence, ')
          ..write('operatorApplied: $operatorApplied, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    documentId,
    entityType,
    detector,
    spanStart,
    spanEnd,
    confidence,
    operatorApplied,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entity &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.documentId == this.documentId &&
          other.entityType == this.entityType &&
          other.detector == this.detector &&
          other.spanStart == this.spanStart &&
          other.spanEnd == this.spanEnd &&
          other.confidence == this.confidence &&
          other.operatorApplied == this.operatorApplied &&
          other.createdAt == this.createdAt);
}

class EntitiesCompanion extends UpdateCompanion<Entity> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> documentId;
  final Value<String> entityType;
  final Value<String> detector;
  final Value<int> spanStart;
  final Value<int> spanEnd;
  final Value<double> confidence;
  final Value<String> operatorApplied;
  final Value<int> createdAt;
  final Value<int> rowid;
  const EntitiesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.detector = const Value.absent(),
    this.spanStart = const Value.absent(),
    this.spanEnd = const Value.absent(),
    this.confidence = const Value.absent(),
    this.operatorApplied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitiesCompanion.insert({
    required String id,
    required String workspaceId,
    required String documentId,
    required String entityType,
    required String detector,
    required int spanStart,
    required int spanEnd,
    required double confidence,
    required String operatorApplied,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       documentId = Value(documentId),
       entityType = Value(entityType),
       detector = Value(detector),
       spanStart = Value(spanStart),
       spanEnd = Value(spanEnd),
       confidence = Value(confidence),
       operatorApplied = Value(operatorApplied),
       createdAt = Value(createdAt);
  static Insertable<Entity> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? documentId,
    Expression<String>? entityType,
    Expression<String>? detector,
    Expression<int>? spanStart,
    Expression<int>? spanEnd,
    Expression<double>? confidence,
    Expression<String>? operatorApplied,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (documentId != null) 'document_id': documentId,
      if (entityType != null) 'entity_type': entityType,
      if (detector != null) 'detector': detector,
      if (spanStart != null) 'span_start': spanStart,
      if (spanEnd != null) 'span_end': spanEnd,
      if (confidence != null) 'confidence': confidence,
      if (operatorApplied != null) 'operator_applied': operatorApplied,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? documentId,
    Value<String>? entityType,
    Value<String>? detector,
    Value<int>? spanStart,
    Value<int>? spanEnd,
    Value<double>? confidence,
    Value<String>? operatorApplied,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return EntitiesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      documentId: documentId ?? this.documentId,
      entityType: entityType ?? this.entityType,
      detector: detector ?? this.detector,
      spanStart: spanStart ?? this.spanStart,
      spanEnd: spanEnd ?? this.spanEnd,
      confidence: confidence ?? this.confidence,
      operatorApplied: operatorApplied ?? this.operatorApplied,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (detector.present) {
      map['detector'] = Variable<String>(detector.value);
    }
    if (spanStart.present) {
      map['span_start'] = Variable<int>(spanStart.value);
    }
    if (spanEnd.present) {
      map['span_end'] = Variable<int>(spanEnd.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (operatorApplied.present) {
      map['operator_applied'] = Variable<String>(operatorApplied.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitiesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('documentId: $documentId, ')
          ..write('entityType: $entityType, ')
          ..write('detector: $detector, ')
          ..write('spanStart: $spanStart, ')
          ..write('spanEnd: $spanEnd, ')
          ..write('confidence: $confidence, ')
          ..write('operatorApplied: $operatorApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TokensTable extends Tokens with TableInfo<$TokensTable, Token> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id)',
    ),
  );
  static const VerificationMeta _tokenValueMeta = const VerificationMeta(
    'tokenValue',
  );
  @override
  late final GeneratedColumn<String> tokenValue = GeneratedColumn<String>(
    'token_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plaintextFingerprintMeta =
      const VerificationMeta('plaintextFingerprint');
  @override
  late final GeneratedColumn<Uint8List> plaintextFingerprint =
      GeneratedColumn<Uint8List>(
        'plaintext_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ciphertextMeta = const VerificationMeta(
    'ciphertext',
  );
  @override
  late final GeneratedColumn<Uint8List> ciphertext = GeneratedColumn<Uint8List>(
    'ciphertext',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyVersionMeta = const VerificationMeta(
    'keyVersion',
  );
  @override
  late final GeneratedColumn<int> keyVersion = GeneratedColumn<int>(
    'key_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    entityId,
    tokenValue,
    plaintextFingerprint,
    ciphertext,
    keyVersion,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Token> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('token_value')) {
      context.handle(
        _tokenValueMeta,
        tokenValue.isAcceptableOrUnknown(data['token_value']!, _tokenValueMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenValueMeta);
    }
    if (data.containsKey('plaintext_fingerprint')) {
      context.handle(
        _plaintextFingerprintMeta,
        plaintextFingerprint.isAcceptableOrUnknown(
          data['plaintext_fingerprint']!,
          _plaintextFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plaintextFingerprintMeta);
    }
    if (data.containsKey('ciphertext')) {
      context.handle(
        _ciphertextMeta,
        ciphertext.isAcceptableOrUnknown(data['ciphertext']!, _ciphertextMeta),
      );
    } else if (isInserting) {
      context.missing(_ciphertextMeta);
    }
    if (data.containsKey('key_version')) {
      context.handle(
        _keyVersionMeta,
        keyVersion.isAcceptableOrUnknown(data['key_version']!, _keyVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_keyVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Token map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Token(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      tokenValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_value'],
      )!,
      plaintextFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}plaintext_fingerprint'],
      )!,
      ciphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}ciphertext'],
      )!,
      keyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TokensTable createAlias(String alias) {
    return $TokensTable(attachedDatabase, alias);
  }
}

class Token extends DataClass implements Insertable<Token> {
  final String id;
  final String workspaceId;
  final String entityId;
  final String tokenValue;
  final Uint8List plaintextFingerprint;
  final Uint8List ciphertext;
  final int keyVersion;
  final int createdAt;
  const Token({
    required this.id,
    required this.workspaceId,
    required this.entityId,
    required this.tokenValue,
    required this.plaintextFingerprint,
    required this.ciphertext,
    required this.keyVersion,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['entity_id'] = Variable<String>(entityId);
    map['token_value'] = Variable<String>(tokenValue);
    map['plaintext_fingerprint'] = Variable<Uint8List>(plaintextFingerprint);
    map['ciphertext'] = Variable<Uint8List>(ciphertext);
    map['key_version'] = Variable<int>(keyVersion);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TokensCompanion toCompanion(bool nullToAbsent) {
    return TokensCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      entityId: Value(entityId),
      tokenValue: Value(tokenValue),
      plaintextFingerprint: Value(plaintextFingerprint),
      ciphertext: Value(ciphertext),
      keyVersion: Value(keyVersion),
      createdAt: Value(createdAt),
    );
  }

  factory Token.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Token(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      tokenValue: serializer.fromJson<String>(json['tokenValue']),
      plaintextFingerprint: serializer.fromJson<Uint8List>(
        json['plaintextFingerprint'],
      ),
      ciphertext: serializer.fromJson<Uint8List>(json['ciphertext']),
      keyVersion: serializer.fromJson<int>(json['keyVersion']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'entityId': serializer.toJson<String>(entityId),
      'tokenValue': serializer.toJson<String>(tokenValue),
      'plaintextFingerprint': serializer.toJson<Uint8List>(
        plaintextFingerprint,
      ),
      'ciphertext': serializer.toJson<Uint8List>(ciphertext),
      'keyVersion': serializer.toJson<int>(keyVersion),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Token copyWith({
    String? id,
    String? workspaceId,
    String? entityId,
    String? tokenValue,
    Uint8List? plaintextFingerprint,
    Uint8List? ciphertext,
    int? keyVersion,
    int? createdAt,
  }) => Token(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    entityId: entityId ?? this.entityId,
    tokenValue: tokenValue ?? this.tokenValue,
    plaintextFingerprint: plaintextFingerprint ?? this.plaintextFingerprint,
    ciphertext: ciphertext ?? this.ciphertext,
    keyVersion: keyVersion ?? this.keyVersion,
    createdAt: createdAt ?? this.createdAt,
  );
  Token copyWithCompanion(TokensCompanion data) {
    return Token(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      tokenValue: data.tokenValue.present
          ? data.tokenValue.value
          : this.tokenValue,
      plaintextFingerprint: data.plaintextFingerprint.present
          ? data.plaintextFingerprint.value
          : this.plaintextFingerprint,
      ciphertext: data.ciphertext.present
          ? data.ciphertext.value
          : this.ciphertext,
      keyVersion: data.keyVersion.present
          ? data.keyVersion.value
          : this.keyVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Token(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('entityId: $entityId, ')
          ..write('tokenValue: $tokenValue, ')
          ..write('plaintextFingerprint: $plaintextFingerprint, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('keyVersion: $keyVersion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    entityId,
    tokenValue,
    $driftBlobEquality.hash(plaintextFingerprint),
    $driftBlobEquality.hash(ciphertext),
    keyVersion,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Token &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.entityId == this.entityId &&
          other.tokenValue == this.tokenValue &&
          $driftBlobEquality.equals(
            other.plaintextFingerprint,
            this.plaintextFingerprint,
          ) &&
          $driftBlobEquality.equals(other.ciphertext, this.ciphertext) &&
          other.keyVersion == this.keyVersion &&
          other.createdAt == this.createdAt);
}

class TokensCompanion extends UpdateCompanion<Token> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> entityId;
  final Value<String> tokenValue;
  final Value<Uint8List> plaintextFingerprint;
  final Value<Uint8List> ciphertext;
  final Value<int> keyVersion;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TokensCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.tokenValue = const Value.absent(),
    this.plaintextFingerprint = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.keyVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokensCompanion.insert({
    required String id,
    required String workspaceId,
    required String entityId,
    required String tokenValue,
    required Uint8List plaintextFingerprint,
    required Uint8List ciphertext,
    required int keyVersion,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       entityId = Value(entityId),
       tokenValue = Value(tokenValue),
       plaintextFingerprint = Value(plaintextFingerprint),
       ciphertext = Value(ciphertext),
       keyVersion = Value(keyVersion),
       createdAt = Value(createdAt);
  static Insertable<Token> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? entityId,
    Expression<String>? tokenValue,
    Expression<Uint8List>? plaintextFingerprint,
    Expression<Uint8List>? ciphertext,
    Expression<int>? keyVersion,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (entityId != null) 'entity_id': entityId,
      if (tokenValue != null) 'token_value': tokenValue,
      if (plaintextFingerprint != null)
        'plaintext_fingerprint': plaintextFingerprint,
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (keyVersion != null) 'key_version': keyVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokensCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? entityId,
    Value<String>? tokenValue,
    Value<Uint8List>? plaintextFingerprint,
    Value<Uint8List>? ciphertext,
    Value<int>? keyVersion,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return TokensCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      entityId: entityId ?? this.entityId,
      tokenValue: tokenValue ?? this.tokenValue,
      plaintextFingerprint: plaintextFingerprint ?? this.plaintextFingerprint,
      ciphertext: ciphertext ?? this.ciphertext,
      keyVersion: keyVersion ?? this.keyVersion,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (tokenValue.present) {
      map['token_value'] = Variable<String>(tokenValue.value);
    }
    if (plaintextFingerprint.present) {
      map['plaintext_fingerprint'] = Variable<Uint8List>(
        plaintextFingerprint.value,
      );
    }
    if (ciphertext.present) {
      map['ciphertext'] = Variable<Uint8List>(ciphertext.value);
    }
    if (keyVersion.present) {
      map['key_version'] = Variable<int>(keyVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokensCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('entityId: $entityId, ')
          ..write('tokenValue: $tokenValue, ')
          ..write('plaintextFingerprint: $plaintextFingerprint, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('keyVersion: $keyVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomEntityTypesTable extends CustomEntityTypes
    with TableInfo<$CustomEntityTypesTable, CustomEntityType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomEntityTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regexPatternMeta = const VerificationMeta(
    'regexPattern',
  );
  @override
  late final GeneratedColumn<String> regexPattern = GeneratedColumn<String>(
    'regex_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validatorMeta = const VerificationMeta(
    'validator',
  );
  @override
  late final GeneratedColumn<String> validator = GeneratedColumn<String>(
    'validator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examplesJsonMeta = const VerificationMeta(
    'examplesJson',
  );
  @override
  late final GeneratedColumn<String> examplesJson = GeneratedColumn<String>(
    'examples_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultOperatorMeta = const VerificationMeta(
    'defaultOperator',
  );
  @override
  late final GeneratedColumn<String> defaultOperator = GeneratedColumn<String>(
    'default_operator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    label,
    regexPattern,
    validator,
    examplesJson,
    defaultOperator,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_entity_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomEntityType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('regex_pattern')) {
      context.handle(
        _regexPatternMeta,
        regexPattern.isAcceptableOrUnknown(
          data['regex_pattern']!,
          _regexPatternMeta,
        ),
      );
    }
    if (data.containsKey('validator')) {
      context.handle(
        _validatorMeta,
        validator.isAcceptableOrUnknown(data['validator']!, _validatorMeta),
      );
    }
    if (data.containsKey('examples_json')) {
      context.handle(
        _examplesJsonMeta,
        examplesJson.isAcceptableOrUnknown(
          data['examples_json']!,
          _examplesJsonMeta,
        ),
      );
    }
    if (data.containsKey('default_operator')) {
      context.handle(
        _defaultOperatorMeta,
        defaultOperator.isAcceptableOrUnknown(
          data['default_operator']!,
          _defaultOperatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultOperatorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {workspaceId, projectId, label},
  ];
  @override
  CustomEntityType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomEntityType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      regexPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regex_pattern'],
      ),
      validator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}validator'],
      ),
      examplesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples_json'],
      ),
      defaultOperator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_operator'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomEntityTypesTable createAlias(String alias) {
    return $CustomEntityTypesTable(attachedDatabase, alias);
  }
}

class CustomEntityType extends DataClass
    implements Insertable<CustomEntityType> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String label;
  final String? regexPattern;
  final String? validator;
  final String? examplesJson;
  final String defaultOperator;
  final int createdAt;
  const CustomEntityType({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.label,
    this.regexPattern,
    this.validator,
    this.examplesJson,
    required this.defaultOperator,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || regexPattern != null) {
      map['regex_pattern'] = Variable<String>(regexPattern);
    }
    if (!nullToAbsent || validator != null) {
      map['validator'] = Variable<String>(validator);
    }
    if (!nullToAbsent || examplesJson != null) {
      map['examples_json'] = Variable<String>(examplesJson);
    }
    map['default_operator'] = Variable<String>(defaultOperator);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CustomEntityTypesCompanion toCompanion(bool nullToAbsent) {
    return CustomEntityTypesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      label: Value(label),
      regexPattern: regexPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(regexPattern),
      validator: validator == null && nullToAbsent
          ? const Value.absent()
          : Value(validator),
      examplesJson: examplesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(examplesJson),
      defaultOperator: Value(defaultOperator),
      createdAt: Value(createdAt),
    );
  }

  factory CustomEntityType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomEntityType(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      label: serializer.fromJson<String>(json['label']),
      regexPattern: serializer.fromJson<String?>(json['regexPattern']),
      validator: serializer.fromJson<String?>(json['validator']),
      examplesJson: serializer.fromJson<String?>(json['examplesJson']),
      defaultOperator: serializer.fromJson<String>(json['defaultOperator']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'label': serializer.toJson<String>(label),
      'regexPattern': serializer.toJson<String?>(regexPattern),
      'validator': serializer.toJson<String?>(validator),
      'examplesJson': serializer.toJson<String?>(examplesJson),
      'defaultOperator': serializer.toJson<String>(defaultOperator),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CustomEntityType copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    String? label,
    Value<String?> regexPattern = const Value.absent(),
    Value<String?> validator = const Value.absent(),
    Value<String?> examplesJson = const Value.absent(),
    String? defaultOperator,
    int? createdAt,
  }) => CustomEntityType(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    label: label ?? this.label,
    regexPattern: regexPattern.present ? regexPattern.value : this.regexPattern,
    validator: validator.present ? validator.value : this.validator,
    examplesJson: examplesJson.present ? examplesJson.value : this.examplesJson,
    defaultOperator: defaultOperator ?? this.defaultOperator,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomEntityType copyWithCompanion(CustomEntityTypesCompanion data) {
    return CustomEntityType(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      label: data.label.present ? data.label.value : this.label,
      regexPattern: data.regexPattern.present
          ? data.regexPattern.value
          : this.regexPattern,
      validator: data.validator.present ? data.validator.value : this.validator,
      examplesJson: data.examplesJson.present
          ? data.examplesJson.value
          : this.examplesJson,
      defaultOperator: data.defaultOperator.present
          ? data.defaultOperator.value
          : this.defaultOperator,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomEntityType(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('label: $label, ')
          ..write('regexPattern: $regexPattern, ')
          ..write('validator: $validator, ')
          ..write('examplesJson: $examplesJson, ')
          ..write('defaultOperator: $defaultOperator, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    label,
    regexPattern,
    validator,
    examplesJson,
    defaultOperator,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomEntityType &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.label == this.label &&
          other.regexPattern == this.regexPattern &&
          other.validator == this.validator &&
          other.examplesJson == this.examplesJson &&
          other.defaultOperator == this.defaultOperator &&
          other.createdAt == this.createdAt);
}

class CustomEntityTypesCompanion extends UpdateCompanion<CustomEntityType> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String> label;
  final Value<String?> regexPattern;
  final Value<String?> validator;
  final Value<String?> examplesJson;
  final Value<String> defaultOperator;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CustomEntityTypesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.label = const Value.absent(),
    this.regexPattern = const Value.absent(),
    this.validator = const Value.absent(),
    this.examplesJson = const Value.absent(),
    this.defaultOperator = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomEntityTypesCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String label,
    this.regexPattern = const Value.absent(),
    this.validator = const Value.absent(),
    this.examplesJson = const Value.absent(),
    required String defaultOperator,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       label = Value(label),
       defaultOperator = Value(defaultOperator),
       createdAt = Value(createdAt);
  static Insertable<CustomEntityType> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? label,
    Expression<String>? regexPattern,
    Expression<String>? validator,
    Expression<String>? examplesJson,
    Expression<String>? defaultOperator,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (label != null) 'label': label,
      if (regexPattern != null) 'regex_pattern': regexPattern,
      if (validator != null) 'validator': validator,
      if (examplesJson != null) 'examples_json': examplesJson,
      if (defaultOperator != null) 'default_operator': defaultOperator,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomEntityTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String>? label,
    Value<String?>? regexPattern,
    Value<String?>? validator,
    Value<String?>? examplesJson,
    Value<String>? defaultOperator,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomEntityTypesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      label: label ?? this.label,
      regexPattern: regexPattern ?? this.regexPattern,
      validator: validator ?? this.validator,
      examplesJson: examplesJson ?? this.examplesJson,
      defaultOperator: defaultOperator ?? this.defaultOperator,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (regexPattern.present) {
      map['regex_pattern'] = Variable<String>(regexPattern.value);
    }
    if (validator.present) {
      map['validator'] = Variable<String>(validator.value);
    }
    if (examplesJson.present) {
      map['examples_json'] = Variable<String>(examplesJson.value);
    }
    if (defaultOperator.present) {
      map['default_operator'] = Variable<String>(defaultOperator.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomEntityTypesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('label: $label, ')
          ..write('regexPattern: $regexPattern, ')
          ..write('validator: $validator, ')
          ..write('examplesJson: $examplesJson, ')
          ..write('defaultOperator: $defaultOperator, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<int> success = GeneratedColumn<int>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _biometricResultMeta = const VerificationMeta(
    'biometricResult',
  );
  @override
  late final GeneratedColumn<String> biometricResult = GeneratedColumn<String>(
    'biometric_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    eventType,
    documentId,
    entityId,
    toolName,
    success,
    biometricResult,
    metadataJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('biometric_result')) {
      context.handle(
        _biometricResultMeta,
        biometricResult.isAcceptableOrUnknown(
          data['biometric_result']!,
          _biometricResultMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      ),
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}success'],
      )!,
      biometricResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}biometric_result'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String eventType;
  final String? documentId;
  final String? entityId;
  final String? toolName;
  final int success;
  final String? biometricResult;
  final String? metadataJson;
  final int createdAt;
  const AuditLogData({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.eventType,
    this.documentId,
    this.entityId,
    this.toolName,
    required this.success,
    this.biometricResult,
    this.metadataJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    if (!nullToAbsent || toolName != null) {
      map['tool_name'] = Variable<String>(toolName);
    }
    map['success'] = Variable<int>(success);
    if (!nullToAbsent || biometricResult != null) {
      map['biometric_result'] = Variable<String>(biometricResult);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      eventType: Value(eventType),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      toolName: toolName == null && nullToAbsent
          ? const Value.absent()
          : Value(toolName),
      success: Value(success),
      biometricResult: biometricResult == null && nullToAbsent
          ? const Value.absent()
          : Value(biometricResult),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      toolName: serializer.fromJson<String?>(json['toolName']),
      success: serializer.fromJson<int>(json['success']),
      biometricResult: serializer.fromJson<String?>(json['biometricResult']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'eventType': serializer.toJson<String>(eventType),
      'documentId': serializer.toJson<String?>(documentId),
      'entityId': serializer.toJson<String?>(entityId),
      'toolName': serializer.toJson<String?>(toolName),
      'success': serializer.toJson<int>(success),
      'biometricResult': serializer.toJson<String?>(biometricResult),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AuditLogData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    String? eventType,
    Value<String?> documentId = const Value.absent(),
    Value<String?> entityId = const Value.absent(),
    Value<String?> toolName = const Value.absent(),
    int? success,
    Value<String?> biometricResult = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    int? createdAt,
  }) => AuditLogData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    eventType: eventType ?? this.eventType,
    documentId: documentId.present ? documentId.value : this.documentId,
    entityId: entityId.present ? entityId.value : this.entityId,
    toolName: toolName.present ? toolName.value : this.toolName,
    success: success ?? this.success,
    biometricResult: biometricResult.present
        ? biometricResult.value
        : this.biometricResult,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      success: data.success.present ? data.success.value : this.success,
      biometricResult: data.biometricResult.present
          ? data.biometricResult.value
          : this.biometricResult,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('eventType: $eventType, ')
          ..write('documentId: $documentId, ')
          ..write('entityId: $entityId, ')
          ..write('toolName: $toolName, ')
          ..write('success: $success, ')
          ..write('biometricResult: $biometricResult, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    eventType,
    documentId,
    entityId,
    toolName,
    success,
    biometricResult,
    metadataJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.eventType == this.eventType &&
          other.documentId == this.documentId &&
          other.entityId == this.entityId &&
          other.toolName == this.toolName &&
          other.success == this.success &&
          other.biometricResult == this.biometricResult &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String> eventType;
  final Value<String?> documentId;
  final Value<String?> entityId;
  final Value<String?> toolName;
  final Value<int> success;
  final Value<String?> biometricResult;
  final Value<String?> metadataJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.documentId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.toolName = const Value.absent(),
    this.success = const Value.absent(),
    this.biometricResult = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String eventType,
    this.documentId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.toolName = const Value.absent(),
    required int success,
    this.biometricResult = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       eventType = Value(eventType),
       success = Value(success),
       createdAt = Value(createdAt);
  static Insertable<AuditLogData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? eventType,
    Expression<String>? documentId,
    Expression<String>? entityId,
    Expression<String>? toolName,
    Expression<int>? success,
    Expression<String>? biometricResult,
    Expression<String>? metadataJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (eventType != null) 'event_type': eventType,
      if (documentId != null) 'document_id': documentId,
      if (entityId != null) 'entity_id': entityId,
      if (toolName != null) 'tool_name': toolName,
      if (success != null) 'success': success,
      if (biometricResult != null) 'biometric_result': biometricResult,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String>? eventType,
    Value<String?>? documentId,
    Value<String?>? entityId,
    Value<String?>? toolName,
    Value<int>? success,
    Value<String?>? biometricResult,
    Value<String?>? metadataJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      eventType: eventType ?? this.eventType,
      documentId: documentId ?? this.documentId,
      entityId: entityId ?? this.entityId,
      toolName: toolName ?? this.toolName,
      success: success ?? this.success,
      biometricResult: biometricResult ?? this.biometricResult,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (success.present) {
      map['success'] = Variable<int>(success.value);
    }
    if (biometricResult.present) {
      map['biometric_result'] = Variable<String>(biometricResult.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('eventType: $eventType, ')
          ..write('documentId: $documentId, ')
          ..write('entityId: $entityId, ')
          ..write('toolName: $toolName, ')
          ..write('success: $success, ')
          ..write('biometricResult: $biometricResult, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultMetaTable extends VaultMeta
    with TableInfo<$VaultMetaTable, VaultMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<Uint8List> value = GeneratedColumn<Uint8List>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  VaultMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $VaultMetaTable createAlias(String alias) {
    return $VaultMetaTable(attachedDatabase, alias);
  }
}

class VaultMetaData extends DataClass implements Insertable<VaultMetaData> {
  final String key;
  final Uint8List value;
  const VaultMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<Uint8List>(value);
    return map;
  }

  VaultMetaCompanion toCompanion(bool nullToAbsent) {
    return VaultMetaCompanion(key: Value(key), value: Value(value));
  }

  factory VaultMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Uint8List>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Uint8List>(value),
    };
  }

  VaultMetaData copyWith({String? key, Uint8List? value}) =>
      VaultMetaData(key: key ?? this.key, value: value ?? this.value);
  VaultMetaData copyWithCompanion(VaultMetaCompanion data) {
    return VaultMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, $driftBlobEquality.hash(value));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultMetaData &&
          other.key == this.key &&
          $driftBlobEquality.equals(other.value, this.value));
}

class VaultMetaCompanion extends UpdateCompanion<VaultMetaData> {
  final Value<String> key;
  final Value<Uint8List> value;
  final Value<int> rowid;
  const VaultMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultMetaCompanion.insert({
    required String key,
    required Uint8List value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<VaultMetaData> custom({
    Expression<String>? key,
    Expression<Uint8List>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultMetaCompanion copyWith({
    Value<String>? key,
    Value<Uint8List>? value,
    Value<int>? rowid,
  }) {
    return VaultMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<Uint8List>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta(
    'lastPushAt',
  );
  @override
  late final GeneratedColumn<int> lastPushAt = GeneratedColumn<int>(
    'last_push_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<int> lastPullAt = GeneratedColumn<int>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peerPublicKeysJsonMeta =
      const VerificationMeta('peerPublicKeysJson');
  @override
  late final GeneratedColumn<String> peerPublicKeysJson =
      GeneratedColumn<String>(
        'peer_public_keys_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    lastPushAt,
    lastPullAt,
    peerPublicKeysJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(
          data['last_push_at']!,
          _lastPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    if (data.containsKey('peer_public_keys_json')) {
      context.handle(
        _peerPublicKeysJsonMeta,
        peerPublicKeysJson.isAcceptableOrUnknown(
          data['peer_public_keys_json']!,
          _peerPublicKeysJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_push_at'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pull_at'],
      ),
      peerPublicKeysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_public_keys_json'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String deviceId;
  final int? lastPushAt;
  final int? lastPullAt;
  final String? peerPublicKeysJson;
  const SyncStateData({
    required this.deviceId,
    this.lastPushAt,
    this.lastPullAt,
    this.peerPublicKeysJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || lastPushAt != null) {
      map['last_push_at'] = Variable<int>(lastPushAt);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<int>(lastPullAt);
    }
    if (!nullToAbsent || peerPublicKeysJson != null) {
      map['peer_public_keys_json'] = Variable<String>(peerPublicKeysJson);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      deviceId: Value(deviceId),
      lastPushAt: lastPushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushAt),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
      peerPublicKeysJson: peerPublicKeysJson == null && nullToAbsent
          ? const Value.absent()
          : Value(peerPublicKeysJson),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastPushAt: serializer.fromJson<int?>(json['lastPushAt']),
      lastPullAt: serializer.fromJson<int?>(json['lastPullAt']),
      peerPublicKeysJson: serializer.fromJson<String?>(
        json['peerPublicKeysJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'lastPushAt': serializer.toJson<int?>(lastPushAt),
      'lastPullAt': serializer.toJson<int?>(lastPullAt),
      'peerPublicKeysJson': serializer.toJson<String?>(peerPublicKeysJson),
    };
  }

  SyncStateData copyWith({
    String? deviceId,
    Value<int?> lastPushAt = const Value.absent(),
    Value<int?> lastPullAt = const Value.absent(),
    Value<String?> peerPublicKeysJson = const Value.absent(),
  }) => SyncStateData(
    deviceId: deviceId ?? this.deviceId,
    lastPushAt: lastPushAt.present ? lastPushAt.value : this.lastPushAt,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
    peerPublicKeysJson: peerPublicKeysJson.present
        ? peerPublicKeysJson.value
        : this.peerPublicKeysJson,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastPushAt: data.lastPushAt.present
          ? data.lastPushAt.value
          : this.lastPushAt,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
      peerPublicKeysJson: data.peerPublicKeysJson.present
          ? data.peerPublicKeysJson.value
          : this.peerPublicKeysJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('deviceId: $deviceId, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('peerPublicKeysJson: $peerPublicKeysJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(deviceId, lastPushAt, lastPullAt, peerPublicKeysJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.deviceId == this.deviceId &&
          other.lastPushAt == this.lastPushAt &&
          other.lastPullAt == this.lastPullAt &&
          other.peerPublicKeysJson == this.peerPublicKeysJson);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> deviceId;
  final Value<int?> lastPushAt;
  final Value<int?> lastPullAt;
  final Value<String?> peerPublicKeysJson;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.deviceId = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.peerPublicKeysJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String deviceId,
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.peerPublicKeysJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<SyncStateData> custom({
    Expression<String>? deviceId,
    Expression<int>? lastPushAt,
    Expression<int>? lastPullAt,
    Expression<String>? peerPublicKeysJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (peerPublicKeysJson != null)
        'peer_public_keys_json': peerPublicKeysJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? deviceId,
    Value<int?>? lastPushAt,
    Value<int?>? lastPullAt,
    Value<String?>? peerPublicKeysJson,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      deviceId: deviceId ?? this.deviceId,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      peerPublicKeysJson: peerPublicKeysJson ?? this.peerPublicKeysJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<int>(lastPushAt.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<int>(lastPullAt.value);
    }
    if (peerPublicKeysJson.present) {
      map['peer_public_keys_json'] = Variable<String>(peerPublicKeysJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('peerPublicKeysJson: $peerPublicKeysJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierAtCreationMeta = const VerificationMeta(
    'tierAtCreation',
  );
  @override
  late final GeneratedColumn<String> tierAtCreation = GeneratedColumn<String>(
    'tier_at_creation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantAtCreationMeta = const VerificationMeta(
    'variantAtCreation',
  );
  @override
  late final GeneratedColumn<String> variantAtCreation =
      GeneratedColumn<String>(
        'variant_at_creation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _modelIdAtCreationMeta = const VerificationMeta(
    'modelIdAtCreation',
  );
  @override
  late final GeneratedColumn<String> modelIdAtCreation =
      GeneratedColumn<String>(
        'model_id_at_creation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<int> archived = GeneratedColumn<int>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    title,
    createdAt,
    updatedAt,
    tierAtCreation,
    variantAtCreation,
    modelIdAtCreation,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('tier_at_creation')) {
      context.handle(
        _tierAtCreationMeta,
        tierAtCreation.isAcceptableOrUnknown(
          data['tier_at_creation']!,
          _tierAtCreationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tierAtCreationMeta);
    }
    if (data.containsKey('variant_at_creation')) {
      context.handle(
        _variantAtCreationMeta,
        variantAtCreation.isAcceptableOrUnknown(
          data['variant_at_creation']!,
          _variantAtCreationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variantAtCreationMeta);
    }
    if (data.containsKey('model_id_at_creation')) {
      context.handle(
        _modelIdAtCreationMeta,
        modelIdAtCreation.isAcceptableOrUnknown(
          data['model_id_at_creation']!,
          _modelIdAtCreationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelIdAtCreationMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      tierAtCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier_at_creation'],
      )!,
      variantAtCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_at_creation'],
      )!,
      modelIdAtCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id_at_creation'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSession extends DataClass implements Insertable<ChatSession> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String? title;
  final int createdAt;
  final int updatedAt;
  final String tierAtCreation;
  final String variantAtCreation;
  final String modelIdAtCreation;
  final int archived;
  const ChatSession({
    required this.id,
    required this.workspaceId,
    this.projectId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.tierAtCreation,
    required this.variantAtCreation,
    required this.modelIdAtCreation,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['tier_at_creation'] = Variable<String>(tierAtCreation);
    map['variant_at_creation'] = Variable<String>(variantAtCreation);
    map['model_id_at_creation'] = Variable<String>(modelIdAtCreation);
    map['archived'] = Variable<int>(archived);
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tierAtCreation: Value(tierAtCreation),
      variantAtCreation: Value(variantAtCreation),
      modelIdAtCreation: Value(modelIdAtCreation),
      archived: Value(archived),
    );
  }

  factory ChatSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSession(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      title: serializer.fromJson<String?>(json['title']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      tierAtCreation: serializer.fromJson<String>(json['tierAtCreation']),
      variantAtCreation: serializer.fromJson<String>(json['variantAtCreation']),
      modelIdAtCreation: serializer.fromJson<String>(json['modelIdAtCreation']),
      archived: serializer.fromJson<int>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'title': serializer.toJson<String?>(title),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'tierAtCreation': serializer.toJson<String>(tierAtCreation),
      'variantAtCreation': serializer.toJson<String>(variantAtCreation),
      'modelIdAtCreation': serializer.toJson<String>(modelIdAtCreation),
      'archived': serializer.toJson<int>(archived),
    };
  }

  ChatSession copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    String? tierAtCreation,
    String? variantAtCreation,
    String? modelIdAtCreation,
    int? archived,
  }) => ChatSession(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    title: title.present ? title.value : this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tierAtCreation: tierAtCreation ?? this.tierAtCreation,
    variantAtCreation: variantAtCreation ?? this.variantAtCreation,
    modelIdAtCreation: modelIdAtCreation ?? this.modelIdAtCreation,
    archived: archived ?? this.archived,
  );
  ChatSession copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSession(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tierAtCreation: data.tierAtCreation.present
          ? data.tierAtCreation.value
          : this.tierAtCreation,
      variantAtCreation: data.variantAtCreation.present
          ? data.variantAtCreation.value
          : this.variantAtCreation,
      modelIdAtCreation: data.modelIdAtCreation.present
          ? data.modelIdAtCreation.value
          : this.modelIdAtCreation,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSession(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tierAtCreation: $tierAtCreation, ')
          ..write('variantAtCreation: $variantAtCreation, ')
          ..write('modelIdAtCreation: $modelIdAtCreation, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    title,
    createdAt,
    updatedAt,
    tierAtCreation,
    variantAtCreation,
    modelIdAtCreation,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSession &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tierAtCreation == this.tierAtCreation &&
          other.variantAtCreation == this.variantAtCreation &&
          other.modelIdAtCreation == this.modelIdAtCreation &&
          other.archived == this.archived);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSession> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String?> title;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> tierAtCreation;
  final Value<String> variantAtCreation;
  final Value<String> modelIdAtCreation;
  final Value<int> archived;
  final Value<int> rowid;
  const ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tierAtCreation = const Value.absent(),
    this.variantAtCreation = const Value.absent(),
    this.modelIdAtCreation = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required String tierAtCreation,
    required String variantAtCreation,
    required String modelIdAtCreation,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       tierAtCreation = Value(tierAtCreation),
       variantAtCreation = Value(variantAtCreation),
       modelIdAtCreation = Value(modelIdAtCreation);
  static Insertable<ChatSession> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? tierAtCreation,
    Expression<String>? variantAtCreation,
    Expression<String>? modelIdAtCreation,
    Expression<int>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tierAtCreation != null) 'tier_at_creation': tierAtCreation,
      if (variantAtCreation != null) 'variant_at_creation': variantAtCreation,
      if (modelIdAtCreation != null) 'model_id_at_creation': modelIdAtCreation,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String?>? title,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? tierAtCreation,
    Value<String>? variantAtCreation,
    Value<String>? modelIdAtCreation,
    Value<int>? archived,
    Value<int>? rowid,
  }) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tierAtCreation: tierAtCreation ?? this.tierAtCreation,
      variantAtCreation: variantAtCreation ?? this.variantAtCreation,
      modelIdAtCreation: modelIdAtCreation ?? this.modelIdAtCreation,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (tierAtCreation.present) {
      map['tier_at_creation'] = Variable<String>(tierAtCreation.value);
    }
    if (variantAtCreation.present) {
      map['variant_at_creation'] = Variable<String>(variantAtCreation.value);
    }
    if (modelIdAtCreation.present) {
      map['model_id_at_creation'] = Variable<String>(modelIdAtCreation.value);
    }
    if (archived.present) {
      map['archived'] = Variable<int>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tierAtCreation: $tierAtCreation, ')
          ..write('variantAtCreation: $variantAtCreation, ')
          ..write('modelIdAtCreation: $modelIdAtCreation, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_sessions (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolCallJsonMeta = const VerificationMeta(
    'toolCallJson',
  );
  @override
  late final GeneratedColumn<String> toolCallJson = GeneratedColumn<String>(
    'tool_call_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolResultJsonMeta = const VerificationMeta(
    'toolResultJson',
  );
  @override
  late final GeneratedColumn<String> toolResultJson = GeneratedColumn<String>(
    'tool_result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokensInputMeta = const VerificationMeta(
    'tokensInput',
  );
  @override
  late final GeneratedColumn<int> tokensInput = GeneratedColumn<int>(
    'tokens_input',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokensOutputMeta = const VerificationMeta(
    'tokensOutput',
  );
  @override
  late final GeneratedColumn<int> tokensOutput = GeneratedColumn<int>(
    'tokens_output',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inferenceMsMeta = const VerificationMeta(
    'inferenceMs',
  );
  @override
  late final GeneratedColumn<int> inferenceMs = GeneratedColumn<int>(
    'inference_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    role,
    content,
    toolCallJson,
    toolResultJson,
    tokensInput,
    tokensOutput,
    inferenceMs,
    modelId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('tool_call_json')) {
      context.handle(
        _toolCallJsonMeta,
        toolCallJson.isAcceptableOrUnknown(
          data['tool_call_json']!,
          _toolCallJsonMeta,
        ),
      );
    }
    if (data.containsKey('tool_result_json')) {
      context.handle(
        _toolResultJsonMeta,
        toolResultJson.isAcceptableOrUnknown(
          data['tool_result_json']!,
          _toolResultJsonMeta,
        ),
      );
    }
    if (data.containsKey('tokens_input')) {
      context.handle(
        _tokensInputMeta,
        tokensInput.isAcceptableOrUnknown(
          data['tokens_input']!,
          _tokensInputMeta,
        ),
      );
    }
    if (data.containsKey('tokens_output')) {
      context.handle(
        _tokensOutputMeta,
        tokensOutput.isAcceptableOrUnknown(
          data['tokens_output']!,
          _tokensOutputMeta,
        ),
      );
    }
    if (data.containsKey('inference_ms')) {
      context.handle(
        _inferenceMsMeta,
        inferenceMs.isAcceptableOrUnknown(
          data['inference_ms']!,
          _inferenceMsMeta,
        ),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      toolCallJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_call_json'],
      ),
      toolResultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_result_json'],
      ),
      tokensInput: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_input'],
      ),
      tokensOutput: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_output'],
      ),
      inferenceMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inference_ms'],
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String? toolCallJson;
  final String? toolResultJson;
  final int? tokensInput;
  final int? tokensOutput;
  final int? inferenceMs;
  final String modelId;
  final int createdAt;
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.toolCallJson,
    this.toolResultJson,
    this.tokensInput,
    this.tokensOutput,
    this.inferenceMs,
    required this.modelId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || toolCallJson != null) {
      map['tool_call_json'] = Variable<String>(toolCallJson);
    }
    if (!nullToAbsent || toolResultJson != null) {
      map['tool_result_json'] = Variable<String>(toolResultJson);
    }
    if (!nullToAbsent || tokensInput != null) {
      map['tokens_input'] = Variable<int>(tokensInput);
    }
    if (!nullToAbsent || tokensOutput != null) {
      map['tokens_output'] = Variable<int>(tokensOutput);
    }
    if (!nullToAbsent || inferenceMs != null) {
      map['inference_ms'] = Variable<int>(inferenceMs);
    }
    map['model_id'] = Variable<String>(modelId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      toolCallJson: toolCallJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCallJson),
      toolResultJson: toolResultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toolResultJson),
      tokensInput: tokensInput == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensInput),
      tokensOutput: tokensOutput == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensOutput),
      inferenceMs: inferenceMs == null && nullToAbsent
          ? const Value.absent()
          : Value(inferenceMs),
      modelId: Value(modelId),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      toolCallJson: serializer.fromJson<String?>(json['toolCallJson']),
      toolResultJson: serializer.fromJson<String?>(json['toolResultJson']),
      tokensInput: serializer.fromJson<int?>(json['tokensInput']),
      tokensOutput: serializer.fromJson<int?>(json['tokensOutput']),
      inferenceMs: serializer.fromJson<int?>(json['inferenceMs']),
      modelId: serializer.fromJson<String>(json['modelId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'toolCallJson': serializer.toJson<String?>(toolCallJson),
      'toolResultJson': serializer.toJson<String?>(toolResultJson),
      'tokensInput': serializer.toJson<int?>(tokensInput),
      'tokensOutput': serializer.toJson<int?>(tokensOutput),
      'inferenceMs': serializer.toJson<int?>(inferenceMs),
      'modelId': serializer.toJson<String>(modelId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    Value<String?> toolCallJson = const Value.absent(),
    Value<String?> toolResultJson = const Value.absent(),
    Value<int?> tokensInput = const Value.absent(),
    Value<int?> tokensOutput = const Value.absent(),
    Value<int?> inferenceMs = const Value.absent(),
    String? modelId,
    int? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    role: role ?? this.role,
    content: content ?? this.content,
    toolCallJson: toolCallJson.present ? toolCallJson.value : this.toolCallJson,
    toolResultJson: toolResultJson.present
        ? toolResultJson.value
        : this.toolResultJson,
    tokensInput: tokensInput.present ? tokensInput.value : this.tokensInput,
    tokensOutput: tokensOutput.present ? tokensOutput.value : this.tokensOutput,
    inferenceMs: inferenceMs.present ? inferenceMs.value : this.inferenceMs,
    modelId: modelId ?? this.modelId,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      toolCallJson: data.toolCallJson.present
          ? data.toolCallJson.value
          : this.toolCallJson,
      toolResultJson: data.toolResultJson.present
          ? data.toolResultJson.value
          : this.toolResultJson,
      tokensInput: data.tokensInput.present
          ? data.tokensInput.value
          : this.tokensInput,
      tokensOutput: data.tokensOutput.present
          ? data.tokensOutput.value
          : this.tokensOutput,
      inferenceMs: data.inferenceMs.present
          ? data.inferenceMs.value
          : this.inferenceMs,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCallJson: $toolCallJson, ')
          ..write('toolResultJson: $toolResultJson, ')
          ..write('tokensInput: $tokensInput, ')
          ..write('tokensOutput: $tokensOutput, ')
          ..write('inferenceMs: $inferenceMs, ')
          ..write('modelId: $modelId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    role,
    content,
    toolCallJson,
    toolResultJson,
    tokensInput,
    tokensOutput,
    inferenceMs,
    modelId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.toolCallJson == this.toolCallJson &&
          other.toolResultJson == this.toolResultJson &&
          other.tokensInput == this.tokensInput &&
          other.tokensOutput == this.tokensOutput &&
          other.inferenceMs == this.inferenceMs &&
          other.modelId == this.modelId &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> toolCallJson;
  final Value<String?> toolResultJson;
  final Value<int?> tokensInput;
  final Value<int?> tokensOutput;
  final Value<int?> inferenceMs;
  final Value<String> modelId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.toolCallJson = const Value.absent(),
    this.toolResultJson = const Value.absent(),
    this.tokensInput = const Value.absent(),
    this.tokensOutput = const Value.absent(),
    this.inferenceMs = const Value.absent(),
    this.modelId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String sessionId,
    required String role,
    required String content,
    this.toolCallJson = const Value.absent(),
    this.toolResultJson = const Value.absent(),
    this.tokensInput = const Value.absent(),
    this.tokensOutput = const Value.absent(),
    this.inferenceMs = const Value.absent(),
    required String modelId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       role = Value(role),
       content = Value(content),
       modelId = Value(modelId),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? toolCallJson,
    Expression<String>? toolResultJson,
    Expression<int>? tokensInput,
    Expression<int>? tokensOutput,
    Expression<int>? inferenceMs,
    Expression<String>? modelId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (toolCallJson != null) 'tool_call_json': toolCallJson,
      if (toolResultJson != null) 'tool_result_json': toolResultJson,
      if (tokensInput != null) 'tokens_input': tokensInput,
      if (tokensOutput != null) 'tokens_output': tokensOutput,
      if (inferenceMs != null) 'inference_ms': inferenceMs,
      if (modelId != null) 'model_id': modelId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? toolCallJson,
    Value<String?>? toolResultJson,
    Value<int?>? tokensInput,
    Value<int?>? tokensOutput,
    Value<int?>? inferenceMs,
    Value<String>? modelId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      toolCallJson: toolCallJson ?? this.toolCallJson,
      toolResultJson: toolResultJson ?? this.toolResultJson,
      tokensInput: tokensInput ?? this.tokensInput,
      tokensOutput: tokensOutput ?? this.tokensOutput,
      inferenceMs: inferenceMs ?? this.inferenceMs,
      modelId: modelId ?? this.modelId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (toolCallJson.present) {
      map['tool_call_json'] = Variable<String>(toolCallJson.value);
    }
    if (toolResultJson.present) {
      map['tool_result_json'] = Variable<String>(toolResultJson.value);
    }
    if (tokensInput.present) {
      map['tokens_input'] = Variable<int>(tokensInput.value);
    }
    if (tokensOutput.present) {
      map['tokens_output'] = Variable<int>(tokensOutput.value);
    }
    if (inferenceMs.present) {
      map['inference_ms'] = Variable<int>(inferenceMs.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCallJson: $toolCallJson, ')
          ..write('toolResultJson: $toolResultJson, ')
          ..write('tokensInput: $tokensInput, ')
          ..write('tokensOutput: $tokensOutput, ')
          ..write('inferenceMs: $inferenceMs, ')
          ..write('modelId: $modelId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinkCoreMemoryTable extends MinkCoreMemory
    with TableInfo<$MinkCoreMemoryTable, MinkCoreMemoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinkCoreMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    key,
    valueJson,
    provenance,
    confidence,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mink_core_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinkCoreMemoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    } else if (isInserting) {
      context.missing(_provenanceMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {workspaceId, projectId, key},
  ];
  @override
  MinkCoreMemoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinkCoreMemoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MinkCoreMemoryTable createAlias(String alias) {
    return $MinkCoreMemoryTable(attachedDatabase, alias);
  }
}

class MinkCoreMemoryData extends DataClass
    implements Insertable<MinkCoreMemoryData> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String key;
  final String valueJson;
  final String provenance;
  final double? confidence;
  final int createdAt;
  final int updatedAt;
  const MinkCoreMemoryData({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.key,
    required this.valueJson,
    required this.provenance,
    this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['provenance'] = Variable<String>(provenance);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MinkCoreMemoryCompanion toCompanion(bool nullToAbsent) {
    return MinkCoreMemoryCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      key: Value(key),
      valueJson: Value(valueJson),
      provenance: Value(provenance),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MinkCoreMemoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinkCoreMemoryData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      provenance: serializer.fromJson<String>(json['provenance']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'provenance': serializer.toJson<String>(provenance),
      'confidence': serializer.toJson<double?>(confidence),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MinkCoreMemoryData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    String? key,
    String? valueJson,
    String? provenance,
    Value<double?> confidence = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => MinkCoreMemoryData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    provenance: provenance ?? this.provenance,
    confidence: confidence.present ? confidence.value : this.confidence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MinkCoreMemoryData copyWithCompanion(MinkCoreMemoryCompanion data) {
    return MinkCoreMemoryData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinkCoreMemoryData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('provenance: $provenance, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    key,
    valueJson,
    provenance,
    confidence,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinkCoreMemoryData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.provenance == this.provenance &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MinkCoreMemoryCompanion extends UpdateCompanion<MinkCoreMemoryData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String> key;
  final Value<String> valueJson;
  final Value<String> provenance;
  final Value<double?> confidence;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MinkCoreMemoryCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.provenance = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinkCoreMemoryCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String key,
    required String valueJson,
    required String provenance,
    this.confidence = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       key = Value(key),
       valueJson = Value(valueJson),
       provenance = Value(provenance),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MinkCoreMemoryData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<String>? provenance,
    Expression<double>? confidence,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (provenance != null) 'provenance': provenance,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinkCoreMemoryCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String>? key,
    Value<String>? valueJson,
    Value<String>? provenance,
    Value<double?>? confidence,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MinkCoreMemoryCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      provenance: provenance ?? this.provenance,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinkCoreMemoryCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('provenance: $provenance, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinkEpisodicMemoryTable extends MinkEpisodicMemory
    with TableInfo<$MinkEpisodicMemoryTable, MinkEpisodicMemoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinkEpisodicMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeTypeMeta = const VerificationMeta(
    'episodeType',
  );
  @override
  late final GeneratedColumn<String> episodeType = GeneratedColumn<String>(
    'episode_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenRefsJsonMeta = const VerificationMeta(
    'tokenRefsJson',
  );
  @override
  late final GeneratedColumn<String> tokenRefsJson = GeneratedColumn<String>(
    'token_refs_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    occurredAt,
    summary,
    detailsJson,
    episodeType,
    tokenRefsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mink_episodic_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinkEpisodicMemoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('episode_type')) {
      context.handle(
        _episodeTypeMeta,
        episodeType.isAcceptableOrUnknown(
          data['episode_type']!,
          _episodeTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeTypeMeta);
    }
    if (data.containsKey('token_refs_json')) {
      context.handle(
        _tokenRefsJsonMeta,
        tokenRefsJson.isAcceptableOrUnknown(
          data['token_refs_json']!,
          _tokenRefsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinkEpisodicMemoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinkEpisodicMemoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      ),
      episodeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_type'],
      )!,
      tokenRefsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_refs_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MinkEpisodicMemoryTable createAlias(String alias) {
    return $MinkEpisodicMemoryTable(attachedDatabase, alias);
  }
}

class MinkEpisodicMemoryData extends DataClass
    implements Insertable<MinkEpisodicMemoryData> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final int occurredAt;
  final String summary;
  final String? detailsJson;
  final String episodeType;
  final String? tokenRefsJson;
  final int createdAt;
  const MinkEpisodicMemoryData({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.occurredAt,
    required this.summary,
    this.detailsJson,
    required this.episodeType,
    this.tokenRefsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['occurred_at'] = Variable<int>(occurredAt);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    map['episode_type'] = Variable<String>(episodeType);
    if (!nullToAbsent || tokenRefsJson != null) {
      map['token_refs_json'] = Variable<String>(tokenRefsJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MinkEpisodicMemoryCompanion toCompanion(bool nullToAbsent) {
    return MinkEpisodicMemoryCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      occurredAt: Value(occurredAt),
      summary: Value(summary),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
      episodeType: Value(episodeType),
      tokenRefsJson: tokenRefsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenRefsJson),
      createdAt: Value(createdAt),
    );
  }

  factory MinkEpisodicMemoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinkEpisodicMemoryData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      summary: serializer.fromJson<String>(json['summary']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
      episodeType: serializer.fromJson<String>(json['episodeType']),
      tokenRefsJson: serializer.fromJson<String?>(json['tokenRefsJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'summary': serializer.toJson<String>(summary),
      'detailsJson': serializer.toJson<String?>(detailsJson),
      'episodeType': serializer.toJson<String>(episodeType),
      'tokenRefsJson': serializer.toJson<String?>(tokenRefsJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MinkEpisodicMemoryData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    int? occurredAt,
    String? summary,
    Value<String?> detailsJson = const Value.absent(),
    String? episodeType,
    Value<String?> tokenRefsJson = const Value.absent(),
    int? createdAt,
  }) => MinkEpisodicMemoryData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    occurredAt: occurredAt ?? this.occurredAt,
    summary: summary ?? this.summary,
    detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
    episodeType: episodeType ?? this.episodeType,
    tokenRefsJson: tokenRefsJson.present
        ? tokenRefsJson.value
        : this.tokenRefsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  MinkEpisodicMemoryData copyWithCompanion(MinkEpisodicMemoryCompanion data) {
    return MinkEpisodicMemoryData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      summary: data.summary.present ? data.summary.value : this.summary,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      episodeType: data.episodeType.present
          ? data.episodeType.value
          : this.episodeType,
      tokenRefsJson: data.tokenRefsJson.present
          ? data.tokenRefsJson.value
          : this.tokenRefsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinkEpisodicMemoryData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('summary: $summary, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('episodeType: $episodeType, ')
          ..write('tokenRefsJson: $tokenRefsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    occurredAt,
    summary,
    detailsJson,
    episodeType,
    tokenRefsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinkEpisodicMemoryData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.occurredAt == this.occurredAt &&
          other.summary == this.summary &&
          other.detailsJson == this.detailsJson &&
          other.episodeType == this.episodeType &&
          other.tokenRefsJson == this.tokenRefsJson &&
          other.createdAt == this.createdAt);
}

class MinkEpisodicMemoryCompanion
    extends UpdateCompanion<MinkEpisodicMemoryData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<int> occurredAt;
  final Value<String> summary;
  final Value<String?> detailsJson;
  final Value<String> episodeType;
  final Value<String?> tokenRefsJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const MinkEpisodicMemoryCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.episodeType = const Value.absent(),
    this.tokenRefsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinkEpisodicMemoryCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required int occurredAt,
    required String summary,
    this.detailsJson = const Value.absent(),
    required String episodeType,
    this.tokenRefsJson = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       occurredAt = Value(occurredAt),
       summary = Value(summary),
       episodeType = Value(episodeType),
       createdAt = Value(createdAt);
  static Insertable<MinkEpisodicMemoryData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<int>? occurredAt,
    Expression<String>? summary,
    Expression<String>? detailsJson,
    Expression<String>? episodeType,
    Expression<String>? tokenRefsJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (summary != null) 'summary': summary,
      if (detailsJson != null) 'details_json': detailsJson,
      if (episodeType != null) 'episode_type': episodeType,
      if (tokenRefsJson != null) 'token_refs_json': tokenRefsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinkEpisodicMemoryCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<int>? occurredAt,
    Value<String>? summary,
    Value<String?>? detailsJson,
    Value<String>? episodeType,
    Value<String?>? tokenRefsJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return MinkEpisodicMemoryCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      occurredAt: occurredAt ?? this.occurredAt,
      summary: summary ?? this.summary,
      detailsJson: detailsJson ?? this.detailsJson,
      episodeType: episodeType ?? this.episodeType,
      tokenRefsJson: tokenRefsJson ?? this.tokenRefsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (episodeType.present) {
      map['episode_type'] = Variable<String>(episodeType.value);
    }
    if (tokenRefsJson.present) {
      map['token_refs_json'] = Variable<String>(tokenRefsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinkEpisodicMemoryCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('summary: $summary, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('episodeType: $episodeType, ')
          ..write('tokenRefsJson: $tokenRefsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinkSemanticMemoryTable extends MinkSemanticMemory
    with TableInfo<$MinkSemanticMemoryTable, MinkSemanticMemoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinkSemanticMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalFingerprintMeta =
      const VerificationMeta('canonicalFingerprint');
  @override
  late final GeneratedColumn<Uint8List> canonicalFingerprint =
      GeneratedColumn<Uint8List>(
        'canonical_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _descriptorMeta = const VerificationMeta(
    'descriptor',
  );
  @override
  late final GeneratedColumn<String> descriptor = GeneratedColumn<String>(
    'descriptor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mink_semantic_memory (id)',
    ),
  );
  static const VerificationMeta _occurrenceCountMeta = const VerificationMeta(
    'occurrenceCount',
  );
  @override
  late final GeneratedColumn<int> occurrenceCount = GeneratedColumn<int>(
    'occurrence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<int> firstSeenAt = GeneratedColumn<int>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embeddingIdMeta = const VerificationMeta(
    'embeddingId',
  );
  @override
  late final GeneratedColumn<String> embeddingId = GeneratedColumn<String>(
    'embedding_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    entityType,
    canonicalFingerprint,
    descriptor,
    parentId,
    occurrenceCount,
    firstSeenAt,
    lastSeenAt,
    embeddingId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mink_semantic_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinkSemanticMemoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('canonical_fingerprint')) {
      context.handle(
        _canonicalFingerprintMeta,
        canonicalFingerprint.isAcceptableOrUnknown(
          data['canonical_fingerprint']!,
          _canonicalFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('descriptor')) {
      context.handle(
        _descriptorMeta,
        descriptor.isAcceptableOrUnknown(data['descriptor']!, _descriptorMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('occurrence_count')) {
      context.handle(
        _occurrenceCountMeta,
        occurrenceCount.isAcceptableOrUnknown(
          data['occurrence_count']!,
          _occurrenceCountMeta,
        ),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('embedding_id')) {
      context.handle(
        _embeddingIdMeta,
        embeddingId.isAcceptableOrUnknown(
          data['embedding_id']!,
          _embeddingIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinkSemanticMemoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinkSemanticMemoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      canonicalFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}canonical_fingerprint'],
      ),
      descriptor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descriptor'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      occurrenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence_count'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      )!,
      embeddingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MinkSemanticMemoryTable createAlias(String alias) {
    return $MinkSemanticMemoryTable(attachedDatabase, alias);
  }
}

class MinkSemanticMemoryData extends DataClass
    implements Insertable<MinkSemanticMemoryData> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String entityType;
  final Uint8List? canonicalFingerprint;
  final String? descriptor;
  final String? parentId;
  final int occurrenceCount;
  final int firstSeenAt;
  final int lastSeenAt;
  final String? embeddingId;
  final int createdAt;
  final int updatedAt;
  const MinkSemanticMemoryData({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.entityType,
    this.canonicalFingerprint,
    this.descriptor,
    this.parentId,
    required this.occurrenceCount,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.embeddingId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || canonicalFingerprint != null) {
      map['canonical_fingerprint'] = Variable<Uint8List>(canonicalFingerprint);
    }
    if (!nullToAbsent || descriptor != null) {
      map['descriptor'] = Variable<String>(descriptor);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['occurrence_count'] = Variable<int>(occurrenceCount);
    map['first_seen_at'] = Variable<int>(firstSeenAt);
    map['last_seen_at'] = Variable<int>(lastSeenAt);
    if (!nullToAbsent || embeddingId != null) {
      map['embedding_id'] = Variable<String>(embeddingId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MinkSemanticMemoryCompanion toCompanion(bool nullToAbsent) {
    return MinkSemanticMemoryCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      entityType: Value(entityType),
      canonicalFingerprint: canonicalFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalFingerprint),
      descriptor: descriptor == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptor),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      occurrenceCount: Value(occurrenceCount),
      firstSeenAt: Value(firstSeenAt),
      lastSeenAt: Value(lastSeenAt),
      embeddingId: embeddingId == null && nullToAbsent
          ? const Value.absent()
          : Value(embeddingId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MinkSemanticMemoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinkSemanticMemoryData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      canonicalFingerprint: serializer.fromJson<Uint8List?>(
        json['canonicalFingerprint'],
      ),
      descriptor: serializer.fromJson<String?>(json['descriptor']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      occurrenceCount: serializer.fromJson<int>(json['occurrenceCount']),
      firstSeenAt: serializer.fromJson<int>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<int>(json['lastSeenAt']),
      embeddingId: serializer.fromJson<String?>(json['embeddingId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'entityType': serializer.toJson<String>(entityType),
      'canonicalFingerprint': serializer.toJson<Uint8List?>(
        canonicalFingerprint,
      ),
      'descriptor': serializer.toJson<String?>(descriptor),
      'parentId': serializer.toJson<String?>(parentId),
      'occurrenceCount': serializer.toJson<int>(occurrenceCount),
      'firstSeenAt': serializer.toJson<int>(firstSeenAt),
      'lastSeenAt': serializer.toJson<int>(lastSeenAt),
      'embeddingId': serializer.toJson<String?>(embeddingId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MinkSemanticMemoryData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    String? entityType,
    Value<Uint8List?> canonicalFingerprint = const Value.absent(),
    Value<String?> descriptor = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    int? occurrenceCount,
    int? firstSeenAt,
    int? lastSeenAt,
    Value<String?> embeddingId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => MinkSemanticMemoryData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    entityType: entityType ?? this.entityType,
    canonicalFingerprint: canonicalFingerprint.present
        ? canonicalFingerprint.value
        : this.canonicalFingerprint,
    descriptor: descriptor.present ? descriptor.value : this.descriptor,
    parentId: parentId.present ? parentId.value : this.parentId,
    occurrenceCount: occurrenceCount ?? this.occurrenceCount,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    embeddingId: embeddingId.present ? embeddingId.value : this.embeddingId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MinkSemanticMemoryData copyWithCompanion(MinkSemanticMemoryCompanion data) {
    return MinkSemanticMemoryData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      canonicalFingerprint: data.canonicalFingerprint.present
          ? data.canonicalFingerprint.value
          : this.canonicalFingerprint,
      descriptor: data.descriptor.present
          ? data.descriptor.value
          : this.descriptor,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      occurrenceCount: data.occurrenceCount.present
          ? data.occurrenceCount.value
          : this.occurrenceCount,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      embeddingId: data.embeddingId.present
          ? data.embeddingId.value
          : this.embeddingId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinkSemanticMemoryData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('entityType: $entityType, ')
          ..write('canonicalFingerprint: $canonicalFingerprint, ')
          ..write('descriptor: $descriptor, ')
          ..write('parentId: $parentId, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('embeddingId: $embeddingId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    entityType,
    $driftBlobEquality.hash(canonicalFingerprint),
    descriptor,
    parentId,
    occurrenceCount,
    firstSeenAt,
    lastSeenAt,
    embeddingId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinkSemanticMemoryData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.entityType == this.entityType &&
          $driftBlobEquality.equals(
            other.canonicalFingerprint,
            this.canonicalFingerprint,
          ) &&
          other.descriptor == this.descriptor &&
          other.parentId == this.parentId &&
          other.occurrenceCount == this.occurrenceCount &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.embeddingId == this.embeddingId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MinkSemanticMemoryCompanion
    extends UpdateCompanion<MinkSemanticMemoryData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String> entityType;
  final Value<Uint8List?> canonicalFingerprint;
  final Value<String?> descriptor;
  final Value<String?> parentId;
  final Value<int> occurrenceCount;
  final Value<int> firstSeenAt;
  final Value<int> lastSeenAt;
  final Value<String?> embeddingId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MinkSemanticMemoryCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.canonicalFingerprint = const Value.absent(),
    this.descriptor = const Value.absent(),
    this.parentId = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.embeddingId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinkSemanticMemoryCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String entityType,
    this.canonicalFingerprint = const Value.absent(),
    this.descriptor = const Value.absent(),
    this.parentId = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    required int firstSeenAt,
    required int lastSeenAt,
    this.embeddingId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       entityType = Value(entityType),
       firstSeenAt = Value(firstSeenAt),
       lastSeenAt = Value(lastSeenAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MinkSemanticMemoryData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? entityType,
    Expression<Uint8List>? canonicalFingerprint,
    Expression<String>? descriptor,
    Expression<String>? parentId,
    Expression<int>? occurrenceCount,
    Expression<int>? firstSeenAt,
    Expression<int>? lastSeenAt,
    Expression<String>? embeddingId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (entityType != null) 'entity_type': entityType,
      if (canonicalFingerprint != null)
        'canonical_fingerprint': canonicalFingerprint,
      if (descriptor != null) 'descriptor': descriptor,
      if (parentId != null) 'parent_id': parentId,
      if (occurrenceCount != null) 'occurrence_count': occurrenceCount,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (embeddingId != null) 'embedding_id': embeddingId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinkSemanticMemoryCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String>? entityType,
    Value<Uint8List?>? canonicalFingerprint,
    Value<String?>? descriptor,
    Value<String?>? parentId,
    Value<int>? occurrenceCount,
    Value<int>? firstSeenAt,
    Value<int>? lastSeenAt,
    Value<String?>? embeddingId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MinkSemanticMemoryCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      entityType: entityType ?? this.entityType,
      canonicalFingerprint: canonicalFingerprint ?? this.canonicalFingerprint,
      descriptor: descriptor ?? this.descriptor,
      parentId: parentId ?? this.parentId,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      embeddingId: embeddingId ?? this.embeddingId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (canonicalFingerprint.present) {
      map['canonical_fingerprint'] = Variable<Uint8List>(
        canonicalFingerprint.value,
      );
    }
    if (descriptor.present) {
      map['descriptor'] = Variable<String>(descriptor.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (occurrenceCount.present) {
      map['occurrence_count'] = Variable<int>(occurrenceCount.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<int>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (embeddingId.present) {
      map['embedding_id'] = Variable<String>(embeddingId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinkSemanticMemoryCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('entityType: $entityType, ')
          ..write('canonicalFingerprint: $canonicalFingerprint, ')
          ..write('descriptor: $descriptor, ')
          ..write('parentId: $parentId, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('embeddingId: $embeddingId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinkSemanticRelationshipsTable extends MinkSemanticRelationships
    with TableInfo<$MinkSemanticRelationshipsTable, MinkSemanticRelationship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinkSemanticRelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _fromEntityIdMeta = const VerificationMeta(
    'fromEntityId',
  );
  @override
  late final GeneratedColumn<String> fromEntityId = GeneratedColumn<String>(
    'from_entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mink_semantic_memory (id)',
    ),
  );
  static const VerificationMeta _toEntityIdMeta = const VerificationMeta(
    'toEntityId',
  );
  @override
  late final GeneratedColumn<String> toEntityId = GeneratedColumn<String>(
    'to_entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mink_semantic_memory (id)',
    ),
  );
  static const VerificationMeta _predicateMeta = const VerificationMeta(
    'predicate',
  );
  @override
  late final GeneratedColumn<String> predicate = GeneratedColumn<String>(
    'predicate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    fromEntityId,
    toEntityId,
    predicate,
    confidence,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mink_semantic_relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinkSemanticRelationship> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('from_entity_id')) {
      context.handle(
        _fromEntityIdMeta,
        fromEntityId.isAcceptableOrUnknown(
          data['from_entity_id']!,
          _fromEntityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromEntityIdMeta);
    }
    if (data.containsKey('to_entity_id')) {
      context.handle(
        _toEntityIdMeta,
        toEntityId.isAcceptableOrUnknown(
          data['to_entity_id']!,
          _toEntityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toEntityIdMeta);
    }
    if (data.containsKey('predicate')) {
      context.handle(
        _predicateMeta,
        predicate.isAcceptableOrUnknown(data['predicate']!, _predicateMeta),
      );
    } else if (isInserting) {
      context.missing(_predicateMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinkSemanticRelationship map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinkSemanticRelationship(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      fromEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_entity_id'],
      )!,
      toEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_entity_id'],
      )!,
      predicate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}predicate'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MinkSemanticRelationshipsTable createAlias(String alias) {
    return $MinkSemanticRelationshipsTable(attachedDatabase, alias);
  }
}

class MinkSemanticRelationship extends DataClass
    implements Insertable<MinkSemanticRelationship> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String fromEntityId;
  final String toEntityId;
  final String predicate;
  final double confidence;
  final int createdAt;
  const MinkSemanticRelationship({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.fromEntityId,
    required this.toEntityId,
    required this.predicate,
    required this.confidence,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['from_entity_id'] = Variable<String>(fromEntityId);
    map['to_entity_id'] = Variable<String>(toEntityId);
    map['predicate'] = Variable<String>(predicate);
    map['confidence'] = Variable<double>(confidence);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MinkSemanticRelationshipsCompanion toCompanion(bool nullToAbsent) {
    return MinkSemanticRelationshipsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      fromEntityId: Value(fromEntityId),
      toEntityId: Value(toEntityId),
      predicate: Value(predicate),
      confidence: Value(confidence),
      createdAt: Value(createdAt),
    );
  }

  factory MinkSemanticRelationship.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinkSemanticRelationship(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      fromEntityId: serializer.fromJson<String>(json['fromEntityId']),
      toEntityId: serializer.fromJson<String>(json['toEntityId']),
      predicate: serializer.fromJson<String>(json['predicate']),
      confidence: serializer.fromJson<double>(json['confidence']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'fromEntityId': serializer.toJson<String>(fromEntityId),
      'toEntityId': serializer.toJson<String>(toEntityId),
      'predicate': serializer.toJson<String>(predicate),
      'confidence': serializer.toJson<double>(confidence),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MinkSemanticRelationship copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    String? fromEntityId,
    String? toEntityId,
    String? predicate,
    double? confidence,
    int? createdAt,
  }) => MinkSemanticRelationship(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    fromEntityId: fromEntityId ?? this.fromEntityId,
    toEntityId: toEntityId ?? this.toEntityId,
    predicate: predicate ?? this.predicate,
    confidence: confidence ?? this.confidence,
    createdAt: createdAt ?? this.createdAt,
  );
  MinkSemanticRelationship copyWithCompanion(
    MinkSemanticRelationshipsCompanion data,
  ) {
    return MinkSemanticRelationship(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      fromEntityId: data.fromEntityId.present
          ? data.fromEntityId.value
          : this.fromEntityId,
      toEntityId: data.toEntityId.present
          ? data.toEntityId.value
          : this.toEntityId,
      predicate: data.predicate.present ? data.predicate.value : this.predicate,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinkSemanticRelationship(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('fromEntityId: $fromEntityId, ')
          ..write('toEntityId: $toEntityId, ')
          ..write('predicate: $predicate, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    fromEntityId,
    toEntityId,
    predicate,
    confidence,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinkSemanticRelationship &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.fromEntityId == this.fromEntityId &&
          other.toEntityId == this.toEntityId &&
          other.predicate == this.predicate &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt);
}

class MinkSemanticRelationshipsCompanion
    extends UpdateCompanion<MinkSemanticRelationship> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String> fromEntityId;
  final Value<String> toEntityId;
  final Value<String> predicate;
  final Value<double> confidence;
  final Value<int> createdAt;
  final Value<int> rowid;
  const MinkSemanticRelationshipsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.fromEntityId = const Value.absent(),
    this.toEntityId = const Value.absent(),
    this.predicate = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinkSemanticRelationshipsCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String fromEntityId,
    required String toEntityId,
    required String predicate,
    required double confidence,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       fromEntityId = Value(fromEntityId),
       toEntityId = Value(toEntityId),
       predicate = Value(predicate),
       confidence = Value(confidence),
       createdAt = Value(createdAt);
  static Insertable<MinkSemanticRelationship> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? fromEntityId,
    Expression<String>? toEntityId,
    Expression<String>? predicate,
    Expression<double>? confidence,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (fromEntityId != null) 'from_entity_id': fromEntityId,
      if (toEntityId != null) 'to_entity_id': toEntityId,
      if (predicate != null) 'predicate': predicate,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinkSemanticRelationshipsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String>? fromEntityId,
    Value<String>? toEntityId,
    Value<String>? predicate,
    Value<double>? confidence,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return MinkSemanticRelationshipsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      fromEntityId: fromEntityId ?? this.fromEntityId,
      toEntityId: toEntityId ?? this.toEntityId,
      predicate: predicate ?? this.predicate,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (fromEntityId.present) {
      map['from_entity_id'] = Variable<String>(fromEntityId.value);
    }
    if (toEntityId.present) {
      map['to_entity_id'] = Variable<String>(toEntityId.value);
    }
    if (predicate.present) {
      map['predicate'] = Variable<String>(predicate.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinkSemanticRelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('fromEntityId: $fromEntityId, ')
          ..write('toEntityId: $toEntityId, ')
          ..write('predicate: $predicate, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinkProceduralMemoryTable extends MinkProceduralMemory
    with TableInfo<$MinkProceduralMemoryTable, MinkProceduralMemoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinkProceduralMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id)',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _triggerPatternJsonMeta =
      const VerificationMeta('triggerPatternJson');
  @override
  late final GeneratedColumn<String> triggerPatternJson =
      GeneratedColumn<String>(
        'trigger_pattern_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actionPatternJsonMeta = const VerificationMeta(
    'actionPatternJson',
  );
  @override
  late final GeneratedColumn<String> actionPatternJson =
      GeneratedColumn<String>(
        'action_pattern_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _observedCountMeta = const VerificationMeta(
    'observedCount',
  );
  @override
  late final GeneratedColumn<int> observedCount = GeneratedColumn<int>(
    'observed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastObservedAtMeta = const VerificationMeta(
    'lastObservedAt',
  );
  @override
  late final GeneratedColumn<int> lastObservedAt = GeneratedColumn<int>(
    'last_observed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userConfirmedMeta = const VerificationMeta(
    'userConfirmed',
  );
  @override
  late final GeneratedColumn<int> userConfirmed = GeneratedColumn<int>(
    'user_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    triggerPatternJson,
    actionPatternJson,
    observedCount,
    confidence,
    lastObservedAt,
    userConfirmed,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mink_procedural_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<MinkProceduralMemoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('trigger_pattern_json')) {
      context.handle(
        _triggerPatternJsonMeta,
        triggerPatternJson.isAcceptableOrUnknown(
          data['trigger_pattern_json']!,
          _triggerPatternJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerPatternJsonMeta);
    }
    if (data.containsKey('action_pattern_json')) {
      context.handle(
        _actionPatternJsonMeta,
        actionPatternJson.isAcceptableOrUnknown(
          data['action_pattern_json']!,
          _actionPatternJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actionPatternJsonMeta);
    }
    if (data.containsKey('observed_count')) {
      context.handle(
        _observedCountMeta,
        observedCount.isAcceptableOrUnknown(
          data['observed_count']!,
          _observedCountMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('last_observed_at')) {
      context.handle(
        _lastObservedAtMeta,
        lastObservedAt.isAcceptableOrUnknown(
          data['last_observed_at']!,
          _lastObservedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastObservedAtMeta);
    }
    if (data.containsKey('user_confirmed')) {
      context.handle(
        _userConfirmedMeta,
        userConfirmed.isAcceptableOrUnknown(
          data['user_confirmed']!,
          _userConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MinkProceduralMemoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinkProceduralMemoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      triggerPatternJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_pattern_json'],
      )!,
      actionPatternJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_pattern_json'],
      )!,
      observedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}observed_count'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      lastObservedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_observed_at'],
      )!,
      userConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_confirmed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MinkProceduralMemoryTable createAlias(String alias) {
    return $MinkProceduralMemoryTable(attachedDatabase, alias);
  }
}

class MinkProceduralMemoryData extends DataClass
    implements Insertable<MinkProceduralMemoryData> {
  final String id;
  final String workspaceId;
  final String? projectId;
  final String triggerPatternJson;
  final String actionPatternJson;
  final int observedCount;
  final double confidence;
  final int lastObservedAt;
  final int userConfirmed;
  final int createdAt;
  final int updatedAt;
  const MinkProceduralMemoryData({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.triggerPatternJson,
    required this.actionPatternJson,
    required this.observedCount,
    required this.confidence,
    required this.lastObservedAt,
    required this.userConfirmed,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['trigger_pattern_json'] = Variable<String>(triggerPatternJson);
    map['action_pattern_json'] = Variable<String>(actionPatternJson);
    map['observed_count'] = Variable<int>(observedCount);
    map['confidence'] = Variable<double>(confidence);
    map['last_observed_at'] = Variable<int>(lastObservedAt);
    map['user_confirmed'] = Variable<int>(userConfirmed);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MinkProceduralMemoryCompanion toCompanion(bool nullToAbsent) {
    return MinkProceduralMemoryCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      triggerPatternJson: Value(triggerPatternJson),
      actionPatternJson: Value(actionPatternJson),
      observedCount: Value(observedCount),
      confidence: Value(confidence),
      lastObservedAt: Value(lastObservedAt),
      userConfirmed: Value(userConfirmed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MinkProceduralMemoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinkProceduralMemoryData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      triggerPatternJson: serializer.fromJson<String>(
        json['triggerPatternJson'],
      ),
      actionPatternJson: serializer.fromJson<String>(json['actionPatternJson']),
      observedCount: serializer.fromJson<int>(json['observedCount']),
      confidence: serializer.fromJson<double>(json['confidence']),
      lastObservedAt: serializer.fromJson<int>(json['lastObservedAt']),
      userConfirmed: serializer.fromJson<int>(json['userConfirmed']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'triggerPatternJson': serializer.toJson<String>(triggerPatternJson),
      'actionPatternJson': serializer.toJson<String>(actionPatternJson),
      'observedCount': serializer.toJson<int>(observedCount),
      'confidence': serializer.toJson<double>(confidence),
      'lastObservedAt': serializer.toJson<int>(lastObservedAt),
      'userConfirmed': serializer.toJson<int>(userConfirmed),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MinkProceduralMemoryData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    String? triggerPatternJson,
    String? actionPatternJson,
    int? observedCount,
    double? confidence,
    int? lastObservedAt,
    int? userConfirmed,
    int? createdAt,
    int? updatedAt,
  }) => MinkProceduralMemoryData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    triggerPatternJson: triggerPatternJson ?? this.triggerPatternJson,
    actionPatternJson: actionPatternJson ?? this.actionPatternJson,
    observedCount: observedCount ?? this.observedCount,
    confidence: confidence ?? this.confidence,
    lastObservedAt: lastObservedAt ?? this.lastObservedAt,
    userConfirmed: userConfirmed ?? this.userConfirmed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MinkProceduralMemoryData copyWithCompanion(
    MinkProceduralMemoryCompanion data,
  ) {
    return MinkProceduralMemoryData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      triggerPatternJson: data.triggerPatternJson.present
          ? data.triggerPatternJson.value
          : this.triggerPatternJson,
      actionPatternJson: data.actionPatternJson.present
          ? data.actionPatternJson.value
          : this.actionPatternJson,
      observedCount: data.observedCount.present
          ? data.observedCount.value
          : this.observedCount,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      lastObservedAt: data.lastObservedAt.present
          ? data.lastObservedAt.value
          : this.lastObservedAt,
      userConfirmed: data.userConfirmed.present
          ? data.userConfirmed.value
          : this.userConfirmed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinkProceduralMemoryData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('triggerPatternJson: $triggerPatternJson, ')
          ..write('actionPatternJson: $actionPatternJson, ')
          ..write('observedCount: $observedCount, ')
          ..write('confidence: $confidence, ')
          ..write('lastObservedAt: $lastObservedAt, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    triggerPatternJson,
    actionPatternJson,
    observedCount,
    confidence,
    lastObservedAt,
    userConfirmed,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinkProceduralMemoryData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.triggerPatternJson == this.triggerPatternJson &&
          other.actionPatternJson == this.actionPatternJson &&
          other.observedCount == this.observedCount &&
          other.confidence == this.confidence &&
          other.lastObservedAt == this.lastObservedAt &&
          other.userConfirmed == this.userConfirmed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MinkProceduralMemoryCompanion
    extends UpdateCompanion<MinkProceduralMemoryData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String> triggerPatternJson;
  final Value<String> actionPatternJson;
  final Value<int> observedCount;
  final Value<double> confidence;
  final Value<int> lastObservedAt;
  final Value<int> userConfirmed;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MinkProceduralMemoryCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.triggerPatternJson = const Value.absent(),
    this.actionPatternJson = const Value.absent(),
    this.observedCount = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastObservedAt = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinkProceduralMemoryCompanion.insert({
    required String id,
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String triggerPatternJson,
    required String actionPatternJson,
    this.observedCount = const Value.absent(),
    required double confidence,
    required int lastObservedAt,
    this.userConfirmed = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       triggerPatternJson = Value(triggerPatternJson),
       actionPatternJson = Value(actionPatternJson),
       confidence = Value(confidence),
       lastObservedAt = Value(lastObservedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MinkProceduralMemoryData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? triggerPatternJson,
    Expression<String>? actionPatternJson,
    Expression<int>? observedCount,
    Expression<double>? confidence,
    Expression<int>? lastObservedAt,
    Expression<int>? userConfirmed,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (triggerPatternJson != null)
        'trigger_pattern_json': triggerPatternJson,
      if (actionPatternJson != null) 'action_pattern_json': actionPatternJson,
      if (observedCount != null) 'observed_count': observedCount,
      if (confidence != null) 'confidence': confidence,
      if (lastObservedAt != null) 'last_observed_at': lastObservedAt,
      if (userConfirmed != null) 'user_confirmed': userConfirmed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinkProceduralMemoryCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String>? triggerPatternJson,
    Value<String>? actionPatternJson,
    Value<int>? observedCount,
    Value<double>? confidence,
    Value<int>? lastObservedAt,
    Value<int>? userConfirmed,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MinkProceduralMemoryCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      triggerPatternJson: triggerPatternJson ?? this.triggerPatternJson,
      actionPatternJson: actionPatternJson ?? this.actionPatternJson,
      observedCount: observedCount ?? this.observedCount,
      confidence: confidence ?? this.confidence,
      lastObservedAt: lastObservedAt ?? this.lastObservedAt,
      userConfirmed: userConfirmed ?? this.userConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (triggerPatternJson.present) {
      map['trigger_pattern_json'] = Variable<String>(triggerPatternJson.value);
    }
    if (actionPatternJson.present) {
      map['action_pattern_json'] = Variable<String>(actionPatternJson.value);
    }
    if (observedCount.present) {
      map['observed_count'] = Variable<int>(observedCount.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (lastObservedAt.present) {
      map['last_observed_at'] = Variable<int>(lastObservedAt.value);
    }
    if (userConfirmed.present) {
      map['user_confirmed'] = Variable<int>(userConfirmed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinkProceduralMemoryCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('triggerPatternJson: $triggerPatternJson, ')
          ..write('actionPatternJson: $actionPatternJson, ')
          ..write('observedCount: $observedCount, ')
          ..write('confidence: $confidence, ')
          ..write('lastObservedAt: $lastObservedAt, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $EntitiesTable entities = $EntitiesTable(this);
  late final $TokensTable tokens = $TokensTable(this);
  late final $CustomEntityTypesTable customEntityTypes =
      $CustomEntityTypesTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $VaultMetaTable vaultMeta = $VaultMetaTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $MinkCoreMemoryTable minkCoreMemory = $MinkCoreMemoryTable(this);
  late final $MinkEpisodicMemoryTable minkEpisodicMemory =
      $MinkEpisodicMemoryTable(this);
  late final $MinkSemanticMemoryTable minkSemanticMemory =
      $MinkSemanticMemoryTable(this);
  late final $MinkSemanticRelationshipsTable minkSemanticRelationships =
      $MinkSemanticRelationshipsTable(this);
  late final $MinkProceduralMemoryTable minkProceduralMemory =
      $MinkProceduralMemoryTable(this);
  late final Index idxEntitiesDocument = Index(
    'idx_entities_document',
    'CREATE INDEX idx_entities_document ON entities (document_id)',
  );
  late final Index idxTokensFingerprint = Index(
    'idx_tokens_fingerprint',
    'CREATE INDEX idx_tokens_fingerprint ON tokens (workspace_id, plaintext_fingerprint)',
  );
  late final Index idxChatMessagesSession = Index(
    'idx_chat_messages_session',
    'CREATE INDEX idx_chat_messages_session ON chat_messages (session_id, created_at)',
  );
  late final Index idxEpisodicTime = Index(
    'idx_episodic_time',
    'CREATE INDEX idx_episodic_time ON mink_episodic_memory (workspace_id, project_id, occurred_at)',
  );
  late final Index idxSemanticFingerprint = Index(
    'idx_semantic_fingerprint',
    'CREATE INDEX idx_semantic_fingerprint ON mink_semantic_memory (workspace_id, canonical_fingerprint)',
  );
  late final Index idxSemanticParent = Index(
    'idx_semantic_parent',
    'CREATE INDEX idx_semantic_parent ON mink_semantic_memory (parent_id)',
  );
  late final Index idxRelFrom = Index(
    'idx_rel_from',
    'CREATE INDEX idx_rel_from ON mink_semantic_relationships (from_entity_id)',
  );
  late final Index idxRelTo = Index(
    'idx_rel_to',
    'CREATE INDEX idx_rel_to ON mink_semantic_relationships (to_entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workspaces,
    projects,
    documents,
    entities,
    tokens,
    customEntityTypes,
    auditLog,
    vaultMeta,
    syncState,
    chatSessions,
    chatMessages,
    minkCoreMemory,
    minkEpisodicMemory,
    minkSemanticMemory,
    minkSemanticRelationships,
    minkProceduralMemory,
    idxEntitiesDocument,
    idxTokensFingerprint,
    idxChatMessagesSession,
    idxEpisodicTime,
    idxSemanticFingerprint,
    idxSemanticParent,
    idxRelFrom,
    idxRelTo,
  ];
}

typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      required String id,
      required String name,
      required int createdAt,
      required int kekVersion,
      Value<int> rowid,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> kekVersion,
      Value<int> rowid,
    });

final class $$WorkspacesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace> {
  $$WorkspacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: $_aliasNameGenerator(db.workspaces.id, db.projects.workspaceId),
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentsTable, List<Document>>
  _documentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: $_aliasNameGenerator(db.workspaces.id, db.documents.workspaceId),
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntitiesTable, List<Entity>> _entitiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entities,
    aliasName: $_aliasNameGenerator(db.workspaces.id, db.entities.workspaceId),
  );

  $$EntitiesTableProcessedTableManager get entitiesRefs {
    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TokensTable, List<Token>> _tokensRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tokens,
    aliasName: $_aliasNameGenerator(db.workspaces.id, db.tokens.workspaceId),
  );

  $$TokensTableProcessedTableManager get tokensRefs {
    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomEntityTypesTable, List<CustomEntityType>>
  _customEntityTypesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customEntityTypes,
        aliasName: $_aliasNameGenerator(
          db.workspaces.id,
          db.customEntityTypes.workspaceId,
        ),
      );

  $$CustomEntityTypesTableProcessedTableManager get customEntityTypesRefs {
    final manager = $$CustomEntityTypesTableTableManager(
      $_db,
      $_db.customEntityTypes,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customEntityTypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditLogTable, List<AuditLogData>>
  _auditLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.auditLog,
    aliasName: $_aliasNameGenerator(db.workspaces.id, db.auditLog.workspaceId),
  );

  $$AuditLogTableProcessedTableManager get auditLogRefs {
    final manager = $$AuditLogTableTableManager(
      $_db,
      $_db.auditLog,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatSessionsTable, List<ChatSession>>
  _chatSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatSessions,
    aliasName: $_aliasNameGenerator(
      db.workspaces.id,
      db.chatSessions.workspaceId,
    ),
  );

  $$ChatSessionsTableProcessedTableManager get chatSessionsRefs {
    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MinkCoreMemoryTable, List<MinkCoreMemoryData>>
  _minkCoreMemoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.minkCoreMemory,
    aliasName: $_aliasNameGenerator(
      db.workspaces.id,
      db.minkCoreMemory.workspaceId,
    ),
  );

  $$MinkCoreMemoryTableProcessedTableManager get minkCoreMemoryRefs {
    final manager = $$MinkCoreMemoryTableTableManager(
      $_db,
      $_db.minkCoreMemory,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_minkCoreMemoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkEpisodicMemoryTable,
    List<MinkEpisodicMemoryData>
  >
  _minkEpisodicMemoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkEpisodicMemory,
        aliasName: $_aliasNameGenerator(
          db.workspaces.id,
          db.minkEpisodicMemory.workspaceId,
        ),
      );

  $$MinkEpisodicMemoryTableProcessedTableManager get minkEpisodicMemoryRefs {
    final manager = $$MinkEpisodicMemoryTableTableManager(
      $_db,
      $_db.minkEpisodicMemory,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkEpisodicMemoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkSemanticMemoryTable,
    List<MinkSemanticMemoryData>
  >
  _minkSemanticMemoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkSemanticMemory,
        aliasName: $_aliasNameGenerator(
          db.workspaces.id,
          db.minkSemanticMemory.workspaceId,
        ),
      );

  $$MinkSemanticMemoryTableProcessedTableManager get minkSemanticMemoryRefs {
    final manager = $$MinkSemanticMemoryTableTableManager(
      $_db,
      $_db.minkSemanticMemory,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkSemanticMemoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkSemanticRelationshipsTable,
    List<MinkSemanticRelationship>
  >
  _minkSemanticRelationshipsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkSemanticRelationships,
        aliasName: $_aliasNameGenerator(
          db.workspaces.id,
          db.minkSemanticRelationships.workspaceId,
        ),
      );

  $$MinkSemanticRelationshipsTableProcessedTableManager
  get minkSemanticRelationshipsRefs {
    final manager = $$MinkSemanticRelationshipsTableTableManager(
      $_db,
      $_db.minkSemanticRelationships,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkSemanticRelationshipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkProceduralMemoryTable,
    List<MinkProceduralMemoryData>
  >
  _minkProceduralMemoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkProceduralMemory,
        aliasName: $_aliasNameGenerator(
          db.workspaces.id,
          db.minkProceduralMemory.workspaceId,
        ),
      );

  $$MinkProceduralMemoryTableProcessedTableManager
  get minkProceduralMemoryRefs {
    final manager = $$MinkProceduralMemoryTableTableManager(
      $_db,
      $_db.minkProceduralMemory,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkProceduralMemoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kekVersion => $composableBuilder(
    column: $table.kekVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entitiesRefs(
    Expression<bool> Function($$EntitiesTableFilterComposer f) f,
  ) {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tokensRefs(
    Expression<bool> Function($$TokensTableFilterComposer f) f,
  ) {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customEntityTypesRefs(
    Expression<bool> Function($$CustomEntityTypesTableFilterComposer f) f,
  ) {
    final $$CustomEntityTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customEntityTypes,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomEntityTypesTableFilterComposer(
            $db: $db,
            $table: $db.customEntityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditLogRefs(
    Expression<bool> Function($$AuditLogTableFilterComposer f) f,
  ) {
    final $$AuditLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLog,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogTableFilterComposer(
            $db: $db,
            $table: $db.auditLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatSessionsRefs(
    Expression<bool> Function($$ChatSessionsTableFilterComposer f) f,
  ) {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkCoreMemoryRefs(
    Expression<bool> Function($$MinkCoreMemoryTableFilterComposer f) f,
  ) {
    final $$MinkCoreMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkCoreMemory,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkCoreMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkCoreMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkEpisodicMemoryRefs(
    Expression<bool> Function($$MinkEpisodicMemoryTableFilterComposer f) f,
  ) {
    final $$MinkEpisodicMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkEpisodicMemory,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkEpisodicMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkEpisodicMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkSemanticMemoryRefs(
    Expression<bool> Function($$MinkSemanticMemoryTableFilterComposer f) f,
  ) {
    final $$MinkSemanticMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkSemanticRelationshipsRefs(
    Expression<bool> Function($$MinkSemanticRelationshipsTableFilterComposer f)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableFilterComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> minkProceduralMemoryRefs(
    Expression<bool> Function($$MinkProceduralMemoryTableFilterComposer f) f,
  ) {
    final $$MinkProceduralMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkProceduralMemory,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkProceduralMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkProceduralMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kekVersion => $composableBuilder(
    column: $table.kekVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get kekVersion => $composableBuilder(
    column: $table.kekVersion,
    builder: (column) => column,
  );

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entitiesRefs<T extends Object>(
    Expression<T> Function($$EntitiesTableAnnotationComposer a) f,
  ) {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tokensRefs<T extends Object>(
    Expression<T> Function($$TokensTableAnnotationComposer a) f,
  ) {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customEntityTypesRefs<T extends Object>(
    Expression<T> Function($$CustomEntityTypesTableAnnotationComposer a) f,
  ) {
    final $$CustomEntityTypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customEntityTypes,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomEntityTypesTableAnnotationComposer(
                $db: $db,
                $table: $db.customEntityTypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> auditLogRefs<T extends Object>(
    Expression<T> Function($$AuditLogTableAnnotationComposer a) f,
  ) {
    final $$AuditLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLog,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogTableAnnotationComposer(
            $db: $db,
            $table: $db.auditLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatSessionsRefs<T extends Object>(
    Expression<T> Function($$ChatSessionsTableAnnotationComposer a) f,
  ) {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> minkCoreMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkCoreMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkCoreMemoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkCoreMemory,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkCoreMemoryTableAnnotationComposer(
            $db: $db,
            $table: $db.minkCoreMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> minkEpisodicMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkEpisodicMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkEpisodicMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkEpisodicMemory,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkEpisodicMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkEpisodicMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> minkSemanticMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkSemanticMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkSemanticMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticMemory,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> minkSemanticRelationshipsRefs<T extends Object>(
    Expression<T> Function($$MinkSemanticRelationshipsTableAnnotationComposer a)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> minkProceduralMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkProceduralMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkProceduralMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkProceduralMemory,
          getReferencedColumn: (t) => t.workspaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkProceduralMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkProceduralMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          Workspace,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (Workspace, $$WorkspacesTableReferences),
          Workspace,
          PrefetchHooks Function({
            bool projectsRefs,
            bool documentsRefs,
            bool entitiesRefs,
            bool tokensRefs,
            bool customEntityTypesRefs,
            bool auditLogRefs,
            bool chatSessionsRefs,
            bool minkCoreMemoryRefs,
            bool minkEpisodicMemoryRefs,
            bool minkSemanticMemoryRefs,
            bool minkSemanticRelationshipsRefs,
            bool minkProceduralMemoryRefs,
          })
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> kekVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                kekVersion: kekVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAt,
                required int kekVersion,
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                kekVersion: kekVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectsRefs = false,
                documentsRefs = false,
                entitiesRefs = false,
                tokensRefs = false,
                customEntityTypesRefs = false,
                auditLogRefs = false,
                chatSessionsRefs = false,
                minkCoreMemoryRefs = false,
                minkEpisodicMemoryRefs = false,
                minkSemanticMemoryRefs = false,
                minkSemanticRelationshipsRefs = false,
                minkProceduralMemoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectsRefs) db.projects,
                    if (documentsRefs) db.documents,
                    if (entitiesRefs) db.entities,
                    if (tokensRefs) db.tokens,
                    if (customEntityTypesRefs) db.customEntityTypes,
                    if (auditLogRefs) db.auditLog,
                    if (chatSessionsRefs) db.chatSessions,
                    if (minkCoreMemoryRefs) db.minkCoreMemory,
                    if (minkEpisodicMemoryRefs) db.minkEpisodicMemory,
                    if (minkSemanticMemoryRefs) db.minkSemanticMemory,
                    if (minkSemanticRelationshipsRefs)
                      db.minkSemanticRelationships,
                    if (minkProceduralMemoryRefs) db.minkProceduralMemory,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectsRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          Project
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._projectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentsRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          Document
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._documentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).documentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entitiesRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          Entity
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._entitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).entitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tokensRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          Token
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._tokensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).tokensRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customEntityTypesRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          CustomEntityType
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._customEntityTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).customEntityTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auditLogRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          AuditLogData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._auditLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).auditLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatSessionsRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          ChatSession
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._chatSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).chatSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkCoreMemoryRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          MinkCoreMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._minkCoreMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).minkCoreMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkEpisodicMemoryRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          MinkEpisodicMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._minkEpisodicMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).minkEpisodicMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkSemanticMemoryRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          MinkSemanticMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._minkSemanticMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).minkSemanticMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkSemanticRelationshipsRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          MinkSemanticRelationship
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._minkSemanticRelationshipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).minkSemanticRelationshipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkProceduralMemoryRefs)
                        await $_getPrefetchedData<
                          Workspace,
                          $WorkspacesTable,
                          MinkProceduralMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._minkProceduralMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).minkProceduralMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      Workspace,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (Workspace, $$WorkspacesTableReferences),
      Workspace,
      PrefetchHooks Function({
        bool projectsRefs,
        bool documentsRefs,
        bool entitiesRefs,
        bool tokensRefs,
        bool customEntityTypesRefs,
        bool auditLogRefs,
        bool chatSessionsRefs,
        bool minkCoreMemoryRefs,
        bool minkEpisodicMemoryRefs,
        bool minkSemanticMemoryRefs,
        bool minkSemanticRelationshipsRefs,
        bool minkProceduralMemoryRefs,
      })
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String workspaceId,
      required String name,
      Value<String?> templateId,
      required String manifestJson,
      Value<int> manifestVersion,
      required int createdAt,
      required int updatedAt,
      Value<int> archived,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> name,
      Value<String?> templateId,
      Value<String> manifestJson,
      Value<int> manifestVersion,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> archived,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(db.projects.workspaceId, db.workspaces.id),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DocumentsTable, List<Document>>
  _documentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: $_aliasNameGenerator(db.projects.id, db.documents.projectId),
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomEntityTypesTable, List<CustomEntityType>>
  _customEntityTypesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customEntityTypes,
        aliasName: $_aliasNameGenerator(
          db.projects.id,
          db.customEntityTypes.projectId,
        ),
      );

  $$CustomEntityTypesTableProcessedTableManager get customEntityTypesRefs {
    final manager = $$CustomEntityTypesTableTableManager(
      $_db,
      $_db.customEntityTypes,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customEntityTypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatSessionsTable, List<ChatSession>>
  _chatSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatSessions,
    aliasName: $_aliasNameGenerator(db.projects.id, db.chatSessions.projectId),
  );

  $$ChatSessionsTableProcessedTableManager get chatSessionsRefs {
    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MinkCoreMemoryTable, List<MinkCoreMemoryData>>
  _minkCoreMemoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.minkCoreMemory,
    aliasName: $_aliasNameGenerator(
      db.projects.id,
      db.minkCoreMemory.projectId,
    ),
  );

  $$MinkCoreMemoryTableProcessedTableManager get minkCoreMemoryRefs {
    final manager = $$MinkCoreMemoryTableTableManager(
      $_db,
      $_db.minkCoreMemory,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_minkCoreMemoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkEpisodicMemoryTable,
    List<MinkEpisodicMemoryData>
  >
  _minkEpisodicMemoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkEpisodicMemory,
        aliasName: $_aliasNameGenerator(
          db.projects.id,
          db.minkEpisodicMemory.projectId,
        ),
      );

  $$MinkEpisodicMemoryTableProcessedTableManager get minkEpisodicMemoryRefs {
    final manager = $$MinkEpisodicMemoryTableTableManager(
      $_db,
      $_db.minkEpisodicMemory,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkEpisodicMemoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkSemanticMemoryTable,
    List<MinkSemanticMemoryData>
  >
  _minkSemanticMemoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkSemanticMemory,
        aliasName: $_aliasNameGenerator(
          db.projects.id,
          db.minkSemanticMemory.projectId,
        ),
      );

  $$MinkSemanticMemoryTableProcessedTableManager get minkSemanticMemoryRefs {
    final manager = $$MinkSemanticMemoryTableTableManager(
      $_db,
      $_db.minkSemanticMemory,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkSemanticMemoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkSemanticRelationshipsTable,
    List<MinkSemanticRelationship>
  >
  _minkSemanticRelationshipsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkSemanticRelationships,
        aliasName: $_aliasNameGenerator(
          db.projects.id,
          db.minkSemanticRelationships.projectId,
        ),
      );

  $$MinkSemanticRelationshipsTableProcessedTableManager
  get minkSemanticRelationshipsRefs {
    final manager = $$MinkSemanticRelationshipsTableTableManager(
      $_db,
      $_db.minkSemanticRelationships,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkSemanticRelationshipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkProceduralMemoryTable,
    List<MinkProceduralMemoryData>
  >
  _minkProceduralMemoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.minkProceduralMemory,
        aliasName: $_aliasNameGenerator(
          db.projects.id,
          db.minkProceduralMemory.projectId,
        ),
      );

  $$MinkProceduralMemoryTableProcessedTableManager
  get minkProceduralMemoryRefs {
    final manager = $$MinkProceduralMemoryTableTableManager(
      $_db,
      $_db.minkProceduralMemory,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _minkProceduralMemoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manifestVersion => $composableBuilder(
    column: $table.manifestVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customEntityTypesRefs(
    Expression<bool> Function($$CustomEntityTypesTableFilterComposer f) f,
  ) {
    final $$CustomEntityTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customEntityTypes,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomEntityTypesTableFilterComposer(
            $db: $db,
            $table: $db.customEntityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatSessionsRefs(
    Expression<bool> Function($$ChatSessionsTableFilterComposer f) f,
  ) {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkCoreMemoryRefs(
    Expression<bool> Function($$MinkCoreMemoryTableFilterComposer f) f,
  ) {
    final $$MinkCoreMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkCoreMemory,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkCoreMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkCoreMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkEpisodicMemoryRefs(
    Expression<bool> Function($$MinkEpisodicMemoryTableFilterComposer f) f,
  ) {
    final $$MinkEpisodicMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkEpisodicMemory,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkEpisodicMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkEpisodicMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkSemanticMemoryRefs(
    Expression<bool> Function($$MinkSemanticMemoryTableFilterComposer f) f,
  ) {
    final $$MinkSemanticMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> minkSemanticRelationshipsRefs(
    Expression<bool> Function($$MinkSemanticRelationshipsTableFilterComposer f)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableFilterComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> minkProceduralMemoryRefs(
    Expression<bool> Function($$MinkProceduralMemoryTableFilterComposer f) f,
  ) {
    final $$MinkProceduralMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkProceduralMemory,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkProceduralMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkProceduralMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manifestVersion => $composableBuilder(
    column: $table.manifestVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get manifestVersion => $composableBuilder(
    column: $table.manifestVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customEntityTypesRefs<T extends Object>(
    Expression<T> Function($$CustomEntityTypesTableAnnotationComposer a) f,
  ) {
    final $$CustomEntityTypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customEntityTypes,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomEntityTypesTableAnnotationComposer(
                $db: $db,
                $table: $db.customEntityTypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> chatSessionsRefs<T extends Object>(
    Expression<T> Function($$ChatSessionsTableAnnotationComposer a) f,
  ) {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> minkCoreMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkCoreMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkCoreMemoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.minkCoreMemory,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkCoreMemoryTableAnnotationComposer(
            $db: $db,
            $table: $db.minkCoreMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> minkEpisodicMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkEpisodicMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkEpisodicMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkEpisodicMemory,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkEpisodicMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkEpisodicMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> minkSemanticMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkSemanticMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkSemanticMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticMemory,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> minkSemanticRelationshipsRefs<T extends Object>(
    Expression<T> Function($$MinkSemanticRelationshipsTableAnnotationComposer a)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> minkProceduralMemoryRefs<T extends Object>(
    Expression<T> Function($$MinkProceduralMemoryTableAnnotationComposer a) f,
  ) {
    final $$MinkProceduralMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkProceduralMemory,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkProceduralMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkProceduralMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool workspaceId,
            bool documentsRefs,
            bool customEntityTypesRefs,
            bool chatSessionsRefs,
            bool minkCoreMemoryRefs,
            bool minkEpisodicMemoryRefs,
            bool minkSemanticMemoryRefs,
            bool minkSemanticRelationshipsRefs,
            bool minkProceduralMemoryRefs,
          })
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String> manifestJson = const Value.absent(),
                Value<int> manifestVersion = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                workspaceId: workspaceId,
                name: name,
                templateId: templateId,
                manifestJson: manifestJson,
                manifestVersion: manifestVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String name,
                Value<String?> templateId = const Value.absent(),
                required String manifestJson,
                Value<int> manifestVersion = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                name: name,
                templateId: templateId,
                manifestJson: manifestJson,
                manifestVersion: manifestVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                documentsRefs = false,
                customEntityTypesRefs = false,
                chatSessionsRefs = false,
                minkCoreMemoryRefs = false,
                minkEpisodicMemoryRefs = false,
                minkSemanticMemoryRefs = false,
                minkSemanticRelationshipsRefs = false,
                minkProceduralMemoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentsRefs) db.documents,
                    if (customEntityTypesRefs) db.customEntityTypes,
                    if (chatSessionsRefs) db.chatSessions,
                    if (minkCoreMemoryRefs) db.minkCoreMemory,
                    if (minkEpisodicMemoryRefs) db.minkEpisodicMemory,
                    if (minkSemanticMemoryRefs) db.minkSemanticMemory,
                    if (minkSemanticRelationshipsRefs)
                      db.minkSemanticRelationships,
                    if (minkProceduralMemoryRefs) db.minkProceduralMemory,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable: $$ProjectsTableReferences
                                        ._workspaceIdTable(db),
                                    referencedColumn: $$ProjectsTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Document
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._documentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customEntityTypesRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          CustomEntityType
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._customEntityTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).customEntityTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatSessionsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          ChatSession
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._chatSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkCoreMemoryRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          MinkCoreMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._minkCoreMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).minkCoreMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkEpisodicMemoryRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          MinkEpisodicMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._minkEpisodicMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).minkEpisodicMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkSemanticMemoryRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          MinkSemanticMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._minkSemanticMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).minkSemanticMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkSemanticRelationshipsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          MinkSemanticRelationship
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._minkSemanticRelationshipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).minkSemanticRelationshipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (minkProceduralMemoryRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          MinkProceduralMemoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._minkProceduralMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).minkProceduralMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({
        bool workspaceId,
        bool documentsRefs,
        bool customEntityTypesRefs,
        bool chatSessionsRefs,
        bool minkCoreMemoryRefs,
        bool minkEpisodicMemoryRefs,
        bool minkSemanticMemoryRefs,
        bool minkSemanticRelationshipsRefs,
        bool minkProceduralMemoryRefs,
      })
    >;
typedef $$DocumentsTableCreateCompanionBuilder =
    DocumentsCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required String name,
      required String type,
      required Uint8List sourceHash,
      required int createdAt,
      required int updatedAt,
      Value<String?> redactedArtifactPath,
      required String status,
      Value<String?> metadataJson,
      Value<int> rowid,
    });
typedef $$DocumentsTableUpdateCompanionBuilder =
    DocumentsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String> name,
      Value<String> type,
      Value<Uint8List> sourceHash,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> redactedArtifactPath,
      Value<String> status,
      Value<String?> metadataJson,
      Value<int> rowid,
    });

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, Document> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(db.documents.workspaceId, db.workspaces.id),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.documents.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntitiesTable, List<Entity>> _entitiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entities,
    aliasName: $_aliasNameGenerator(db.documents.id, db.entities.documentId),
  );

  $$EntitiesTableProcessedTableManager get entitiesRefs {
    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redactedArtifactPath => $composableBuilder(
    column: $table.redactedArtifactPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entitiesRefs(
    Expression<bool> Function($$EntitiesTableFilterComposer f) f,
  ) {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redactedArtifactPath => $composableBuilder(
    column: $table.redactedArtifactPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<Uint8List> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get redactedArtifactPath => $composableBuilder(
    column: $table.redactedArtifactPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entitiesRefs<T extends Object>(
    Expression<T> Function($$EntitiesTableAnnotationComposer a) f,
  ) {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, $$DocumentsTableReferences),
          Document,
          PrefetchHooks Function({
            bool workspaceId,
            bool projectId,
            bool entitiesRefs,
          })
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<Uint8List> sourceHash = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> redactedArtifactPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                name: name,
                type: type,
                sourceHash: sourceHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                redactedArtifactPath: redactedArtifactPath,
                status: status,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required String name,
                required String type,
                required Uint8List sourceHash,
                required int createdAt,
                required int updatedAt,
                Value<String?> redactedArtifactPath = const Value.absent(),
                required String status,
                Value<String?> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                name: name,
                type: type,
                sourceHash: sourceHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                redactedArtifactPath: redactedArtifactPath,
                status: status,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workspaceId = false, projectId = false, entitiesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (entitiesRefs) db.entities],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable: $$DocumentsTableReferences
                                        ._workspaceIdTable(db),
                                    referencedColumn: $$DocumentsTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$DocumentsTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn: $$DocumentsTableReferences
                                        ._projectIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entitiesRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          Entity
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._entitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).entitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, $$DocumentsTableReferences),
      Document,
      PrefetchHooks Function({
        bool workspaceId,
        bool projectId,
        bool entitiesRefs,
      })
    >;
typedef $$EntitiesTableCreateCompanionBuilder =
    EntitiesCompanion Function({
      required String id,
      required String workspaceId,
      required String documentId,
      required String entityType,
      required String detector,
      required int spanStart,
      required int spanEnd,
      required double confidence,
      required String operatorApplied,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$EntitiesTableUpdateCompanionBuilder =
    EntitiesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> documentId,
      Value<String> entityType,
      Value<String> detector,
      Value<int> spanStart,
      Value<int> spanEnd,
      Value<double> confidence,
      Value<String> operatorApplied,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$EntitiesTableReferences
    extends BaseReferences<_$AppDatabase, $EntitiesTable, Entity> {
  $$EntitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(db.entities.workspaceId, db.workspaces.id),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias(
        $_aliasNameGenerator(db.entities.documentId, db.documents.id),
      );

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TokensTable, List<Token>> _tokensRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tokens,
    aliasName: $_aliasNameGenerator(db.entities.id, db.tokens.entityId),
  );

  $$TokensTableProcessedTableManager get tokensRefs {
    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.entityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detector => $composableBuilder(
    column: $table.detector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spanStart => $composableBuilder(
    column: $table.spanStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spanEnd => $composableBuilder(
    column: $table.spanEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorApplied => $composableBuilder(
    column: $table.operatorApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tokensRefs(
    Expression<bool> Function($$TokensTableFilterComposer f) f,
  ) {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detector => $composableBuilder(
    column: $table.detector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spanStart => $composableBuilder(
    column: $table.spanStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spanEnd => $composableBuilder(
    column: $table.spanEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorApplied => $composableBuilder(
    column: $table.operatorApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detector =>
      $composableBuilder(column: $table.detector, builder: (column) => column);

  GeneratedColumn<int> get spanStart =>
      $composableBuilder(column: $table.spanStart, builder: (column) => column);

  GeneratedColumn<int> get spanEnd =>
      $composableBuilder(column: $table.spanEnd, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operatorApplied => $composableBuilder(
    column: $table.operatorApplied,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tokensRefs<T extends Object>(
    Expression<T> Function($$TokensTableAnnotationComposer a) f,
  ) {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntitiesTable,
          Entity,
          $$EntitiesTableFilterComposer,
          $$EntitiesTableOrderingComposer,
          $$EntitiesTableAnnotationComposer,
          $$EntitiesTableCreateCompanionBuilder,
          $$EntitiesTableUpdateCompanionBuilder,
          (Entity, $$EntitiesTableReferences),
          Entity,
          PrefetchHooks Function({
            bool workspaceId,
            bool documentId,
            bool tokensRefs,
          })
        > {
  $$EntitiesTableTableManager(_$AppDatabase db, $EntitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> detector = const Value.absent(),
                Value<int> spanStart = const Value.absent(),
                Value<int> spanEnd = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> operatorApplied = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion(
                id: id,
                workspaceId: workspaceId,
                documentId: documentId,
                entityType: entityType,
                detector: detector,
                spanStart: spanStart,
                spanEnd: spanEnd,
                confidence: confidence,
                operatorApplied: operatorApplied,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String documentId,
                required String entityType,
                required String detector,
                required int spanStart,
                required int spanEnd,
                required double confidence,
                required String operatorApplied,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                documentId: documentId,
                entityType: entityType,
                detector: detector,
                spanStart: spanStart,
                spanEnd: spanEnd,
                confidence: confidence,
                operatorApplied: operatorApplied,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workspaceId = false, documentId = false, tokensRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (tokensRefs) db.tokens],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable: $$EntitiesTableReferences
                                        ._workspaceIdTable(db),
                                    referencedColumn: $$EntitiesTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (documentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.documentId,
                                    referencedTable: $$EntitiesTableReferences
                                        ._documentIdTable(db),
                                    referencedColumn: $$EntitiesTableReferences
                                        ._documentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tokensRefs)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          Token
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._tokensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).tokensRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntitiesTable,
      Entity,
      $$EntitiesTableFilterComposer,
      $$EntitiesTableOrderingComposer,
      $$EntitiesTableAnnotationComposer,
      $$EntitiesTableCreateCompanionBuilder,
      $$EntitiesTableUpdateCompanionBuilder,
      (Entity, $$EntitiesTableReferences),
      Entity,
      PrefetchHooks Function({
        bool workspaceId,
        bool documentId,
        bool tokensRefs,
      })
    >;
typedef $$TokensTableCreateCompanionBuilder =
    TokensCompanion Function({
      required String id,
      required String workspaceId,
      required String entityId,
      required String tokenValue,
      required Uint8List plaintextFingerprint,
      required Uint8List ciphertext,
      required int keyVersion,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$TokensTableUpdateCompanionBuilder =
    TokensCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> entityId,
      Value<String> tokenValue,
      Value<Uint8List> plaintextFingerprint,
      Value<Uint8List> ciphertext,
      Value<int> keyVersion,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$TokensTableReferences
    extends BaseReferences<_$AppDatabase, $TokensTable, Token> {
  $$TokensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(db.tokens.workspaceId, db.workspaces.id),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EntitiesTable _entityIdTable(_$AppDatabase db) => db.entities
      .createAlias($_aliasNameGenerator(db.tokens.entityId, db.entities.id));

  $$EntitiesTableProcessedTableManager get entityId {
    final $_column = $_itemColumn<String>('entity_id')!;

    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TokensTableFilterComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenValue => $composableBuilder(
    column: $table.tokenValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get plaintextFingerprint => $composableBuilder(
    column: $table.plaintextFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyVersion => $composableBuilder(
    column: $table.keyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableFilterComposer get entityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokensTableOrderingComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenValue => $composableBuilder(
    column: $table.tokenValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get plaintextFingerprint => $composableBuilder(
    column: $table.plaintextFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyVersion => $composableBuilder(
    column: $table.keyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableOrderingComposer get entityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tokenValue => $composableBuilder(
    column: $table.tokenValue,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get plaintextFingerprint => $composableBuilder(
    column: $table.plaintextFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => column,
  );

  GeneratedColumn<int> get keyVersion => $composableBuilder(
    column: $table.keyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableAnnotationComposer get entityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TokensTable,
          Token,
          $$TokensTableFilterComposer,
          $$TokensTableOrderingComposer,
          $$TokensTableAnnotationComposer,
          $$TokensTableCreateCompanionBuilder,
          $$TokensTableUpdateCompanionBuilder,
          (Token, $$TokensTableReferences),
          Token,
          PrefetchHooks Function({bool workspaceId, bool entityId})
        > {
  $$TokensTableTableManager(_$AppDatabase db, $TokensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> tokenValue = const Value.absent(),
                Value<Uint8List> plaintextFingerprint = const Value.absent(),
                Value<Uint8List> ciphertext = const Value.absent(),
                Value<int> keyVersion = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TokensCompanion(
                id: id,
                workspaceId: workspaceId,
                entityId: entityId,
                tokenValue: tokenValue,
                plaintextFingerprint: plaintextFingerprint,
                ciphertext: ciphertext,
                keyVersion: keyVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String entityId,
                required String tokenValue,
                required Uint8List plaintextFingerprint,
                required Uint8List ciphertext,
                required int keyVersion,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TokensCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                entityId: entityId,
                tokenValue: tokenValue,
                plaintextFingerprint: plaintextFingerprint,
                ciphertext: ciphertext,
                keyVersion: keyVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TokensTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, entityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable: $$TokensTableReferences
                                    ._workspaceIdTable(db),
                                referencedColumn: $$TokensTableReferences
                                    ._workspaceIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (entityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entityId,
                                referencedTable: $$TokensTableReferences
                                    ._entityIdTable(db),
                                referencedColumn: $$TokensTableReferences
                                    ._entityIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TokensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TokensTable,
      Token,
      $$TokensTableFilterComposer,
      $$TokensTableOrderingComposer,
      $$TokensTableAnnotationComposer,
      $$TokensTableCreateCompanionBuilder,
      $$TokensTableUpdateCompanionBuilder,
      (Token, $$TokensTableReferences),
      Token,
      PrefetchHooks Function({bool workspaceId, bool entityId})
    >;
typedef $$CustomEntityTypesTableCreateCompanionBuilder =
    CustomEntityTypesCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required String label,
      Value<String?> regexPattern,
      Value<String?> validator,
      Value<String?> examplesJson,
      required String defaultOperator,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CustomEntityTypesTableUpdateCompanionBuilder =
    CustomEntityTypesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String> label,
      Value<String?> regexPattern,
      Value<String?> validator,
      Value<String?> examplesJson,
      Value<String> defaultOperator,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$CustomEntityTypesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomEntityTypesTable,
          CustomEntityType
        > {
  $$CustomEntityTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(
          db.customEntityTypes.workspaceId,
          db.workspaces.id,
        ),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.customEntityTypes.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomEntityTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomEntityTypesTable> {
  $$CustomEntityTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regexPattern => $composableBuilder(
    column: $table.regexPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validator => $composableBuilder(
    column: $table.validator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultOperator => $composableBuilder(
    column: $table.defaultOperator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomEntityTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomEntityTypesTable> {
  $$CustomEntityTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regexPattern => $composableBuilder(
    column: $table.regexPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validator => $composableBuilder(
    column: $table.validator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultOperator => $composableBuilder(
    column: $table.defaultOperator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomEntityTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomEntityTypesTable> {
  $$CustomEntityTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get regexPattern => $composableBuilder(
    column: $table.regexPattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get validator =>
      $composableBuilder(column: $table.validator, builder: (column) => column);

  GeneratedColumn<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultOperator => $composableBuilder(
    column: $table.defaultOperator,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomEntityTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomEntityTypesTable,
          CustomEntityType,
          $$CustomEntityTypesTableFilterComposer,
          $$CustomEntityTypesTableOrderingComposer,
          $$CustomEntityTypesTableAnnotationComposer,
          $$CustomEntityTypesTableCreateCompanionBuilder,
          $$CustomEntityTypesTableUpdateCompanionBuilder,
          (CustomEntityType, $$CustomEntityTypesTableReferences),
          CustomEntityType,
          PrefetchHooks Function({bool workspaceId, bool projectId})
        > {
  $$CustomEntityTypesTableTableManager(
    _$AppDatabase db,
    $CustomEntityTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomEntityTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomEntityTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomEntityTypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> regexPattern = const Value.absent(),
                Value<String?> validator = const Value.absent(),
                Value<String?> examplesJson = const Value.absent(),
                Value<String> defaultOperator = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomEntityTypesCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                label: label,
                regexPattern: regexPattern,
                validator: validator,
                examplesJson: examplesJson,
                defaultOperator: defaultOperator,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required String label,
                Value<String?> regexPattern = const Value.absent(),
                Value<String?> validator = const Value.absent(),
                Value<String?> examplesJson = const Value.absent(),
                required String defaultOperator,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomEntityTypesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                label: label,
                regexPattern: regexPattern,
                validator: validator,
                examplesJson: examplesJson,
                defaultOperator: defaultOperator,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomEntityTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable:
                                    $$CustomEntityTypesTableReferences
                                        ._workspaceIdTable(db),
                                referencedColumn:
                                    $$CustomEntityTypesTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable:
                                    $$CustomEntityTypesTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$CustomEntityTypesTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomEntityTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomEntityTypesTable,
      CustomEntityType,
      $$CustomEntityTypesTableFilterComposer,
      $$CustomEntityTypesTableOrderingComposer,
      $$CustomEntityTypesTableAnnotationComposer,
      $$CustomEntityTypesTableCreateCompanionBuilder,
      $$CustomEntityTypesTableUpdateCompanionBuilder,
      (CustomEntityType, $$CustomEntityTypesTableReferences),
      CustomEntityType,
      PrefetchHooks Function({bool workspaceId, bool projectId})
    >;
typedef $$AuditLogTableCreateCompanionBuilder =
    AuditLogCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required String eventType,
      Value<String?> documentId,
      Value<String?> entityId,
      Value<String?> toolName,
      required int success,
      Value<String?> biometricResult,
      Value<String?> metadataJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AuditLogTableUpdateCompanionBuilder =
    AuditLogCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String> eventType,
      Value<String?> documentId,
      Value<String?> entityId,
      Value<String?> toolName,
      Value<int> success,
      Value<String?> biometricResult,
      Value<String?> metadataJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$AuditLogTableReferences
    extends BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData> {
  $$AuditLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(db.auditLog.workspaceId, db.workspaces.id),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get biometricResult => $composableBuilder(
    column: $table.biometricResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get biometricResult => $composableBuilder(
    column: $table.biometricResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<int> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get biometricResult => $composableBuilder(
    column: $table.biometricResult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogTable,
          AuditLogData,
          $$AuditLogTableFilterComposer,
          $$AuditLogTableOrderingComposer,
          $$AuditLogTableAnnotationComposer,
          $$AuditLogTableCreateCompanionBuilder,
          $$AuditLogTableUpdateCompanionBuilder,
          (AuditLogData, $$AuditLogTableReferences),
          AuditLogData,
          PrefetchHooks Function({bool workspaceId})
        > {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String?> toolName = const Value.absent(),
                Value<int> success = const Value.absent(),
                Value<String?> biometricResult = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                eventType: eventType,
                documentId: documentId,
                entityId: entityId,
                toolName: toolName,
                success: success,
                biometricResult: biometricResult,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required String eventType,
                Value<String?> documentId = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String?> toolName = const Value.absent(),
                required int success,
                Value<String?> biometricResult = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                eventType: eventType,
                documentId: documentId,
                entityId: entityId,
                toolName: toolName,
                success: success,
                biometricResult: biometricResult,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AuditLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable: $$AuditLogTableReferences
                                    ._workspaceIdTable(db),
                                referencedColumn: $$AuditLogTableReferences
                                    ._workspaceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuditLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogTable,
      AuditLogData,
      $$AuditLogTableFilterComposer,
      $$AuditLogTableOrderingComposer,
      $$AuditLogTableAnnotationComposer,
      $$AuditLogTableCreateCompanionBuilder,
      $$AuditLogTableUpdateCompanionBuilder,
      (AuditLogData, $$AuditLogTableReferences),
      AuditLogData,
      PrefetchHooks Function({bool workspaceId})
    >;
typedef $$VaultMetaTableCreateCompanionBuilder =
    VaultMetaCompanion Function({
      required String key,
      required Uint8List value,
      Value<int> rowid,
    });
typedef $$VaultMetaTableUpdateCompanionBuilder =
    VaultMetaCompanion Function({
      Value<String> key,
      Value<Uint8List> value,
      Value<int> rowid,
    });

class $$VaultMetaTableFilterComposer
    extends Composer<_$AppDatabase, $VaultMetaTable> {
  $$VaultMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $VaultMetaTable> {
  $$VaultMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaultMetaTable> {
  $$VaultMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<Uint8List> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$VaultMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaultMetaTable,
          VaultMetaData,
          $$VaultMetaTableFilterComposer,
          $$VaultMetaTableOrderingComposer,
          $$VaultMetaTableAnnotationComposer,
          $$VaultMetaTableCreateCompanionBuilder,
          $$VaultMetaTableUpdateCompanionBuilder,
          (
            VaultMetaData,
            BaseReferences<_$AppDatabase, $VaultMetaTable, VaultMetaData>,
          ),
          VaultMetaData,
          PrefetchHooks Function()
        > {
  $$VaultMetaTableTableManager(_$AppDatabase db, $VaultMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<Uint8List> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required Uint8List value,
                Value<int> rowid = const Value.absent(),
              }) => VaultMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaultMetaTable,
      VaultMetaData,
      $$VaultMetaTableFilterComposer,
      $$VaultMetaTableOrderingComposer,
      $$VaultMetaTableAnnotationComposer,
      $$VaultMetaTableCreateCompanionBuilder,
      $$VaultMetaTableUpdateCompanionBuilder,
      (
        VaultMetaData,
        BaseReferences<_$AppDatabase, $VaultMetaTable, VaultMetaData>,
      ),
      VaultMetaData,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String deviceId,
      Value<int?> lastPushAt,
      Value<int?> lastPullAt,
      Value<String?> peerPublicKeysJson,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> deviceId,
      Value<int?> lastPushAt,
      Value<int?> lastPullAt,
      Value<String?> peerPublicKeysJson,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerPublicKeysJson => $composableBuilder(
    column: $table.peerPublicKeysJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerPublicKeysJson => $composableBuilder(
    column: $table.peerPublicKeysJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerPublicKeysJson => $composableBuilder(
    column: $table.peerPublicKeysJson,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<int?> lastPushAt = const Value.absent(),
                Value<int?> lastPullAt = const Value.absent(),
                Value<String?> peerPublicKeysJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                deviceId: deviceId,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                peerPublicKeysJson: peerPublicKeysJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                Value<int?> lastPushAt = const Value.absent(),
                Value<int?> lastPullAt = const Value.absent(),
                Value<String?> peerPublicKeysJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                deviceId: deviceId,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                peerPublicKeysJson: peerPublicKeysJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ChatSessionsTableCreateCompanionBuilder =
    ChatSessionsCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      Value<String?> title,
      required int createdAt,
      required int updatedAt,
      required String tierAtCreation,
      required String variantAtCreation,
      required String modelIdAtCreation,
      Value<int> archived,
      Value<int> rowid,
    });
typedef $$ChatSessionsTableUpdateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String?> title,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> tierAtCreation,
      Value<String> variantAtCreation,
      Value<String> modelIdAtCreation,
      Value<int> archived,
      Value<int> rowid,
    });

final class $$ChatSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession> {
  $$ChatSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(db.chatSessions.workspaceId, db.workspaces.id),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.chatSessions.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: $_aliasNameGenerator(
      db.chatSessions.id,
      db.chatMessages.sessionId,
    ),
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tierAtCreation => $composableBuilder(
    column: $table.tierAtCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantAtCreation => $composableBuilder(
    column: $table.variantAtCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelIdAtCreation => $composableBuilder(
    column: $table.modelIdAtCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tierAtCreation => $composableBuilder(
    column: $table.tierAtCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantAtCreation => $composableBuilder(
    column: $table.variantAtCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelIdAtCreation => $composableBuilder(
    column: $table.modelIdAtCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get tierAtCreation => $composableBuilder(
    column: $table.tierAtCreation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variantAtCreation => $composableBuilder(
    column: $table.variantAtCreation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelIdAtCreation => $composableBuilder(
    column: $table.modelIdAtCreation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatSessionsTable,
          ChatSession,
          $$ChatSessionsTableFilterComposer,
          $$ChatSessionsTableOrderingComposer,
          $$ChatSessionsTableAnnotationComposer,
          $$ChatSessionsTableCreateCompanionBuilder,
          $$ChatSessionsTableUpdateCompanionBuilder,
          (ChatSession, $$ChatSessionsTableReferences),
          ChatSession,
          PrefetchHooks Function({
            bool workspaceId,
            bool projectId,
            bool chatMessagesRefs,
          })
        > {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> tierAtCreation = const Value.absent(),
                Value<String> variantAtCreation = const Value.absent(),
                Value<String> modelIdAtCreation = const Value.absent(),
                Value<int> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatSessionsCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tierAtCreation: tierAtCreation,
                variantAtCreation: variantAtCreation,
                modelIdAtCreation: modelIdAtCreation,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required String tierAtCreation,
                required String variantAtCreation,
                required String modelIdAtCreation,
                Value<int> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatSessionsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tierAtCreation: tierAtCreation,
                variantAtCreation: variantAtCreation,
                modelIdAtCreation: modelIdAtCreation,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                projectId = false,
                chatMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$ChatSessionsTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$ChatSessionsTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$ChatSessionsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$ChatSessionsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          ChatSession,
                          $ChatSessionsTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ChatSessionsTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChatSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatSessionsTable,
      ChatSession,
      $$ChatSessionsTableFilterComposer,
      $$ChatSessionsTableOrderingComposer,
      $$ChatSessionsTableAnnotationComposer,
      $$ChatSessionsTableCreateCompanionBuilder,
      $$ChatSessionsTableUpdateCompanionBuilder,
      (ChatSession, $$ChatSessionsTableReferences),
      ChatSession,
      PrefetchHooks Function({
        bool workspaceId,
        bool projectId,
        bool chatMessagesRefs,
      })
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String sessionId,
      required String role,
      required String content,
      Value<String?> toolCallJson,
      Value<String?> toolResultJson,
      Value<int?> tokensInput,
      Value<int?> tokensOutput,
      Value<int?> inferenceMs,
      required String modelId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> role,
      Value<String> content,
      Value<String?> toolCallJson,
      Value<String?> toolResultJson,
      Value<int?> tokensInput,
      Value<int?> tokensOutput,
      Value<int?> inferenceMs,
      Value<String> modelId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.chatSessions.createAlias(
        $_aliasNameGenerator(db.chatMessages.sessionId, db.chatSessions.id),
      );

  $$ChatSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCallJson => $composableBuilder(
    column: $table.toolCallJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolResultJson => $composableBuilder(
    column: $table.toolResultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensInput => $composableBuilder(
    column: $table.tokensInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensOutput => $composableBuilder(
    column: $table.tokensOutput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inferenceMs => $composableBuilder(
    column: $table.inferenceMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatSessionsTableFilterComposer get sessionId {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCallJson => $composableBuilder(
    column: $table.toolCallJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolResultJson => $composableBuilder(
    column: $table.toolResultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensInput => $composableBuilder(
    column: $table.tokensInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensOutput => $composableBuilder(
    column: $table.tokensOutput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inferenceMs => $composableBuilder(
    column: $table.inferenceMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatSessionsTableOrderingComposer get sessionId {
    final $$ChatSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get toolCallJson => $composableBuilder(
    column: $table.toolCallJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toolResultJson => $composableBuilder(
    column: $table.toolResultJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tokensInput => $composableBuilder(
    column: $table.tokensInput,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tokensOutput => $composableBuilder(
    column: $table.tokensOutput,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inferenceMs => $composableBuilder(
    column: $table.inferenceMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChatSessionsTableAnnotationComposer get sessionId {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> toolCallJson = const Value.absent(),
                Value<String?> toolResultJson = const Value.absent(),
                Value<int?> tokensInput = const Value.absent(),
                Value<int?> tokensOutput = const Value.absent(),
                Value<int?> inferenceMs = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                toolCallJson: toolCallJson,
                toolResultJson: toolResultJson,
                tokensInput: tokensInput,
                tokensOutput: tokensOutput,
                inferenceMs: inferenceMs,
                modelId: modelId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String role,
                required String content,
                Value<String?> toolCallJson = const Value.absent(),
                Value<String?> toolResultJson = const Value.absent(),
                Value<int?> tokensInput = const Value.absent(),
                Value<int?> tokensOutput = const Value.absent(),
                Value<int?> inferenceMs = const Value.absent(),
                required String modelId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                toolCallJson: toolCallJson,
                toolResultJson: toolResultJson,
                tokensInput: tokensInput,
                tokensOutput: tokensOutput,
                inferenceMs: inferenceMs,
                modelId: modelId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$MinkCoreMemoryTableCreateCompanionBuilder =
    MinkCoreMemoryCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required String key,
      required String valueJson,
      required String provenance,
      Value<double?> confidence,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MinkCoreMemoryTableUpdateCompanionBuilder =
    MinkCoreMemoryCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String> key,
      Value<String> valueJson,
      Value<String> provenance,
      Value<double?> confidence,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$MinkCoreMemoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinkCoreMemoryTable,
          MinkCoreMemoryData
        > {
  $$MinkCoreMemoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(db.minkCoreMemory.workspaceId, db.workspaces.id),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.minkCoreMemory.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinkCoreMemoryTableFilterComposer
    extends Composer<_$AppDatabase, $MinkCoreMemoryTable> {
  $$MinkCoreMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkCoreMemoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MinkCoreMemoryTable> {
  $$MinkCoreMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkCoreMemoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinkCoreMemoryTable> {
  $$MinkCoreMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkCoreMemoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinkCoreMemoryTable,
          MinkCoreMemoryData,
          $$MinkCoreMemoryTableFilterComposer,
          $$MinkCoreMemoryTableOrderingComposer,
          $$MinkCoreMemoryTableAnnotationComposer,
          $$MinkCoreMemoryTableCreateCompanionBuilder,
          $$MinkCoreMemoryTableUpdateCompanionBuilder,
          (MinkCoreMemoryData, $$MinkCoreMemoryTableReferences),
          MinkCoreMemoryData,
          PrefetchHooks Function({bool workspaceId, bool projectId})
        > {
  $$MinkCoreMemoryTableTableManager(
    _$AppDatabase db,
    $MinkCoreMemoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinkCoreMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MinkCoreMemoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MinkCoreMemoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinkCoreMemoryCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                key: key,
                valueJson: valueJson,
                provenance: provenance,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required String key,
                required String valueJson,
                required String provenance,
                Value<double?> confidence = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MinkCoreMemoryCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                key: key,
                valueJson: valueJson,
                provenance: provenance,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinkCoreMemoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable: $$MinkCoreMemoryTableReferences
                                    ._workspaceIdTable(db),
                                referencedColumn:
                                    $$MinkCoreMemoryTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$MinkCoreMemoryTableReferences
                                    ._projectIdTable(db),
                                referencedColumn:
                                    $$MinkCoreMemoryTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MinkCoreMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinkCoreMemoryTable,
      MinkCoreMemoryData,
      $$MinkCoreMemoryTableFilterComposer,
      $$MinkCoreMemoryTableOrderingComposer,
      $$MinkCoreMemoryTableAnnotationComposer,
      $$MinkCoreMemoryTableCreateCompanionBuilder,
      $$MinkCoreMemoryTableUpdateCompanionBuilder,
      (MinkCoreMemoryData, $$MinkCoreMemoryTableReferences),
      MinkCoreMemoryData,
      PrefetchHooks Function({bool workspaceId, bool projectId})
    >;
typedef $$MinkEpisodicMemoryTableCreateCompanionBuilder =
    MinkEpisodicMemoryCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required int occurredAt,
      required String summary,
      Value<String?> detailsJson,
      required String episodeType,
      Value<String?> tokenRefsJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$MinkEpisodicMemoryTableUpdateCompanionBuilder =
    MinkEpisodicMemoryCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<int> occurredAt,
      Value<String> summary,
      Value<String?> detailsJson,
      Value<String> episodeType,
      Value<String?> tokenRefsJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$MinkEpisodicMemoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinkEpisodicMemoryTable,
          MinkEpisodicMemoryData
        > {
  $$MinkEpisodicMemoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(
          db.minkEpisodicMemory.workspaceId,
          db.workspaces.id,
        ),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.minkEpisodicMemory.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinkEpisodicMemoryTableFilterComposer
    extends Composer<_$AppDatabase, $MinkEpisodicMemoryTable> {
  $$MinkEpisodicMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeType => $composableBuilder(
    column: $table.episodeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenRefsJson => $composableBuilder(
    column: $table.tokenRefsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkEpisodicMemoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MinkEpisodicMemoryTable> {
  $$MinkEpisodicMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeType => $composableBuilder(
    column: $table.episodeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenRefsJson => $composableBuilder(
    column: $table.tokenRefsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkEpisodicMemoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinkEpisodicMemoryTable> {
  $$MinkEpisodicMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get episodeType => $composableBuilder(
    column: $table.episodeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tokenRefsJson => $composableBuilder(
    column: $table.tokenRefsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkEpisodicMemoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinkEpisodicMemoryTable,
          MinkEpisodicMemoryData,
          $$MinkEpisodicMemoryTableFilterComposer,
          $$MinkEpisodicMemoryTableOrderingComposer,
          $$MinkEpisodicMemoryTableAnnotationComposer,
          $$MinkEpisodicMemoryTableCreateCompanionBuilder,
          $$MinkEpisodicMemoryTableUpdateCompanionBuilder,
          (MinkEpisodicMemoryData, $$MinkEpisodicMemoryTableReferences),
          MinkEpisodicMemoryData,
          PrefetchHooks Function({bool workspaceId, bool projectId})
        > {
  $$MinkEpisodicMemoryTableTableManager(
    _$AppDatabase db,
    $MinkEpisodicMemoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinkEpisodicMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MinkEpisodicMemoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MinkEpisodicMemoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> detailsJson = const Value.absent(),
                Value<String> episodeType = const Value.absent(),
                Value<String?> tokenRefsJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinkEpisodicMemoryCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                occurredAt: occurredAt,
                summary: summary,
                detailsJson: detailsJson,
                episodeType: episodeType,
                tokenRefsJson: tokenRefsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required int occurredAt,
                required String summary,
                Value<String?> detailsJson = const Value.absent(),
                required String episodeType,
                Value<String?> tokenRefsJson = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MinkEpisodicMemoryCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                occurredAt: occurredAt,
                summary: summary,
                detailsJson: detailsJson,
                episodeType: episodeType,
                tokenRefsJson: tokenRefsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinkEpisodicMemoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable:
                                    $$MinkEpisodicMemoryTableReferences
                                        ._workspaceIdTable(db),
                                referencedColumn:
                                    $$MinkEpisodicMemoryTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable:
                                    $$MinkEpisodicMemoryTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$MinkEpisodicMemoryTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MinkEpisodicMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinkEpisodicMemoryTable,
      MinkEpisodicMemoryData,
      $$MinkEpisodicMemoryTableFilterComposer,
      $$MinkEpisodicMemoryTableOrderingComposer,
      $$MinkEpisodicMemoryTableAnnotationComposer,
      $$MinkEpisodicMemoryTableCreateCompanionBuilder,
      $$MinkEpisodicMemoryTableUpdateCompanionBuilder,
      (MinkEpisodicMemoryData, $$MinkEpisodicMemoryTableReferences),
      MinkEpisodicMemoryData,
      PrefetchHooks Function({bool workspaceId, bool projectId})
    >;
typedef $$MinkSemanticMemoryTableCreateCompanionBuilder =
    MinkSemanticMemoryCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required String entityType,
      Value<Uint8List?> canonicalFingerprint,
      Value<String?> descriptor,
      Value<String?> parentId,
      Value<int> occurrenceCount,
      required int firstSeenAt,
      required int lastSeenAt,
      Value<String?> embeddingId,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MinkSemanticMemoryTableUpdateCompanionBuilder =
    MinkSemanticMemoryCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String> entityType,
      Value<Uint8List?> canonicalFingerprint,
      Value<String?> descriptor,
      Value<String?> parentId,
      Value<int> occurrenceCount,
      Value<int> firstSeenAt,
      Value<int> lastSeenAt,
      Value<String?> embeddingId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$MinkSemanticMemoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinkSemanticMemoryTable,
          MinkSemanticMemoryData
        > {
  $$MinkSemanticMemoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(
          db.minkSemanticMemory.workspaceId,
          db.workspaces.id,
        ),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.minkSemanticMemory.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MinkSemanticMemoryTable _parentIdTable(_$AppDatabase db) =>
      db.minkSemanticMemory.createAlias(
        $_aliasNameGenerator(
          db.minkSemanticMemory.parentId,
          db.minkSemanticMemory.id,
        ),
      );

  $$MinkSemanticMemoryTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$MinkSemanticMemoryTableTableManager(
      $_db,
      $_db.minkSemanticMemory,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MinkSemanticRelationshipsTable,
    List<MinkSemanticRelationship>
  >
  _relationshipsFromTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.minkSemanticRelationships,
    aliasName: $_aliasNameGenerator(
      db.minkSemanticMemory.id,
      db.minkSemanticRelationships.fromEntityId,
    ),
  );

  $$MinkSemanticRelationshipsTableProcessedTableManager get relationshipsFrom {
    final manager = $$MinkSemanticRelationshipsTableTableManager(
      $_db,
      $_db.minkSemanticRelationships,
    ).filter((f) => f.fromEntityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_relationshipsFromTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MinkSemanticRelationshipsTable,
    List<MinkSemanticRelationship>
  >
  _relationshipsToTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.minkSemanticRelationships,
    aliasName: $_aliasNameGenerator(
      db.minkSemanticMemory.id,
      db.minkSemanticRelationships.toEntityId,
    ),
  );

  $$MinkSemanticRelationshipsTableProcessedTableManager get relationshipsTo {
    final manager = $$MinkSemanticRelationshipsTableTableManager(
      $_db,
      $_db.minkSemanticRelationships,
    ).filter((f) => f.toEntityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_relationshipsToTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MinkSemanticMemoryTableFilterComposer
    extends Composer<_$AppDatabase, $MinkSemanticMemoryTable> {
  $$MinkSemanticMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get canonicalFingerprint => $composableBuilder(
    column: $table.canonicalFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptor => $composableBuilder(
    column: $table.descriptor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embeddingId => $composableBuilder(
    column: $table.embeddingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableFilterComposer get parentId {
    final $$MinkSemanticMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> relationshipsFrom(
    Expression<bool> Function($$MinkSemanticRelationshipsTableFilterComposer f)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.fromEntityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableFilterComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> relationshipsTo(
    Expression<bool> Function($$MinkSemanticRelationshipsTableFilterComposer f)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.toEntityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableFilterComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MinkSemanticMemoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MinkSemanticMemoryTable> {
  $$MinkSemanticMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get canonicalFingerprint => $composableBuilder(
    column: $table.canonicalFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptor => $composableBuilder(
    column: $table.descriptor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embeddingId => $composableBuilder(
    column: $table.embeddingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableOrderingComposer get parentId {
    final $$MinkSemanticMemoryTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableOrderingComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkSemanticMemoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinkSemanticMemoryTable> {
  $$MinkSemanticMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get canonicalFingerprint => $composableBuilder(
    column: $table.canonicalFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptor => $composableBuilder(
    column: $table.descriptor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embeddingId => $composableBuilder(
    column: $table.embeddingId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableAnnotationComposer get parentId {
    final $$MinkSemanticMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.parentId,
          referencedTable: $db.minkSemanticMemory,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> relationshipsFrom<T extends Object>(
    Expression<T> Function($$MinkSemanticRelationshipsTableAnnotationComposer a)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.fromEntityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> relationshipsTo<T extends Object>(
    Expression<T> Function($$MinkSemanticRelationshipsTableAnnotationComposer a)
    f,
  ) {
    final $$MinkSemanticRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.minkSemanticRelationships,
          getReferencedColumn: (t) => t.toEntityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MinkSemanticMemoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinkSemanticMemoryTable,
          MinkSemanticMemoryData,
          $$MinkSemanticMemoryTableFilterComposer,
          $$MinkSemanticMemoryTableOrderingComposer,
          $$MinkSemanticMemoryTableAnnotationComposer,
          $$MinkSemanticMemoryTableCreateCompanionBuilder,
          $$MinkSemanticMemoryTableUpdateCompanionBuilder,
          (MinkSemanticMemoryData, $$MinkSemanticMemoryTableReferences),
          MinkSemanticMemoryData,
          PrefetchHooks Function({
            bool workspaceId,
            bool projectId,
            bool parentId,
            bool relationshipsFrom,
            bool relationshipsTo,
          })
        > {
  $$MinkSemanticMemoryTableTableManager(
    _$AppDatabase db,
    $MinkSemanticMemoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinkSemanticMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MinkSemanticMemoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MinkSemanticMemoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<Uint8List?> canonicalFingerprint = const Value.absent(),
                Value<String?> descriptor = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                Value<int> firstSeenAt = const Value.absent(),
                Value<int> lastSeenAt = const Value.absent(),
                Value<String?> embeddingId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinkSemanticMemoryCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                entityType: entityType,
                canonicalFingerprint: canonicalFingerprint,
                descriptor: descriptor,
                parentId: parentId,
                occurrenceCount: occurrenceCount,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                embeddingId: embeddingId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required String entityType,
                Value<Uint8List?> canonicalFingerprint = const Value.absent(),
                Value<String?> descriptor = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                required int firstSeenAt,
                required int lastSeenAt,
                Value<String?> embeddingId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MinkSemanticMemoryCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                entityType: entityType,
                canonicalFingerprint: canonicalFingerprint,
                descriptor: descriptor,
                parentId: parentId,
                occurrenceCount: occurrenceCount,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                embeddingId: embeddingId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinkSemanticMemoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                projectId = false,
                parentId = false,
                relationshipsFrom = false,
                relationshipsTo = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (relationshipsFrom) db.minkSemanticRelationships,
                    if (relationshipsTo) db.minkSemanticRelationships,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$MinkSemanticMemoryTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$MinkSemanticMemoryTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$MinkSemanticMemoryTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$MinkSemanticMemoryTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable:
                                        $$MinkSemanticMemoryTableReferences
                                            ._parentIdTable(db),
                                    referencedColumn:
                                        $$MinkSemanticMemoryTableReferences
                                            ._parentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (relationshipsFrom)
                        await $_getPrefetchedData<
                          MinkSemanticMemoryData,
                          $MinkSemanticMemoryTable,
                          MinkSemanticRelationship
                        >(
                          currentTable: table,
                          referencedTable: $$MinkSemanticMemoryTableReferences
                              ._relationshipsFromTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MinkSemanticMemoryTableReferences(
                                db,
                                table,
                                p0,
                              ).relationshipsFrom,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fromEntityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (relationshipsTo)
                        await $_getPrefetchedData<
                          MinkSemanticMemoryData,
                          $MinkSemanticMemoryTable,
                          MinkSemanticRelationship
                        >(
                          currentTable: table,
                          referencedTable: $$MinkSemanticMemoryTableReferences
                              ._relationshipsToTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MinkSemanticMemoryTableReferences(
                                db,
                                table,
                                p0,
                              ).relationshipsTo,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.toEntityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MinkSemanticMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinkSemanticMemoryTable,
      MinkSemanticMemoryData,
      $$MinkSemanticMemoryTableFilterComposer,
      $$MinkSemanticMemoryTableOrderingComposer,
      $$MinkSemanticMemoryTableAnnotationComposer,
      $$MinkSemanticMemoryTableCreateCompanionBuilder,
      $$MinkSemanticMemoryTableUpdateCompanionBuilder,
      (MinkSemanticMemoryData, $$MinkSemanticMemoryTableReferences),
      MinkSemanticMemoryData,
      PrefetchHooks Function({
        bool workspaceId,
        bool projectId,
        bool parentId,
        bool relationshipsFrom,
        bool relationshipsTo,
      })
    >;
typedef $$MinkSemanticRelationshipsTableCreateCompanionBuilder =
    MinkSemanticRelationshipsCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required String fromEntityId,
      required String toEntityId,
      required String predicate,
      required double confidence,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$MinkSemanticRelationshipsTableUpdateCompanionBuilder =
    MinkSemanticRelationshipsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String> fromEntityId,
      Value<String> toEntityId,
      Value<String> predicate,
      Value<double> confidence,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$MinkSemanticRelationshipsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinkSemanticRelationshipsTable,
          MinkSemanticRelationship
        > {
  $$MinkSemanticRelationshipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(
          db.minkSemanticRelationships.workspaceId,
          db.workspaces.id,
        ),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(
          db.minkSemanticRelationships.projectId,
          db.projects.id,
        ),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MinkSemanticMemoryTable _fromEntityIdTable(_$AppDatabase db) =>
      db.minkSemanticMemory.createAlias(
        $_aliasNameGenerator(
          db.minkSemanticRelationships.fromEntityId,
          db.minkSemanticMemory.id,
        ),
      );

  $$MinkSemanticMemoryTableProcessedTableManager get fromEntityId {
    final $_column = $_itemColumn<String>('from_entity_id')!;

    final manager = $$MinkSemanticMemoryTableTableManager(
      $_db,
      $_db.minkSemanticMemory,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromEntityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MinkSemanticMemoryTable _toEntityIdTable(_$AppDatabase db) =>
      db.minkSemanticMemory.createAlias(
        $_aliasNameGenerator(
          db.minkSemanticRelationships.toEntityId,
          db.minkSemanticMemory.id,
        ),
      );

  $$MinkSemanticMemoryTableProcessedTableManager get toEntityId {
    final $_column = $_itemColumn<String>('to_entity_id')!;

    final manager = $$MinkSemanticMemoryTableTableManager(
      $_db,
      $_db.minkSemanticMemory,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toEntityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinkSemanticRelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $MinkSemanticRelationshipsTable> {
  $$MinkSemanticRelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predicate => $composableBuilder(
    column: $table.predicate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableFilterComposer get fromEntityId {
    final $$MinkSemanticMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromEntityId,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableFilterComposer get toEntityId {
    final $$MinkSemanticMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toEntityId,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableFilterComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkSemanticRelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $MinkSemanticRelationshipsTable> {
  $$MinkSemanticRelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predicate => $composableBuilder(
    column: $table.predicate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableOrderingComposer get fromEntityId {
    final $$MinkSemanticMemoryTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromEntityId,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableOrderingComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableOrderingComposer get toEntityId {
    final $$MinkSemanticMemoryTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toEntityId,
      referencedTable: $db.minkSemanticMemory,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MinkSemanticMemoryTableOrderingComposer(
            $db: $db,
            $table: $db.minkSemanticMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkSemanticRelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinkSemanticRelationshipsTable> {
  $$MinkSemanticRelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get predicate =>
      $composableBuilder(column: $table.predicate, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MinkSemanticMemoryTableAnnotationComposer get fromEntityId {
    final $$MinkSemanticMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.fromEntityId,
          referencedTable: $db.minkSemanticMemory,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$MinkSemanticMemoryTableAnnotationComposer get toEntityId {
    final $$MinkSemanticMemoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.toEntityId,
          referencedTable: $db.minkSemanticMemory,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MinkSemanticMemoryTableAnnotationComposer(
                $db: $db,
                $table: $db.minkSemanticMemory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MinkSemanticRelationshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinkSemanticRelationshipsTable,
          MinkSemanticRelationship,
          $$MinkSemanticRelationshipsTableFilterComposer,
          $$MinkSemanticRelationshipsTableOrderingComposer,
          $$MinkSemanticRelationshipsTableAnnotationComposer,
          $$MinkSemanticRelationshipsTableCreateCompanionBuilder,
          $$MinkSemanticRelationshipsTableUpdateCompanionBuilder,
          (
            MinkSemanticRelationship,
            $$MinkSemanticRelationshipsTableReferences,
          ),
          MinkSemanticRelationship,
          PrefetchHooks Function({
            bool workspaceId,
            bool projectId,
            bool fromEntityId,
            bool toEntityId,
          })
        > {
  $$MinkSemanticRelationshipsTableTableManager(
    _$AppDatabase db,
    $MinkSemanticRelationshipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinkSemanticRelationshipsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MinkSemanticRelationshipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinkSemanticRelationshipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> fromEntityId = const Value.absent(),
                Value<String> toEntityId = const Value.absent(),
                Value<String> predicate = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinkSemanticRelationshipsCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                fromEntityId: fromEntityId,
                toEntityId: toEntityId,
                predicate: predicate,
                confidence: confidence,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required String fromEntityId,
                required String toEntityId,
                required String predicate,
                required double confidence,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MinkSemanticRelationshipsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                fromEntityId: fromEntityId,
                toEntityId: toEntityId,
                predicate: predicate,
                confidence: confidence,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinkSemanticRelationshipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceId = false,
                projectId = false,
                fromEntityId = false,
                toEntityId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workspaceId,
                                    referencedTable:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._workspaceIdTable(db),
                                    referencedColumn:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._workspaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (fromEntityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fromEntityId,
                                    referencedTable:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._fromEntityIdTable(db),
                                    referencedColumn:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._fromEntityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (toEntityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toEntityId,
                                    referencedTable:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._toEntityIdTable(db),
                                    referencedColumn:
                                        $$MinkSemanticRelationshipsTableReferences
                                            ._toEntityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MinkSemanticRelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinkSemanticRelationshipsTable,
      MinkSemanticRelationship,
      $$MinkSemanticRelationshipsTableFilterComposer,
      $$MinkSemanticRelationshipsTableOrderingComposer,
      $$MinkSemanticRelationshipsTableAnnotationComposer,
      $$MinkSemanticRelationshipsTableCreateCompanionBuilder,
      $$MinkSemanticRelationshipsTableUpdateCompanionBuilder,
      (MinkSemanticRelationship, $$MinkSemanticRelationshipsTableReferences),
      MinkSemanticRelationship,
      PrefetchHooks Function({
        bool workspaceId,
        bool projectId,
        bool fromEntityId,
        bool toEntityId,
      })
    >;
typedef $$MinkProceduralMemoryTableCreateCompanionBuilder =
    MinkProceduralMemoryCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> projectId,
      required String triggerPatternJson,
      required String actionPatternJson,
      Value<int> observedCount,
      required double confidence,
      required int lastObservedAt,
      Value<int> userConfirmed,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MinkProceduralMemoryTableUpdateCompanionBuilder =
    MinkProceduralMemoryCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String> triggerPatternJson,
      Value<String> actionPatternJson,
      Value<int> observedCount,
      Value<double> confidence,
      Value<int> lastObservedAt,
      Value<int> userConfirmed,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$MinkProceduralMemoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MinkProceduralMemoryTable,
          MinkProceduralMemoryData
        > {
  $$MinkProceduralMemoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
        $_aliasNameGenerator(
          db.minkProceduralMemory.workspaceId,
          db.workspaces.id,
        ),
      );

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.minkProceduralMemory.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MinkProceduralMemoryTableFilterComposer
    extends Composer<_$AppDatabase, $MinkProceduralMemoryTable> {
  $$MinkProceduralMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerPatternJson => $composableBuilder(
    column: $table.triggerPatternJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionPatternJson => $composableBuilder(
    column: $table.actionPatternJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get observedCount => $composableBuilder(
    column: $table.observedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastObservedAt => $composableBuilder(
    column: $table.lastObservedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkProceduralMemoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MinkProceduralMemoryTable> {
  $$MinkProceduralMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerPatternJson => $composableBuilder(
    column: $table.triggerPatternJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionPatternJson => $composableBuilder(
    column: $table.actionPatternJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get observedCount => $composableBuilder(
    column: $table.observedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastObservedAt => $composableBuilder(
    column: $table.lastObservedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkProceduralMemoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MinkProceduralMemoryTable> {
  $$MinkProceduralMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get triggerPatternJson => $composableBuilder(
    column: $table.triggerPatternJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionPatternJson => $composableBuilder(
    column: $table.actionPatternJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get observedCount => $composableBuilder(
    column: $table.observedCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastObservedAt => $composableBuilder(
    column: $table.lastObservedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MinkProceduralMemoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MinkProceduralMemoryTable,
          MinkProceduralMemoryData,
          $$MinkProceduralMemoryTableFilterComposer,
          $$MinkProceduralMemoryTableOrderingComposer,
          $$MinkProceduralMemoryTableAnnotationComposer,
          $$MinkProceduralMemoryTableCreateCompanionBuilder,
          $$MinkProceduralMemoryTableUpdateCompanionBuilder,
          (MinkProceduralMemoryData, $$MinkProceduralMemoryTableReferences),
          MinkProceduralMemoryData,
          PrefetchHooks Function({bool workspaceId, bool projectId})
        > {
  $$MinkProceduralMemoryTableTableManager(
    _$AppDatabase db,
    $MinkProceduralMemoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MinkProceduralMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MinkProceduralMemoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MinkProceduralMemoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> triggerPatternJson = const Value.absent(),
                Value<String> actionPatternJson = const Value.absent(),
                Value<int> observedCount = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> lastObservedAt = const Value.absent(),
                Value<int> userConfirmed = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MinkProceduralMemoryCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                triggerPatternJson: triggerPatternJson,
                actionPatternJson: actionPatternJson,
                observedCount: observedCount,
                confidence: confidence,
                lastObservedAt: lastObservedAt,
                userConfirmed: userConfirmed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> projectId = const Value.absent(),
                required String triggerPatternJson,
                required String actionPatternJson,
                Value<int> observedCount = const Value.absent(),
                required double confidence,
                required int lastObservedAt,
                Value<int> userConfirmed = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MinkProceduralMemoryCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                triggerPatternJson: triggerPatternJson,
                actionPatternJson: actionPatternJson,
                observedCount: observedCount,
                confidence: confidence,
                lastObservedAt: lastObservedAt,
                userConfirmed: userConfirmed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MinkProceduralMemoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable:
                                    $$MinkProceduralMemoryTableReferences
                                        ._workspaceIdTable(db),
                                referencedColumn:
                                    $$MinkProceduralMemoryTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable:
                                    $$MinkProceduralMemoryTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$MinkProceduralMemoryTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MinkProceduralMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MinkProceduralMemoryTable,
      MinkProceduralMemoryData,
      $$MinkProceduralMemoryTableFilterComposer,
      $$MinkProceduralMemoryTableOrderingComposer,
      $$MinkProceduralMemoryTableAnnotationComposer,
      $$MinkProceduralMemoryTableCreateCompanionBuilder,
      $$MinkProceduralMemoryTableUpdateCompanionBuilder,
      (MinkProceduralMemoryData, $$MinkProceduralMemoryTableReferences),
      MinkProceduralMemoryData,
      PrefetchHooks Function({bool workspaceId, bool projectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$EntitiesTableTableManager get entities =>
      $$EntitiesTableTableManager(_db, _db.entities);
  $$TokensTableTableManager get tokens =>
      $$TokensTableTableManager(_db, _db.tokens);
  $$CustomEntityTypesTableTableManager get customEntityTypes =>
      $$CustomEntityTypesTableTableManager(_db, _db.customEntityTypes);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$VaultMetaTableTableManager get vaultMeta =>
      $$VaultMetaTableTableManager(_db, _db.vaultMeta);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$MinkCoreMemoryTableTableManager get minkCoreMemory =>
      $$MinkCoreMemoryTableTableManager(_db, _db.minkCoreMemory);
  $$MinkEpisodicMemoryTableTableManager get minkEpisodicMemory =>
      $$MinkEpisodicMemoryTableTableManager(_db, _db.minkEpisodicMemory);
  $$MinkSemanticMemoryTableTableManager get minkSemanticMemory =>
      $$MinkSemanticMemoryTableTableManager(_db, _db.minkSemanticMemory);
  $$MinkSemanticRelationshipsTableTableManager get minkSemanticRelationships =>
      $$MinkSemanticRelationshipsTableTableManager(
        _db,
        _db.minkSemanticRelationships,
      );
  $$MinkProceduralMemoryTableTableManager get minkProceduralMemory =>
      $$MinkProceduralMemoryTableTableManager(_db, _db.minkProceduralMemory);
}
