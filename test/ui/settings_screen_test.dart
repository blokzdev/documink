import 'package:documink/core/flavors/flavor.dart';
import 'package:documink/features/suggestions/proactive_suggestions_setting.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/services/settings_store.dart';
import 'package:documink/ui/screens/settings_screen.dart';
import 'package:documink/ui/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  SettingsStore? store,
}) async {
  final container = ProviderContainer(
    overrides: [
      currentFlavorProvider.overrideWithValue(Flavor.dev),
      if (store != null) settingsStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('shows the settings sections', (tester) async {
    await _pump(tester);
    // Top sections render immediately…
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('SECURITY'), findsOneWidget);
    // …lower ones are below the fold in the test viewport.
    await tester.scrollUntilVisible(find.text('ABOUT'), 200);
    expect(find.text('ABOUT'), findsOneWidget);
  });

  testWidgets('selecting a theme updates themeMode live', (tester) async {
    final container = await _pump(tester);
    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.dark);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  testWidgets('proactive-suggestions toggle defaults on and opts out live', (
    tester,
  ) async {
    // Tall viewport so the whole settings list (the toggle sits low) is on-screen.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemorySettingsStore();
    final container = await _pump(tester, store: store);
    expect(container.read(proactiveSuggestionsProvider), isTrue);

    final toggle = find.byKey(const Key('proactive-suggestions-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(container.read(proactiveSuggestionsProvider), isFalse);
    expect(store.getString('proactive_suggestions_enabled'), 'false');
  });
}
