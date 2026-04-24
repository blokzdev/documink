import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

class AppSchemaVersion extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get version => integer()();
}

@DriftDatabase(tables: [AppSchemaVersion])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}
