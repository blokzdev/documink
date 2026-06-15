import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../services/database_providers.dart';
import '../documents/document_repository.dart';
import '../llm/llm_backend.dart';
import '../llm/llm_providers.dart';
import '../llm/device_capability_profiler.dart' show noTier;
import '../mink/mink_providers.dart';
import '../projects/active_project_provider.dart';
import '../projects/project_manifest.dart';
import '../projects/project_providers.dart';
import 'chat_repository.dart';

/// Chat session + message persistence (requires the unlocked vault).
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(appDatabaseProvider)),
);

/// Sessions in the active scope (project, or global), most-recently-active first.
final chatSessionsProvider = FutureProvider.autoDispose<List<ChatSession>>(
  (ref) => ref
      .watch(chatRepositoryProvider)
      .listSessions(projectId: ref.watch(activeProjectProvider)),
);

/// Messages of one session, transcript order. Invalidated after each turn.
final chatMessagesProvider = FutureProvider.autoDispose
    .family<List<ChatMessage>, String>(
      (ref, sessionId) =>
          ref.watch(chatRepositoryProvider).messagesForSession(sessionId),
    );

/// The default permissions for a no-project (global) chat: read + summarize
/// granted, everything privacy-sensitive denied (deny-by-default). Memory tools
/// are always available regardless (router-gated). Logged in docs/DECISIONS.md.
final ProjectPermissions _globalChatPermissions = ProjectPermissions.fromJson(
  const {'read_documents': true},
);

/// Everything a Mink turn needs that the chat UI must resolve: scope, the
/// permissions to gate tools against, the active tier/model, and whether the
/// on-device model is actually usable right now.
class MinkTurnContext {
  const MinkTurnContext({
    required this.workspaceId,
    this.projectId,
    required this.permissions,
    required this.tier,
    required this.variantId,
    required this.modelId,
    required this.available,
    this.unavailableReason,
  });

  final String workspaceId;
  final String? projectId;
  final ProjectPermissions permissions;
  final String tier;
  final String variantId;
  final String modelId;
  final bool available;
  final String? unavailableReason;
}

/// Resolves the [MinkTurnContext] from the profiler state, the active Project's
/// manifest (permissions/persona), and the live [LlmBackend] availability.
final minkTurnContextProvider = FutureProvider.autoDispose<MinkTurnContext>((
  ref,
) async {
  final state = await ref.watch(profilerStateProvider.future);
  final projectId = ref.watch(activeProjectProvider);

  ProjectPermissions permissions = _globalChatPermissions;
  if (projectId != null) {
    final project = await ref.watch(projectByIdProvider(projectId).future);
    if (project != null) {
      permissions = ProjectManifest.parse(project.manifestJson).permissions;
    }
  }

  final llmReady = await ref.watch(llmBackendProvider).isAvailable();
  final belowFloor = state?.isFloor ?? false;
  final available = llmReady && !belowFloor;

  return MinkTurnContext(
    workspaceId: DocumentRepository.defaultWorkspaceId,
    projectId: projectId,
    permissions: permissions,
    tier: state?.tier ?? noTier,
    variantId: state?.variant.id ?? 'balanced',
    modelId: state?.modelId ?? 'none',
    available: available,
    unavailableReason: belowFloor
        ? 'This device is below the Mink AI floor.'
        : (!llmReady
              ? 'On-device AI is not enabled. Turn it on in Settings → AI Model.'
              : null),
  );
});

/// The transient send state for one chat thread (in-flight + last error),
/// separate from the persisted message list so the transcript stays visible.
class ChatSendState {
  const ChatSendState({this.sending = false, this.error});

  final bool sending;
  final String? error;
}

/// Drives one user turn: resolves the [MinkTurnContext], invokes [MinkService],
/// and refreshes the thread. Surfaces unavailability/errors as a banner rather
/// than throwing (the user message is still persisted by the service).
class ChatSend extends AutoDisposeFamilyNotifier<ChatSendState, String> {
  @override
  ChatSendState build(String sessionId) => const ChatSendState();

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;
    state = const ChatSendState(sending: true);

    final ctx = await ref.read(minkTurnContextProvider.future);
    if (!ctx.available) {
      state = ChatSendState(
        error: ctx.unavailableReason ?? 'Mink is unavailable.',
      );
      return;
    }

    try {
      await ref
          .read(minkServiceProvider)
          .sendMessage(
            sessionId: arg,
            userText: trimmed,
            workspaceId: ctx.workspaceId,
            projectId: ctx.projectId,
            permissions: ctx.permissions,
            tier: ctx.tier,
            modelId: ctx.modelId,
          );
      ref.invalidate(chatMessagesProvider(arg));
      state = const ChatSendState();
    } on LlmUnavailableException {
      ref.invalidate(chatMessagesProvider(arg));
      state = const ChatSendState(
        error: 'Mink is unavailable on this device right now.',
      );
    } on Object {
      ref.invalidate(chatMessagesProvider(arg));
      state = const ChatSendState(
        error: 'Something went wrong. Please try again.',
      );
    }
  }
}

final chatSendProvider = NotifierProvider.autoDispose
    .family<ChatSend, ChatSendState, String>(ChatSend.new);
