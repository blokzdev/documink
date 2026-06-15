import 'package:documink/data/app_database.dart';
import 'package:documink/features/chat/chat_repository.dart';
import 'package:documink/features/mink/context_assembler.dart';
import 'package:documink/features/mink/tool_registry.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessage _msg(String role, String content) => ChatMessage(
  id: 'm_$content',
  sessionId: 's',
  role: role,
  content: content,
  modelId: 'model',
  createdAt: 0,
);

void main() {
  const assembler = ContextAssembler();

  group('episodic tier scaling', () {
    test('disabled at minimum and floor', () {
      expect(assembler.episodicLimitForTier('minimum'), 0);
      expect(assembler.episodicLimitForTier('none'), 0);
      expect(ContextAssembler.episodicEnabledForTier('minimum'), isFalse);
      expect(ContextAssembler.episodicEnabledForTier('none'), isFalse);
    });

    test('full at standard and above', () {
      expect(assembler.episodicLimitForTier('standard'), greaterThan(0));
      expect(assembler.episodicLimitForTier('performance'), greaterThan(0));
      expect(ContextAssembler.episodicEnabledForTier('standard'), isTrue);
    });
  });

  group('build', () {
    test('includes system prompt, tool catalog, memory and transcript', () {
      final prompt = assembler.build(
        coreMemory: [
          {'key': 'preferred_name', 'value': 'Dr. A'},
        ],
        episodic: [
          {'summary': 'Redacted a lab report'},
        ],
        history: [
          _msg(ChatRole.user, 'hello'),
          _msg(ChatRole.mink, 'hi there'),
        ],
        toolCatalog: minkToolCatalog,
        persona: 'A medical records helper',
      );

      expect(prompt, contains('You are Mink'));
      expect(prompt, contains('Project persona: A medical records helper'));
      expect(prompt, contains('preferred_name: Dr. A'));
      expect(prompt, contains('Redacted a lab report'));
      expect(prompt, contains('User: hello'));
      expect(prompt, contains('Mink: hi there'));
      expect(prompt, contains('search_documents'));
    });

    test('keeps only the most recent history window', () {
      final history = [
        for (var i = 0; i < ContextAssembler.maxHistoryMessages + 5; i++)
          _msg(ChatRole.user, 'line$i'),
      ];
      final prompt = assembler.build(
        coreMemory: const [],
        episodic: const [],
        history: history,
        toolCatalog: minkToolCatalog,
      );
      expect(prompt, isNot(contains('line0')));
      expect(prompt, contains('line${history.length - 1}'));
    });
  });
}
