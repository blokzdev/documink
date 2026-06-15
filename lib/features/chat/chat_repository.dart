import 'package:drift/drift.dart';

import '../../data/app_database.dart';
import '../../data/id_generator.dart';

/// Canonical `chat_messages.role` values (blueprint §3.2). Mink's transcript
/// interleaves user turns, Mink replies, and the tool calls/results it makes.
class ChatRole {
  const ChatRole._();

  static const String user = 'user';
  static const String mink = 'mink';
  static const String toolCall = 'tool_call';
  static const String toolResult = 'tool_result';
  static const String system = 'system';
}

/// Persists Mink chat sessions and their messages into the unlocked vault
/// (`chat_sessions` / `chat_messages`, blueprint §3.2). Content is stored in the
/// encrypted vault like document originals; Mink's own output + memory use
/// token-refs (`<<tok_…>>`) rather than inline plaintext, masked on display.
class ChatRepository {
  ChatRepository(
    this._db, {
    IdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final IdGenerator _newId;
  final DateTime Function() _clock;

  /// Opens a new session, stamping the tier/variant/model active at creation
  /// (so the transcript records which model produced it, even after a re-profile).
  Future<String> createSession({
    required String workspaceId,
    String? projectId,
    required String tierAtCreation,
    required String variantAtCreation,
    required String modelIdAtCreation,
    String? title,
  }) async {
    final id = _newId();
    final now = _clock().millisecondsSinceEpoch;
    await _db
        .into(_db.chatSessions)
        .insert(
          ChatSessionsCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            projectId: Value(projectId),
            title: Value(title),
            createdAt: now,
            updatedAt: now,
            tierAtCreation: tierAtCreation,
            variantAtCreation: variantAtCreation,
            modelIdAtCreation: modelIdAtCreation,
          ),
        );
    return id;
  }

  /// Appends a message to a session and bumps the session's `updated_at`.
  Future<String> addMessage({
    required String sessionId,
    required String role,
    required String content,
    required String modelId,
    String? toolCallJson,
    String? toolResultJson,
    int? tokensInput,
    int? tokensOutput,
    int? inferenceMs,
  }) async {
    final id = _newId();
    final now = _clock().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await _db
          .into(_db.chatMessages)
          .insert(
            ChatMessagesCompanion.insert(
              id: id,
              sessionId: sessionId,
              role: role,
              content: content,
              toolCallJson: Value(toolCallJson),
              toolResultJson: Value(toolResultJson),
              tokensInput: Value(tokensInput),
              tokensOutput: Value(tokensOutput),
              inferenceMs: Value(inferenceMs),
              modelId: modelId,
              createdAt: now,
            ),
          );
      await (_db.update(_db.chatSessions)..where((s) => s.id.equals(sessionId)))
          .write(ChatSessionsCompanion(updatedAt: Value(now)));
    });
    return id;
  }

  /// Sessions in the given scope, most-recently-active first. [projectId] null
  /// returns workspace-global (no-project) sessions; pass a project id for that
  /// project's sessions (blueprint §6.7 isolation).
  Future<List<ChatSession>> listSessions({
    String? projectId,
    bool includeArchived = false,
  }) {
    final q = _db.select(_db.chatSessions)
      ..where(
        (s) => projectId == null
            ? s.projectId.isNull()
            : s.projectId.equals(projectId),
      );
    if (!includeArchived) {
      q.where((s) => s.archived.equals(0));
    }
    q.orderBy([(s) => OrderingTerm.desc(s.updatedAt)]);
    return q.get();
  }

  /// All messages in a session, oldest-first (transcript order).
  Future<List<ChatMessage>> messagesForSession(String sessionId) {
    return (_db.select(_db.chatMessages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  /// Renames a session (user-editable title; auto-generated from the first turn).
  Future<void> renameSession(String id, String title) async {
    await (_db.update(_db.chatSessions)..where((s) => s.id.equals(id))).write(
      ChatSessionsCompanion(
        title: Value(title),
        updatedAt: Value(_clock().millisecondsSinceEpoch),
      ),
    );
  }

  /// Soft-archives a session (kept for audit; hidden from the default list).
  Future<void> archiveSession(String id) async {
    await (_db.update(_db.chatSessions)..where((s) => s.id.equals(id))).write(
      ChatSessionsCompanion(
        archived: const Value(1),
        updatedAt: Value(_clock().millisecondsSinceEpoch),
      ),
    );
  }
}
