import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/settings_store.dart';

/// Runtime light/dark/system theme selection, persisted via [settingsStoreProvider]
/// (the persistent store is wired at bootstrap; in-memory in tests).
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  static const settingsKey = 'theme_mode';

  @override
  ThemeMode build() =>
      _parse(ref.read(settingsStoreProvider).getString(settingsKey));

  void set(ThemeMode mode) {
    state = mode;
    ref.read(settingsStoreProvider).setString(settingsKey, mode.name);
  }

  /// Cycles system → light → dark → system (the AppBar quick-toggle).
  void cycle() => set(switch (state) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  });

  static ThemeMode _parse(String? raw) => ThemeMode.values.firstWhere(
    (m) => m.name == raw,
    orElse: () => ThemeMode.system,
  );
}
