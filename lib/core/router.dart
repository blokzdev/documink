import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/custom_entities/custom_entity_definition.dart';
import '../features/llm/llm_providers.dart';
import '../services/vault_providers.dart';
import '../ui/screens/ai_settings_screen.dart';
import '../ui/screens/audit_log_screen.dart';
import '../ui/screens/chat_screen.dart';
import '../ui/screens/chat_thread_screen.dart';
import '../ui/screens/blank_wizard_screen.dart';
import '../ui/screens/capture_screen.dart';
import '../ui/screens/custom_entity_form_screen.dart';
import '../ui/screens/custom_entity_types_screen.dart';
import '../ui/screens/document_detail_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/mink_memory_screen.dart';
import '../ui/screens/onboarding_ai_screen.dart';
import '../ui/screens/paste_editor_screen.dart';
import '../ui/screens/project_detail_screen.dart';
import '../ui/screens/projects_list_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/template_picker_screen.dart';
import '../ui/screens/upload_scaffold_screen.dart';
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
  ref.listen(aiOnboardingProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final unlocked = ref.read(appUnlockedProvider);
      final atUnlock = state.matchedLocation == Routes.unlock;
      if (!unlocked) return atUnlock ? null : Routes.unlock;
      if (atUnlock) return Routes.home;
      // First-run Tier-4 onboarding gate (Phase 11b): owed until the profiler
      // has run once. The flag is synchronous; see aiOnboardingProvider.
      final needsOnboarding = ref.read(aiOnboardingProvider);
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (needsOnboarding && !atOnboarding) return Routes.onboarding;
      if (!needsOnboarding && atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.unlock,
        builder: (context, state) => const VaultUnlockScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingAiScreen(),
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
        path: Routes.newProjectAiScaffold,
        builder: (context, state) => const UploadScaffoldScreen(),
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
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: Routes.chatThreadPattern,
        builder: (context, state) =>
            ChatThreadScreen(sessionId: state.pathParameters['sessionId']!),
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
        path: Routes.aiSettings,
        builder: (context, state) => const AiSettingsScreen(),
      ),
      GoRoute(
        path: Routes.minkMemory,
        builder: (context, state) => const MinkMemoryScreen(),
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
