import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The currently selected Project id, or `null` for the workspace-global view
/// (all documents, workspace-global custom entities). Project-scoped reads watch
/// this to filter by the active Project (blueprint §6.7 isolation).
///
/// In-memory for Phase 14a — there is no Project-selection UI yet; the selector
/// and restart-durable persistence land with the Project list/detail UI (14c).
class ActiveProjectNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Selects a Project (or clears the selection when [projectId] is null).
  void set(String? projectId) => state = projectId;

  /// Returns to the workspace-global view.
  void clear() => state = null;
}

final activeProjectProvider = NotifierProvider<ActiveProjectNotifier, String?>(
  ActiveProjectNotifier.new,
);
