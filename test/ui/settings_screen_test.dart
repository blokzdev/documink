import 'package:documink/core/flavors/flavor.dart';
import 'package:documink/ui/screens/settings_screen.dart';
import 'package:documink/ui/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [currentFlavorProvider.overrideWithValue(Flavor.dev)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: SettingsScreen()),
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
}
