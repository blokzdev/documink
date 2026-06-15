import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/id_generator.dart';
import '../../features/audit/audit_event_type.dart';
import '../../features/audit/audit_providers.dart';
import '../../features/chat/chat_providers.dart';
import '../../features/chat/chat_repository.dart';
import '../../features/documents/document_repository.dart';
import '../theme/tokens.dart';
import '../widgets/token_text.dart';

/// A single Mink conversation: the transcript (user / Mink bubbles, inline
/// tool-call chips) plus the composer. Token references render masked; Mink's
/// model is shown in the app bar (roadmap Phase 12).
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String get _sessionId => widget.sessionId;

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    await ref.read(chatSendProvider(_sessionId).notifier).send(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _report(ChatMessage message) async {
    await ref
        .read(auditLogRepositoryProvider)
        .record(
          id: defaultIdGenerator(),
          workspaceId: DocumentRepository.defaultWorkspaceId,
          eventType: AuditEventType.aiOutputReported,
          success: true,
          metadata: {'session_id': message.sessionId, 'message_id': message.id},
          nowEpochMs: DateTime.now().millisecondsSinceEpoch,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reported. Flagged locally for your review.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(_sessionId));
    final sendState = ref.watch(chatSendProvider(_sessionId));
    final model = ref
        .watch(minkTurnContextProvider)
        .maybeWhen(data: (c) => c.modelId, orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mink'),
        bottom: model == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(18),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.spacingXs),
                  child: Text(
                    'on-device · $model',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: Column(
              children: [
                Expanded(
                  child: messagesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(
                      child: Text('Could not load this conversation.'),
                    ),
                    data: (messages) {
                      final visible = messages
                          .where((m) => m.role != ChatRole.toolResult)
                          .toList();
                      if (visible.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTokens.spacingLg),
                            child: Text(
                              'Ask Mink about your documents, redactions, or '
                              'anything you want it to remember.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      _scrollToBottom();
                      return ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(AppTokens.spacingMd),
                        itemCount: visible.length,
                        itemBuilder: (context, i) => _MessageView(
                          visible[i],
                          onReport: () => _report(visible[i]),
                        ),
                      );
                    },
                  ),
                ),
                if (sendState.error != null) _Banner(sendState.error!),
                _Composer(
                  controller: _input,
                  sending: sendState.sending,
                  onSend: _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView(this.message, {required this.onReport});

  final ChatMessage message;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (message.role == ChatRole.toolCall) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTokens.spacingXs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppTokens.spacingXs),
            Flexible(
              child: Text(
                'Mink used ${_toolName(message.toolCallJson)}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    final isUser = message.role == ChatRole.user;
    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: AppTokens.spacingXs),
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppTokens.cardRadius,
      ),
      child: TokenText(message.content),
    );

    final column = Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        bubble,
        if (!isUser)
          TextButton.icon(
            onPressed: onReport,
            icon: const Icon(Icons.flag_outlined, size: 16),
            label: const Text('Report'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.92,
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: column,
      ),
    );
  }

  String _toolName(String? toolCallJson) {
    if (toolCallJson == null) return 'a tool';
    try {
      final decoded = jsonDecode(toolCallJson);
      if (decoded is Map && decoded['tool'] is String) {
        return '`${decoded['tool']}`';
      }
    } on FormatException {
      // fall through
    }
    return 'a tool';
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.errorContainer,
      padding: const EdgeInsets.all(AppTokens.spacingSm),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              enabled: !sending,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Message Mink',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: AppTokens.spacingSm),
          sending
              ? const Padding(
                  padding: EdgeInsets.all(AppTokens.spacingSm),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton.filled(
                  onPressed: onSend,
                  icon: const Icon(Icons.send),
                  tooltip: 'Send',
                ),
        ],
      ),
    );
  }
}
