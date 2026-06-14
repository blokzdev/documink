import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/custom_entities/custom_entity_definition.dart';
import '../services/vault_providers.dart';
import '../ui/screens/audit_log_screen.dart';
import '../ui/screens/blank_wizard_screen.dart';
import '../ui/screens/capture_screen.dart';
import '../ui/screens/custom_entity_form_screen.dart';
import '../ui/screens/custom_entity_types_screen.dart';
import '../ui/screens/document_detail_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/paste_editor_screen.dart';
import '../ui/screens/placeholder_screen.dart';
import '../ui/screens/project_detail_screen.dart';
import '../ui/screens/projects_list_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/template_picker_screen.dart';
import '../ui/screens/vault_browser_screen.dart';
import '../ui/screens/vault_unlock_screen.dart';
import 'routes.dart';

/// Builds a fresh router gated on vault unlock. Reads [appUnlockedProvider] for
/// the redirect and refreshes when it changes, so locking/unlocking moves the
/// user to/from the unlock screen. Exposed as a factory so tests get an isolated
/// instance (no navigation state leaking between tests).
GoRouter createRouter(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(appUnlockedProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final unlocked = ref.read(appUnlockedProvider);
      final atUnlock = state.matchedLocation == Routes.unlock;
      if (!unlocked) return atUnlock ? null : Routes.unlock;
      if (atUnlock) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.unlock,
        builder: (context, state) => const VaultUnlockScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.scan,
        builder: (context, state) =>
            const CaptureScreen(mode: CaptureMode.scan),
      ),
      GoRoute(
        path: Routes.paste,
        builder: (context, state) =>
            PasteEditorScreen(initialText: state.extra as String?),
      ),
      GoRoute(
        path: Routes.import,
        builder: (context, state) =>
            const CaptureScreen(mode: CaptureMode.import),
      ),
      GoRoute(
        path: Routes.newProject,
        builder: (context, state) => const TemplatePickerScreen(),
      ),
      GoRoute(
        path: Routes.newProjectWizard,
        builder: (context, state) => const BlankWizardScreen(),
      ),
      GoRoute(
        path: Routes.projects,
        builder: (context, state) => const ProjectsListScreen(),
      ),
      GoRoute(
        path: Routes.projectDetailPattern,
        builder: (context, state) =>
            ProjectDetailScreen(projectId: state.pathParameters['id']!),
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
        path: Routes.vault,
        builder: (context, state) => const VaultBrowserScreen(),
      ),
      GoRoute(
        path: Routes.documentPattern,
        builder: (context, state) =>
            DocumentDetailScreen(documentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.auditLog,
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(
        path: Routes.customEntities,
        builder: (context, state) => const CustomEntityTypesScreen(),
      ),
      GoRoute(
        path: Routes.customEntityForm,
        builder: (context, state) => CustomEntityFormScreen(
          initial: state.extra as CustomEntityDefinition?,
        ),
      ),
    ],
  );
}

/// App-wide router. Overridable in tests for an isolated instance.
final routerProvider = Provider<GoRouter>((ref) => createRouter(ref));
