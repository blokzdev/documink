import 'package:documink/ui/screens/paste_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpEditor(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: PasteEditorScreen())),
  );
}

String _previewText(WidgetTester tester) => tester
    .widget<SelectableText>(find.byKey(const Key('redacted-preview')))
    .data!;

void main() {
  testWidgets('detects an entity and shows a redacted preview', (tester) async {
    await _pumpEditor(tester);

    await tester.enterText(
      find.byType(TextField),
      'Email me at alice@example.com today.',
    );
    await tester.tap(find.text('Detect'));
    await tester.pumpAndSettle();

    expect(find.textContaining('detected'), findsOneWidget);
    expect(find.textContaining('EMAIL'), findsOneWidget);
    expect(_previewText(tester), contains('[REDACTED]'));
  });

  testWidgets('switching to Mask updates the preview', (tester) async {
    await _pumpEditor(tester);

    await tester.enterText(find.byType(TextField), 'Reach alice@example.com.');
    await tester.tap(find.text('Detect'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mask'));
    await tester.pumpAndSettle();

    expect(_previewText(tester), contains('•'));
    expect(_previewText(tester), isNot(contains('alice@example.com')));
  });

  testWidgets('empty input shows the no-entities state', (tester) async {
    await _pumpEditor(tester);

    await tester.enterText(find.byType(TextField), 'just some words');
    await tester.tap(find.text('Detect'));
    await tester.pumpAndSettle();

    expect(find.text('No sensitive entities detected.'), findsOneWidget);
  });
}
