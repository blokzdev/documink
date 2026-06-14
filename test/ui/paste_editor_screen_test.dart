import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/paste_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

void main() {
  late TestVault vault;

  setUp(() async {
    vault = await TestVault.unlocked();
    addTearDown(vault.dispose);
  });

  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vault.override],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PasteEditorScreen(),
        ),
      ),
    );
  }

  String previewText(WidgetTester tester) => tester
      .widget<SelectableText>(find.byKey(const Key('redacted-preview')))
      .data!;

  Future<void> detect(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text('Detect'));
    await tester.pumpAndSettle();
  }

  testWidgets('detects an entity and shows a redacted preview', (tester) async {
    await pumpEditor(tester);
    await detect(tester, 'Email me at alice@example.com today.');

    expect(find.textContaining('detected'), findsOneWidget);
    expect(find.textContaining('EMAIL'), findsOneWidget);
    expect(previewText(tester), contains('[REDACTED]'));
  });

  testWidgets('switching to Mask updates the preview', (tester) async {
    await pumpEditor(tester);
    await detect(tester, 'Reach alice@example.com.');

    await tester.tap(find.text('Mask'));
    await tester.pumpAndSettle();

    expect(previewText(tester), contains('•'));
    expect(previewText(tester), isNot(contains('alice@example.com')));
  });

  testWidgets('Token operator yields a vault surrogate', (tester) async {
    await pumpEditor(tester);
    await detect(tester, 'Reach alice@example.com.');

    await tester.tap(find.text('Token'));
    await tester.pumpAndSettle();

    expect(previewText(tester), contains('<EMAIL_'));
    expect(previewText(tester), isNot(contains('alice@example.com')));
  });

  testWidgets('Encrypt operator yields an inline ciphertext', (tester) async {
    await pumpEditor(tester);
    await detect(tester, 'Reach alice@example.com.');

    await tester.tap(find.text('Encrypt'));
    await tester.pumpAndSettle();

    expect(previewText(tester), contains('<ENC:'));
  });

  testWidgets('empty input shows the no-entities state', (tester) async {
    await pumpEditor(tester);
    await detect(tester, 'just some words');

    expect(find.text('No sensitive entities detected.'), findsOneWidget);
  });

  testWidgets('initialText (from an input source) seeds and auto-detects', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vault.override],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PasteEditorScreen(initialText: 'Reach alice@example.com.'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Detection ran automatically on the seeded text.
    expect(find.textContaining('detected'), findsOneWidget);
    expect(find.textContaining('EMAIL'), findsOneWidget);
    expect(previewText(tester), contains('[REDACTED]'));
  });
}
