// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSchemaVersionTable extends AppSchemaVersion
    with TableInfo<$AppSchemaVersionTable, AppSchemaVersionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSchemaVersionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_schema_version';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSchemaVersionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSchemaVersionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSchemaVersionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $AppSchemaVersionTable createAlias(String alias) {
    return $AppSchemaVersionTable(attachedDatabase, alias);
  }
}

class AppSchemaVersionData extends DataClass
    implements Insertable<AppSchemaVersionData> {
  final int id;
  final int version;
  const AppSchemaVersionData({required this.id, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version'] = Variable<int>(version);
    return map;
  }

  AppSchemaVersionCompanion toCompanion(bool nullToAbsent) {
    return AppSchemaVersionCompanion(id: Value(id), version: Value(version));
  }

  factory AppSchemaVersionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSchemaVersionData(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<int>(version),
    };
  }

  AppSchemaVersionData copyWith({int? id, int? version}) =>
      AppSchemaVersionData(id: id ?? this.id, version: version ?? this.version);
  AppSchemaVersionData copyWithCompanion(AppSchemaVersionCompanion data) {
    return AppSchemaVersionData(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSchemaVersionData(')
          ..write('id: $id, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSchemaVersionData &&
          other.id == this.id &&
          other.version == this.version);
}

class AppSchemaVersionCompanion extends UpdateCompanion<AppSchemaVersionData> {
  final Value<int> id;
  final Value<int> version;
  const AppSchemaVersionCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
  });
  AppSchemaVersionCompanion.insert({
    this.id = const Value.absent(),
    required int version,
  }) : version = Value(version);
  static Insertable<AppSchemaVersionData> custom({
    Expression<int>? id,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
    });
  }

  AppSchemaVersionCompanion copyWith({Value<int>? id, Value<int>? version}) {
    return AppSchemaVersionCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSchemaVersionCompanion(')
          ..write('id: $id, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSchemaVersionTable appSchemaVersion = $AppSchemaVersionTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [appSchemaVersion];
}

typedef $$AppSchemaVersionTableCreateCompanionBuilder =
    AppSchemaVersionCompanion Function({Value<int> id, required int version});
typedef $$AppSchemaVersionTableUpdateCompanionBuilder =
    AppSchemaVersionCompanion Function({Value<int> id, Value<int> version});

class $$AppSchemaVersionTableFilterComposer
    extends Composer<_$AppDatabase, $AppSchemaVersionTable> {
  $$AppSchemaVersionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSchemaVersionTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSchemaVersionTable> {
  $$AppSchemaVersionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSchemaVersionTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSchemaVersionTable> {
  $$AppSchemaVersionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$AppSchemaVersionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSchemaVersionTable,
          AppSchemaVersionData,
          $$AppSchemaVersionTableFilterComposer,
          $$AppSchemaVersionTableOrderingComposer,
          $$AppSchemaVersionTableAnnotationComposer,
          $$AppSchemaVersionTableCreateCompanionBuilder,
          $$AppSchemaVersionTableUpdateCompanionBuilder,
          (
            AppSchemaVersionData,
            BaseReferences<
              _$AppDatabase,
              $AppSchemaVersionTable,
              AppSchemaVersionData
            >,
          ),
          AppSchemaVersionData,
          PrefetchHooks Function()
        > {
  $$AppSchemaVersionTableTableManager(
    _$AppDatabase db,
    $AppSchemaVersionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSchemaVersionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSchemaVersionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSchemaVersionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> version = const Value.absent(),
              }) => AppSchemaVersionCompanion(id: id, version: version),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required int version}) =>
                  AppSchemaVersionCompanion.insert(id: id, version: version),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSchemaVersionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSchemaVersionTable,
      AppSchemaVersionData,
      $$AppSchemaVersionTableFilterComposer,
      $$AppSchemaVersionTableOrderingComposer,
      $$AppSchemaVersionTableAnnotationComposer,
      $$AppSchemaVersionTableCreateCompanionBuilder,
      $$AppSchemaVersionTableUpdateCompanionBuilder,
      (
        AppSchemaVersionData,
        BaseReferences<
          _$AppDatabase,
          $AppSchemaVersionTable,
          AppSchemaVersionData
        >,
      ),
      AppSchemaVersionData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSchemaVersionTableTableManager get appSchemaVersion =>
      $$AppSchemaVersionTableTableManager(_db, _db.appSchemaVersion);
}
