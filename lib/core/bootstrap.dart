import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flavors/flavor.dart';
import 'router.dart';
import '../ui/theme/app_theme.dart';
import '../ui/theme/theme_mode_controller.dart';

void bootstrap(Flavor flavor) {
  runApp(
    ProviderScope(
      overrides: [currentFlavorProvider.overrideWithValue(flavor)],
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
