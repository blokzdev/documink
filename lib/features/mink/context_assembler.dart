import '../../data/app_database.dart' show ChatMessage;
import '../chat/chat_repository.dart';
import '../llm/device_capability_profiler.dart' show noTier;

/// Mink's identity + privacy posture, prepended to every prompt. Mink is the
/// on-device assistant (no cloud); it references personal values as token refs
/// and calls tools rather than inventing answers (blueprint §5; memory.md §3).
const String minkSystemPrompt = '''
You are Mink, the private on-device assistant inside DocuMink. Everything runs
locally — no cloud, no tracking. You help the user understand and redact their
documents and you remember useful context across sessions.

Rules:
- Never reveal decoded personal data. Refer to detected values by type
  (<PERSON>, <EMAIL>, <SSN>) or by their token reference.
- Never store raw personal data in memory; store token references instead.
- Prefer calling a tool to look something up over guessing.
- Be concise and direct.''';

/// Assembles the single prompt string handed to the [LlmBackend] for a turn:
/// system prompt + project persona + (tier-scaled) memory + recent transcript +
/// the tool catalog. Pure and deterministic, so the whole context build is
/// unit-testable headlessly (memory.md §4.3 / §7).
class ContextAssembler {
  const ContextAssembler();

  /// Most recent transcript messages to include (older turns are dropped to
  /// keep the prompt within budget).
  static const int maxHistoryMessages = 24;

  /// How many episodic memories to recall for context, scaled by tier
  /// (memory.md §7). Disabled at Minimum and below the floor.
  int episodicLimitForTier(String tier) {
    if (tier == noTier || tier == 'minimum') return 0;
    if (tier == 'standard') return 8;
    return 12; // performance / professional / system-provided
  }

  /// Whether episodic capture is allowed to write at this tier (memory.md §7:
  /// episodic is disabled at Minimum and below the floor).
  static bool episodicEnabledForTier(String tier) =>
      tier != noTier && tier != 'minimum';

  String build({
    required List<Map<String, dynamic>> coreMemory,
    required List<Map<String, dynamic>> episodic,
    required List<ChatMessage> history,
    required String toolCatalog,
    String? persona,
    String? systemPromptAddendum,
  }) {
    final b = StringBuffer()..writeln(minkSystemPrompt);

    if (persona != null && persona.trim().isNotEmpty) {
      b
        ..writeln()
        ..writeln('Project persona: ${persona.trim()}');
    }
    if (systemPromptAddendum != null &&
        systemPromptAddendum.trim().isNotEmpty) {
      b.writeln(systemPromptAddendum.trim());
    }

    b
      ..writeln()
      ..writeln(toolCatalog);

    if (coreMemory.isNotEmpty) {
      b
        ..writeln()
        ..writeln('What you remember about the user:');
      for (final m in coreMemory) {
        b.writeln('- ${m['key']}: ${m['value']}');
      }
    }

    if (episodic.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Recent activity:');
      for (final e in episodic) {
        b.writeln('- ${e['summary']}');
      }
    }

    final recent = history.length > maxHistoryMessages
        ? history.sublist(history.length - maxHistoryMessages)
        : history;
    if (recent.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Conversation so far:');
      for (final m in recent) {
        b.writeln('${_speaker(m)}: ${_line(m)}');
      }
    }

    b
      ..writeln()
      ..writeln('Now respond to the latest user message.');
    return b.toString();
  }

  String _speaker(ChatMessage m) => switch (m.role) {
    ChatRole.user => 'User',
    ChatRole.mink => 'Mink',
    ChatRole.toolCall => 'ToolCall',
    ChatRole.toolResult => 'ToolResult',
    _ => 'System',
  };

  String _line(ChatMessage m) {
    if (m.role == ChatRole.toolCall) return m.toolCallJson ?? m.content;
    if (m.role == ChatRole.toolResult) return m.toolResultJson ?? m.content;
    return m.content;
  }
}
