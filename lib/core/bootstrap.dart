import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flavors/flavor.dart';
import 'router.dart';
import '../ui/theme/app_theme.dart';

void bootstrap(Flavor flavor) {
  runApp(
    ProviderScope(
      overrides: [
        currentFlavorProvider.overrideWithValue(flavor),
      ],
      child: const DocuMinkApp(),
    ),
  );
}

class DocuMinkApp extends StatelessWidget {
  const DocuMinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DocuMink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}