import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/home_screen.dart';
import '../ui/screens/paste_editor_screen.dart';
import '../ui/screens/placeholder_screen.dart';
import 'routes.dart';

/// Builds a fresh router. Exposed as a factory so tests get an isolated
/// instance (no navigation state leaking between tests).
GoRouter createRouter() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: Routes.scan,
      builder: (context, state) => const PlaceholderScreen(
        title: 'Scan',
        message: 'Camera capture & OCR arrive with Phase 4 (native input).',
        icon: Icons.document_scanner_outlined,
      ),
    ),
    GoRoute(
      path: Routes.paste,
      builder: (context, state) => const PasteEditorScreen(),
    ),
    GoRoute(
      path: Routes.import,
      builder: (context, state) => const PlaceholderScreen(
        title: 'Import',
        message: 'Image & PDF import arrive with Phase 4 (native input).',
        icon: Icons.file_open_outlined,
      ),
    ),
    GoRoute(
      path: Routes.newProject,
      builder: (context, state) => const PlaceholderScreen(
        title: 'New Project',
        message: 'Project creation UI arrives in a later Phase 5 chunk.',
        icon: Icons.create_new_folder_outlined,
      ),
    ),
    GoRoute(
      path: Routes.chat,
      builder: (context, state) => const PlaceholderScreen(
        title: 'Chat with Mink',
        message: 'The Mink chat UI arrives with the conversational layer.',
        icon: Icons.chat_bubble_outline,
      ),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const PlaceholderScreen(
        title: 'Settings',
        message: 'The Settings screen arrives in Phase 5e.',
        icon: Icons.settings_outlined,
      ),
    ),
  ],
);

/// App-wide router. Overridable in tests for an isolated instance.
final routerProvider = Provider<GoRouter>((ref) => createRouter());
