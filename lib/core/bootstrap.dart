import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flavors/flavor.dart';
import 'router.dart';
import '../services/authenticator.dart';
import '../services/local_auth_authenticator.dart';
import '../services/settings_store.dart';
import '../services/shared_preferences_settings_store.dart';
import '../services/vault_providers.dart';
import '../ui/theme/app_theme.dart';
import '../ui/theme/theme_mode_controller.dart';

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final supportDir = await getApplicationSupportDirectory();
  final vaultFile = File('${supportDir.path}/vault.db');
  runApp(
    ProviderScope(
      overrides: [
        currentFlavorProvider.overrideWithValue(flavor),
        settingsStoreProvider.overrideWithValue(
          SharedPreferencesSettingsStore(prefs),
        ),
        vaultFileProvider.overrideWithValue(vaultFile),
        authenticatorProvider.overrideWithValue(LocalAuthAuthenticator()),
      ],
      child: const DocuMinkApp(),
    ),
  );
}

class DocuMinkApp extends ConsumerWidget {
  const DocuMinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'DocuMink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
