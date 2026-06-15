import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../documents/document_repository.dart';
import '../projects/active_project_provider.dart';
import 'memory_providers.dart';
import 'memory_repository.dart';

/// A snapshot of the memory Mink can see in the active scope, split into the
/// active Project's entries and workspace-global entries (memory.md §8.1 — the
/// user-facing memory inspector). Core + Episodic are the V1-active types.
class MinkMemoryView {
  const MinkMemoryView({
    required this.core,
    required this.episodic,
    this.activeProjectId,
  });

  final List<CoreMemoryEntry> core;
  final List<EpisodicEntry> episodic;
  final String? activeProjectId;

  List<CoreMemoryEntry> get globalCore =>
      core.where((e) => e.projectId == null).toList();
  List<CoreMemoryEntry> get projectCore =>
      core.where((e) => e.projectId != null).toList();
  List<EpisodicEntry> get globalEpisodic =>
      episodic.where((e) => e.projectId == null).toList();
  List<EpisodicEntry> get projectEpisodic =>
      episodic.where((e) => e.projectId != null).toList();

  bool get isEmpty => core.isEmpty && episodic.isEmpty;
}

/// The memory inspector view for the active scope (globals + active Project).
final minkMemoryViewProvider = FutureProvider.autoDispose<MinkMemoryView>((
  ref,
) async {
  final repo = ref.watch(memoryRepositoryProvider);
  final projectId = ref.watch(activeProjectProvider);
  const workspaceId = DocumentRepository.defaultWorkspaceId;
  final core = await repo.recallCore(workspaceId, projectId: projectId);
  final episodic = await repo.recallEpisodic(workspaceId, projectId: projectId);
  return MinkMemoryView(
    core: core,
    episodic: episodic,
    activeProjectId: projectId,
  );
});

/// Human-readable provenance label (memory.md §8.1).
String memoryProvenanceLabel(String provenance) => switch (provenance) {
  'user' => 'You told me',
  'observed' => 'Observed from an action',
  _ => 'Inferred from conversation',
};

/// Memory edit/delete/export actions for the inspector. Deletes go through the
/// repository (the same path `forget` uses); the write guard already protects
/// the write side, so no PII can be (re)introduced here.
class MinkMemoryActions {
  MinkMemoryActions(this._repo);

  final MemoryRepository _repo;

  Future<void> forgetCore(String id) => _repo.forgetCore(id);
  Future<void> forgetEpisodic(String id) => _repo.forgetEpisodic(id);

  /// Deletes every entry whose key/value/summary contains [topic]
  /// (case-insensitive) in the given view. Returns how many were removed.
  /// V1 uses literal matching (no embeddings — ADR-018); semantic "forget
  /// everything about X" arrives with Resource memory in V1.2.
  Future<int> forgetAbout(String topic, MinkMemoryView view) async {
    final needle = topic.trim().toLowerCase();
    if (needle.isEmpty) return 0;
    var removed = 0;
    for (final c in view.core) {
      if ('${c.key} ${c.value}'.toLowerCase().contains(needle)) {
        await _repo.forgetCore(c.id);
        removed++;
      }
    }
    for (final e in view.episodic) {
      if (e.summary.toLowerCase().contains(needle)) {
        await _repo.forgetEpisodic(e.id);
        removed++;
      }
    }
    return removed;
  }

  /// All in-scope memory as a stable, pretty-printable structure (no raw PII —
  /// values already carry token references, never plaintext).
  Map<String, dynamic> exportJson(MinkMemoryView view) => {
    'core': [
      for (final c in view.core)
        {
          'id': c.id,
          'key': c.key,
          'value': c.value,
          'provenance': c.provenance,
          'project_id': c.projectId,
        },
    ],
    'episodic': [
      for (final e in view.episodic)
        {
          'id': e.id,
          'occurred_at': e.occurredAt,
          'summary': e.summary,
          'episode_type': e.episodeType,
          'project_id': e.projectId,
        },
    ],
  };
}

final minkMemoryActionsProvider = Provider<MinkMemoryActions>(
  (ref) => MinkMemoryActions(ref.watch(memoryRepositoryProvider)),
);
