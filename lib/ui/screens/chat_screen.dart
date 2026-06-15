import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/datetime_format.dart';
import '../../core/routes.dart';
import '../../data/app_database.dart';
import '../../features/chat/chat_providers.dart';
import '../theme/tokens.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';

/// The Mink chat home: the user's chat sessions in the active scope (a Project,
/// or global), newest-active first, with a "New chat" action (blueprint §5,
/// roadmap Phase 12). Tapping a session opens its thread.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  Future<void> _newChat(BuildContext context, WidgetRef ref) async {
    final ctx = await ref.read(minkTurnContextProvider.future);
    final id = await ref
        .read(chatRepositoryProvider)
        .createSession(
          workspaceId: ctx.workspaceId,
          projectId: ctx.projectId,
          tierAtCreation: ctx.tier,
          variantAtCreation: ctx.variantId,
          modelIdAtCreation: ctx.modelId,
        );
    ref.invalidate(chatSessionsProvider);
    if (context.mounted) context.push(Routes.chatThread(id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(chatSessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Mink')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newChat(context, ref),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('New chat'),
      ),
      body: SafeArea(
        child: sessionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => AppErrorState(
            title: 'Could not load your chats',
            onRetry: () => ref.invalidate(chatSessionsProvider),
          ),
          data: (sessions) {
            if (sessions.isEmpty) {
              return AppEmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No chats yet',
                message:
                    'Start a conversation with Mink, your private '
                    'on-device assistant.',
                action: FilledButton.icon(
                  onPressed: () => _newChat(context, ref),
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('New chat'),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.maxContentWidth,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTokens.spacingSm),
                  itemBuilder: (context, i) => _SessionTile(sessions[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile(this.session);

  final ChatSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.forum_outlined),
        title: Text(
          session.title?.trim().isNotEmpty == true
              ? session.title!
              : 'Untitled chat',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Updated ${formatTimestamp(session.updatedAt)} · '
          '${session.modelIdAtCreation}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.chatThread(session.id)),
      ),
    );
  }
}
