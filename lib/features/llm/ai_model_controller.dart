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
import 'tier_catalog.dart';

/// Drives the user-facing Tier-4 model controls (Phase 11a / roadmap §11):
/// enable the recommended model, switch Balanced↔Specialized, override the tier,
/// re-check the device, and remove the downloaded model. Every change persists
/// the [ProfilerState] and writes the matching **no-silent-swap** audit row
/// (architecture-invariants #2). PII-safe: audit metadata carries only ids,
/// versions, scores, and sizes — never document content.
///
/// Pure-Dart with constructor-injected deps (mirrors [LlmRuntimeCoordinator]) so
/// the whole flow is fake-tested; the real download + `flutter_gemma` backend +
/// audit DB are wired in [aiModelControllerProvider].
class AiModelController {
  AiModelController({
    required Future<ModelManifest> Function() loadManifest,
    required Future<ProfilerState?> Function() loadState,
    required Future<void> Function(ProfilerState) saveState,
    required Future<ProfilerState> Function(ModelManifest manifest)
    recheckProfile,
    required Future<LlmBackend> Function(
      ModelVariant variant, {
      void Function(double progress)? onProgress,
    })
    activate,
    required void Function(LlmBackend) setActiveBackend,
    required void Function() clearActiveBackend,
    required ModelStore modelStore,
    required Future<void> Function(
      String eventType,
      Map<String, dynamic> metadata,
    )
    recordAudit,
  }) : _loadManifest = loadManifest,
       _loadState = loadState,
       _saveState = saveState,
       _recheckProfile = recheckProfile,
       _activate = activate,
       _setActiveBackend = setActiveBackend,
       _clearActiveBackend = clearActiveBackend,
       _modelStore = modelStore,
       _recordAudit = recordAudit;

  final Future<ModelManifest> Function() _loadManifest;
  final Future<ProfilerState?> Function() _loadState;
  final Future<void> Function(ProfilerState) _saveState;
  final Future<ProfilerState> Function(ModelManifest) _recheckProfile;
  final Future<LlmBackend> Function(
    ModelVariant variant, {
    void Function(double progress)? onProgress,
  })
  _activate;
  final void Function(LlmBackend) _setActiveBackend;
  final void Function() _clearActiveBackend;
  final ModelStore _modelStore;
  final Future<void> Function(String, Map<String, dynamic>) _recordAudit;

  /// Re-run the device profiler. Preserves a `ready` download when the
  /// recommendation (and its model file) is unchanged — a re-check must not
  /// silently drop an already-installed model. Audits tier/variant changes.
  Future<ProfilerState> recheck() async {
    final manifest = await _loadManifest();
    final previous = await _loadState();
    var next = await _recheckProfile(manifest); // collects + selects + persists

    // ProfilerService resets downloadState→notDownloaded on every run. If the
    // pick is identical and the file is still on disk, keep the ready state.
    if (previous != null &&
        previous.downloadState == DownloadState.ready &&
        previous.modelId != null &&
        previous.modelId == next.modelId &&
        await _modelStore.fileFor(previous.modelId!).exists()) {
      next = next.copyWith(downloadState: DownloadState.ready);
      await _saveState(next);
    }

    await _auditSelectionChange(previous, next);
    return next;
  }

  /// Download + load the recommended (currently selected) tier/variant.
  Future<ProfilerState> enableRecommended({
    void Function(double progress)? onProgress,
  }) async {
    final state = await _loadState();
    if (state == null || state.isFloor || state.modelId == null) {
      throw StateError('No recommended tier to enable on this device.');
    }
    final manifest = await _loadManifest();
    final variant = LlmRuntimeCoordinator.variantIn(
      manifest,
      state.tier,
      state.variant,
    );
    if (variant == null) {
      throw StateError('Selected variant is not in the manifest.');
    }
    return _installAndActivate(
      state,
      variant,
      manifest,
      onProgress: onProgress,
    );
  }

  /// Switch between Balanced and Specialized within the current tier (downloads
  /// the variant's model if not already present). Audits the variant change.
  Future<ProfilerState> switchVariant(
    VariantKind kind, {
    void Function(double progress)? onProgress,
  }) async {
    final state = await _loadState();
    if (state == null || state.isFloor) {
      throw StateError('No tier selected for a variant switch.');
    }
    if (kind == state.variant) return state;
    final manifest = await _loadManifest();
    final variant = LlmRuntimeCoordinator.variantIn(manifest, state.tier, kind);
    if (variant == null) {
      throw StateError('Variant $kind is not offered for tier ${state.tier}.');
    }
    await _recordAudit(AuditEventType.variantChange, {
      'tier': state.tier,
      'from': state.variant.id,
      'to': kind.id,
    });
    final selected = state.copyWith(variant: kind, modelId: variant.modelId);
    return _installAndActivate(
      selected,
      variant,
      manifest,
      onProgress: onProgress,
    );
  }

  /// Override the recommended tier (UI restricts to qualifying tiers). Downloads
  /// the new tier's model for the current variant kind. Audits the tier change.
  Future<ProfilerState> overrideTier(
    String tier, {
    void Function(double progress)? onProgress,
  }) async {
    final state = await _loadState();
    if (state == null) {
      throw StateError('Run the profiler before overriding the tier.');
    }
    if (tier == state.tier) return state;
    final manifest = await _loadManifest();
    final variant =
        LlmRuntimeCoordinator.variantIn(manifest, tier, state.variant) ??
        LlmRuntimeCoordinator.variantIn(manifest, tier, VariantKind.balanced);
    if (variant == null) {
      throw StateError('Tier $tier is not in the manifest.');
    }
    await _recordAudit(AuditEventType.tierChange, {
      'from': state.tier,
      'to': tier,
      'score': state.score,
    });
    final kind =
        manifest.catalog.tiers
            .firstWhere((t) => t.tier == tier)
            .variants
            .containsKey(state.variant)
        ? state.variant
        : VariantKind.balanced;
    final selected = state.copyWith(
      tier: tier,
      variant: kind,
      modelId: variant.modelId,
      floorReason: null,
    );
    return _installAndActivate(
      selected,
      variant,
      manifest,
      onProgress: onProgress,
    );
  }

  /// Delete the downloaded model file, disable the engine, and mark the state
  /// not-downloaded. Audits the uninstall.
  Future<ProfilerState> removeModel() async {
    final state = await _loadState();
    if (state == null || state.modelId == null) {
      throw StateError('No downloaded model to remove.');
    }
    final file = _modelStore.fileFor(state.modelId!);
    if (await file.exists()) await file.delete();
    _clearActiveBackend();
    final next = state.copyWith(downloadState: DownloadState.notDownloaded);
    await _saveState(next);
    await _recordAudit(AuditEventType.modelUninstall, {
      'modelId': state.modelId,
    });
    return next;
  }

  /// Shared install path: download+verify+load the [variant], set the active
  /// backend, persist `ready`, and audit the install.
  Future<ProfilerState> _installAndActivate(
    ProfilerState selected,
    ModelVariant variant,
    ModelManifest manifest, {
    void Function(double progress)? onProgress,
  }) async {
    final backend = await _activate(variant, onProgress: onProgress);
    _setActiveBackend(backend);
    final next = selected.copyWith(downloadState: DownloadState.ready);
    await _saveState(next);
    await _recordAudit(AuditEventType.modelInstall, {
      'modelId': variant.modelId,
      'version': manifest.version,
      'sizeBytes': variant.sizeBytes,
    });
    return next;
  }

  Future<void> _auditSelectionChange(
    ProfilerState? previous,
    ProfilerState next,
  ) async {
    if (previous == null) return;
    if (previous.tier != next.tier) {
      await _recordAudit(AuditEventType.tierChange, {
        'from': previous.tier,
        'to': next.tier,
        'score': next.score,
      });
    }
    if (previous.variant != next.variant) {
      await _recordAudit(AuditEventType.variantChange, {
        'tier': next.tier,
        'from': previous.variant.id,
        'to': next.variant.id,
      });
    }
  }
}

/// [AiModelController] wired to the real profiler, download pipeline, active
/// backend, model store, and audit log (all require the unlocked vault).
final aiModelControllerProvider = Provider<AiModelController>((ref) {
  final coordinator = ref.watch(llmRuntimeCoordinatorProvider);
  final newId = defaultIdGenerator;
  return AiModelController(
    loadManifest: () => ref.read(modelManifestProvider.future),
    loadState: () => ref.read(profilerRepositoryProvider).load(),
    saveState: (s) => ref.read(profilerRepositoryProvider).save(s),
    recheckProfile: (manifest) =>
        ref.read(profilerServiceProvider).recheck(manifest),
    activate: coordinator.activateVariant,
    setActiveBackend: ref.read(activeLlmBackendProvider.notifier).set,
    clearActiveBackend: ref.read(activeLlmBackendProvider.notifier).clear,
    modelStore: ref.watch(modelStoreProvider),
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
