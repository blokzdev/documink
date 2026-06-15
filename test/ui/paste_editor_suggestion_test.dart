import 'package:documink/data/app_database.dart';
import 'package:documink/services/database_providers.dart';
import 'package:documink/services/settings_store.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/paste_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

/// Two emails → a recurring EMAIL type, so the deterministic rule fires.
const _recurring = 'Email alice@example.com or bob@example.com.';

void main() {
  late TestVault vault;

  setUp(() async {
    vault = await TestVault.unlocked();
    addTearDown(vault.dispose);
  });

  Future<void> pump(WidgetTester tester, {SettingsStore? store}) async {
    // Tall viewport so the suggestion card (low in the list) is laid out + tappable.
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        vault.override,
        if (store != null) settingsStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    // The default workspace exists from vault init in production; the audit
    // (FK → workspaces) needs it for suggestion_offered/actioned/dismissed.
    final db = container.read(appDatabaseProvider);
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws_default',
            name: 'W',
            createdAt: 0,
            kekVersion: 1,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PasteEditorScreen(),
        ),
      ),
    );
  }

  Future<void> detect(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text('Detect'));
    await tester.pumpAndSettle();
  }

  final card = find.byKey(const Key('proactive-suggestion-card'));
  String preview(WidgetTester tester) => tester
      .widget<SelectableText>(find.byKey(const Key('redacted-preview')))
      .data!;

  testWidgets('a recurring entity surfaces a suggestion card', (tester) async {
    await pump(tester);
    await detect(tester, _recurring);

    expect(card, findsOneWidget);
    expect(find.textContaining('Tokenize all 2'), findsOneWidget);
    // First-offer disclosure shows once.
    expect(find.textContaining('turn this off in Settings'), findsOneWidget);
  });

  testWidgets('a single occurrence does not surface a card', (tester) async {
    await pump(tester);
    await detect(tester, 'Email alice@example.com today.');

    expect(card, findsNothing);
  });

  testWidgets('applying the suggestion tokenizes that label', (tester) async {
    await pump(tester);
    await detect(tester, _recurring);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(card, findsNothing);
    expect(preview(tester), contains('<EMAIL_'));
    expect(preview(tester), isNot(contains('alice@example.com')));
  });

  testWidgets('dismissing hides the card without changing the preview', (
    tester,
  ) async {
    await pump(tester);
    await detect(tester, _recurring);
    expect(preview(tester), contains('[REDACTED]'));

    await tester.tap(find.widgetWithText(TextButton, 'Dismiss'));
    await tester.pumpAndSettle();

    expect(card, findsNothing);
    expect(preview(tester), contains('[REDACTED]'));
  });

  testWidgets('no card when proactive suggestions are turned off', (
    tester,
  ) async {
    await pump(
      tester,
      store: InMemorySettingsStore({'proactive_suggestions_enabled': 'false'}),
    );
    await detect(tester, _recurring);

    expect(card, findsNothing);
  });
}
