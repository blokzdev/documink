import 'package:documink/core/bootstrap.dart';
import 'package:documink/core/flavors/flavor.dart';
import 'package:documink/ui/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container() => ProviderContainer(
  overrides: [currentFlavorProvider.overrideWithValue(Flavor.dev)],
);

Future<ProviderContainer> _pumpApp(WidgetTester tester) async {
  final container = _container();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const DocuMinkApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('Home shows the app title and all primary actions', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('DocuMink'), findsOneWidget);
    for (final label in const [
      'Scan',
      'Paste text',
      'Import',
      'New Project',
      'Chat with Mink',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('tapping a primary action pushes its destination', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Paste text'));
    await tester.pumpAndSettle();

    // Placeholder destination for the paste route.
    expect(find.textContaining('Phase 5b'), findsOneWidget);
  });

  testWidgets('Settings action pushes the settings screen', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Phase 5e'), findsOneWidget);
  });

  testWidgets('theme toggle cycles the theme mode', (tester) async {
    final container = await _pumpApp(tester);
    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pump();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
