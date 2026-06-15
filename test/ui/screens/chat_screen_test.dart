import 'package:documink/data/app_database.dart';
import 'package:documink/features/chat/chat_providers.dart';
import 'package:documink/ui/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ChatSession _session(String id, {String? title}) => ChatSession(
  id: id,
  workspaceId: 'ws_default',
  title: title,
  createdAt: 0,
  updatedAt: 1000,
  tierAtCreation: 'standard',
  variantAtCreation: 'balanced',
  modelIdAtCreation: 'gemma',
  archived: 0,
);

Widget _app(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(home: ChatScreen()),
);

void main() {
  testWidgets('empty state offers a New chat action', (tester) async {
    await tester.pumpWidget(
      _app([chatSessionsProvider.overrideWith((ref) async => [])]),
    );
    await tester.pumpAndSettle();

    expect(find.text('No chats yet'), findsOneWidget);
    // 'New chat' appears on both the FAB and the empty-state action.
    expect(find.text('New chat'), findsWidgets);
  });

  testWidgets('renders a tile per session with its model', (tester) async {
    await tester.pumpWidget(
      _app([
        chatSessionsProvider.overrideWith(
          (ref) async => [_session('s1', title: 'Tax docs'), _session('s2')],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tax docs'), findsOneWidget);
    expect(find.text('Untitled chat'), findsOneWidget);
    expect(find.textContaining('gemma'), findsWidgets);
  });
}
