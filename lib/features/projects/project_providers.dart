import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../services/database_providers.dart';
import '../documents/document_repository.dart';
import '../input/input_providers.dart';
import '../llm/llm_providers.dart';
import 'ai_scaffold_orchestrator.dart';
import 'domain_inference_service.dart';
import 'personal_template.dart';
import 'personal_template_repository.dart';
import 'project_repository.dart';
import 'template_manifest.dart';
import 'template_service.dart';
import 'tool_permission_registry.dart';

/// Decides whether a Mink tool call is permitted under a Project manifest
/// (blueprint §5/§6.7).
final toolPermissionRegistryProvider = Provider<ToolPermissionRegistry>(
  (ref) => const ToolPermissionRegistry(),
);

/// Project CRUD against the unlocked vault (throws if locked, via
/// [appDatabaseProvider]).
final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(ref.watch(appDatabaseProvider)),
);

/// The active (non-archived) Projects in the workspace, newest-updated first.
/// Auto-disposes so it refetches each time the Project list is opened.
final projectsListProvider = FutureProvider.autoDispose<List<Project>>(
  (ref) => ref.watch(projectRepositoryProvider).listActive(),
);

/// A single Project by id.
final projectByIdProvider = FutureProvider.autoDispose.family<Project?, String>(
  (ref, id) => ref.watch(projectRepositoryProvider).getById(id),
);

/// The documents belonging to a specific Project (newest first), for the project
/// detail screen — scoped by id rather than the active selection.
final projectDocumentsProvider = FutureProvider.autoDispose
    .family<List<Document>, String>(
      (ref, id) =>
          ref.watch(documentRepositoryProvider).listDocuments(projectId: id),
    );

/// Loads + verifies the bundled, Ed25519-signed Verified-templates catalog.
final templateServiceProvider = Provider<TemplateService>(
  (ref) => TemplateService(),
);

/// The Verified templates (blueprint §6.3), for the template picker (14b-2).
/// Throws if the bundled catalog fails Ed25519 verification.
final verifiedTemplatesProvider = FutureProvider<List<TemplateDefinition>>(
  (ref) => ref.watch(templateServiceProvider).verifiedTemplates(),
);

/// On-device document→template inference for creation Path B (blueprint §6.2).
/// Uses the [llmBackendProvider]; returns null (fall back to the picker) when no
/// Tier-4 model is available.
final domainInferenceServiceProvider = Provider<DomainInferenceService>(
  (ref) => DomainInferenceService(ref.watch(llmBackendProvider)),
);

/// Orchestrates the upload→infer step of creation Path B (blueprint §6.2): picks
/// + ingests a PDF via [inputIngestionServiceProvider] and classifies it with the
/// [domainInferenceServiceProvider]. Pure-Dart; the native pick/extract is the
/// injected seam.
final aiScaffoldOrchestratorProvider = Provider<AiScaffoldOrchestrator>(
  (ref) => AiScaffoldOrchestrator(
    pickDocument: ref.watch(inputIngestionServiceProvider).importPdf,
    inference: ref.watch(domainInferenceServiceProvider),
  ),
);

/// CRUD for the user's personal Project templates (blueprint §6.5), against the
/// unlocked vault.
final personalTemplateRepositoryProvider = Provider<PersonalTemplateRepository>(
  (ref) => PersonalTemplateRepository(ref.watch(appDatabaseProvider)),
);

/// The user's saved personal templates ("Yours" in the picker), newest first.
/// Auto-disposes so it refetches each time the picker is opened.
final personalTemplatesProvider =
    FutureProvider.autoDispose<List<PersonalTemplate>>(
      (ref) => ref.watch(personalTemplateRepositoryProvider).list(),
    );
