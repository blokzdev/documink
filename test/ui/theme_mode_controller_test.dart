import 'package:flutter/material.dart';
import 'package:documink/services/settings_store.dart';
import 'package:documink/ui/theme/theme_mode_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to system', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(themeModeProvider), ThemeMode.system);
  });

  test('loads the persisted mode from the settings store', () {
    final c = ProviderContainer(
      overrides: [
        settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore({ThemeModeController.settingsKey: 'dark'}),
        ),
      ],
    );
    addTearDown(c.dispose);
    expect(c.read(themeModeProvider), ThemeMode.dark);
  });

  test('set persists the mode to the store', () {
    final store = InMemorySettingsStore();
    final c = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);

    c.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(store.getString(ThemeModeController.settingsKey), 'dark');
  });

  test('cycle: system -> light -> dark -> system', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final ctrl = c.read(themeModeProvider.notifier);

    ctrl.cycle();
    expect(c.read(themeModeProvider), ThemeMode.light);
    ctrl.cycle();
    expect(c.read(themeModeProvider), ThemeMode.dark);
    ctrl.cycle();
    expect(c.read(themeModeProvider), ThemeMode.system);
  });

  test('set assigns directly', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(c.read(themeModeProvider), ThemeMode.dark);
  });
}
