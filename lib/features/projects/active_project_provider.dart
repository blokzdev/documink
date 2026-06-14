import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/settings_store.dart';

/// The currently selected Project id, or `null` for the workspace-global view
/// (all documents, workspace-global custom entities). Project-scoped reads watch
/// this to filter by the active Project (blueprint §6.7 isolation).
///
/// Persisted via [settingsStoreProvider] (the `themeMode` precedent): a Project
/// id is non-PII UI state, must survive restart, and is read before the vault is
/// unlocked — so it belongs in the settings store, not the encrypted vault.
class ActiveProjectNotifier extends Notifier<String?> {
  static const settingsKey = 'active_project_id';

  @override
  String? build() {
    final stored = ref.read(settingsStoreProvider).getString(settingsKey);
    return (stored == null || stored.isEmpty) ? null : stored;
  }

  /// Selects a Project (or clears the selection when [projectId] is null).
  void set(String? projectId) {
    state = projectId;
    // Empty string is the "no active project" sentinel in the string store.
    ref.read(settingsStoreProvider).setString(settingsKey, projectId ?? '');
  }

  /// Returns to the workspace-global view.
  void clear() => set(null);
}

final activeProjectProvider = NotifierProvider<ActiveProjectNotifier, String?>(
  ActiveProjectNotifier.new,
);
