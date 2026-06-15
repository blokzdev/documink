import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/id_generator.dart';
import '../audit/audit_event_type.dart';
import '../audit/audit_providers.dart';
import '../documents/document_repository.dart';
import 'llm_backend.dart';
import 'llm_providers.dart';
import 'llm_runtime_coordinator.dart';
import 'model_manifest.dart';
import 'model_store.dart';
import 'profiler_state.dart';

/// Restores the Tier-4 engine on vault unlock (Phase 11a). Activation is
/// otherwise in-memory ([ActiveLlmBackend]) and would reset every launch; this
/// rebuilds the backend from the persisted [ProfilerState] + on-disk model so a
/// `ready` model stays enabled across restarts. Also detects a model-manifest
/// **version bump** vs. the persisted state and audits it once (the before/after
/// user prompt lands in 11b).
///
/// Pure-Dart with injected deps so it's fake-tested; wired in
/// [aiActivationServiceProvider] and invoked from bootstrap's unlock listener.
class AiActivationService {
  AiActivationService({
    required Future<ProfilerState?> Function() loadState,
    required Future<void> Function(ProfilerState) saveState,
    required Future<ModelManifest> Function() loadManifest,
    required ModelStore modelStore,
    required LlmBackend Function(String modelPath) backendFactory,
    required void Function(LlmBackend) setActiveBackend,
    required Future<void> Function(
      String eventType,
      Map<String, dynamic> metadata,
    )
    recordAudit,
  }) : _loadState = loadState,
       _saveState = saveState,
       _loadManifest = loadManifest,
       _modelStore = modelStore,
       _backendFactory = backendFactory,
       _setActiveBackend = setActiveBackend,
       _recordAudit = recordAudit;

  final Future<ProfilerState?> Function() _loadState;
  final Future<void> Function(ProfilerState) _saveState;
  final Future<ModelManifest> Function() _loadManifest;
  final ModelStore _modelStore;
  final LlmBackend Function(String) _backendFactory;
  final void Function(LlmBackend) _setActiveBackend;
  final Future<void> Function(String, Map<String, dynamic>) _recordAudit;

  /// Best-effort: never throws (a failed restore just leaves the engine
  /// `Unavailable`, which degrades gracefully).
  Future<void> restoreOnUnlock() async {
    try {
      await _restore();
    } catch (_) {
      // Swallow — the engine stays UnavailableLlmBackend (graceful).
    }
  }

  Future<void> _restore() async {
    var state = await _loadState();
    if (state == null) return;

    final manifest = await _loadManifest();

    // No-silent-swap: a newer manifest than the one the model was selected
    // against is audited once, then the recorded version is advanced so it does
    // not re-fire every unlock. (11b adds the before/after confirmation prompt.)
    if (state.manifestVersion < manifest.version) {
      await _recordAudit(AuditEventType.manifestUpdate, {
        'from': state.manifestVersion,
        'to': manifest.version,
      });
      state = state.copyWith(manifestVersion: manifest.version);
      await _saveState(state);
    }

    if (state.downloadState != DownloadState.ready ||
        state.isFloor ||
        state.modelId == null) {
      return;
    }
    final variant = LlmRuntimeCoordinator.variantIn(
      manifest,
      state.tier,
      state.variant,
    );
    if (variant == null) return;

    final file = _modelStore.fileFor(state.modelId!);
    if (!await file.exists()) {
      // The model is gone (cleared by the OS or a sideload) — record reality so
      // the UI offers re-download instead of a broken "ready".
      await _saveState(
        state.copyWith(downloadState: DownloadState.notDownloaded),
      );
      return;
    }
    _setActiveBackend(_backendFactory(file.path));
  }
}

/// [AiActivationService] wired to the persisted profiler state, verified
/// manifest, model store, `flutter_gemma` backend factory, and audit log.
final aiActivationServiceProvider = Provider<AiActivationService>((ref) {
  final coordinator = ref.watch(llmRuntimeCoordinatorProvider);
  final newId = defaultIdGenerator;
  return AiActivationService(
    loadState: () => ref.read(profilerRepositoryProvider).load(),
    saveState: (s) => ref.read(profilerRepositoryProvider).save(s),
    loadManifest: () => ref.read(modelManifestProvider.future),
    modelStore: ref.watch(modelStoreProvider),
    backendFactory: coordinator.backendFactory,
    setActiveBackend: ref.read(activeLlmBackendProvider.notifier).set,
    recordAudit: (eventType, metadata) => ref
        .read(auditLogRepositoryProvider)
        .record(
          id: newId(),
          workspaceId: DocumentRepository.defaultWorkspaceId,
          eventType: eventType,
          success: true,
          metadata: metadata,
          nowEpochMs: DateTime.now().millisecondsSinceEpoch,
        ),
  );
});
