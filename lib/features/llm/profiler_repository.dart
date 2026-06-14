import 'dart:convert';
import 'dart:typed_data';

import '../../data/app_database.dart';
import 'profiler_state.dart';

/// Persists the [ProfilerState] to `vault_meta` as a single JSON blob (blueprint
/// §4.7). The spec lists several `llm_*` fields; we store them as one atomic
/// document under a namespaced key rather than one row each (logged in
/// DECISIONS). Requires the unlocked vault DB.
class ProfilerRepository {
  ProfilerRepository(this._db);

  final AppDatabase _db;

  static const String metaKey = 'llm:profiler_state';

  Future<void> save(ProfilerState state) async {
    final blob = Uint8List.fromList(utf8.encode(jsonEncode(state.toJson())));
    await _db
        .into(_db.vaultMeta)
        .insertOnConflictUpdate(
          VaultMetaCompanion.insert(key: metaKey, value: blob),
        );
  }

  Future<ProfilerState?> load() async {
    final row = await (_db.select(
      _db.vaultMeta,
    )..where((t) => t.key.equals(metaKey))).getSingleOrNull();
    if (row == null) return null;
    final json = jsonDecode(utf8.decode(row.value)) as Map<String, dynamic>;
    return ProfilerState.fromJson(json);
  }
}
