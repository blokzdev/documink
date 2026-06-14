import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../services/database_providers.dart';
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

/// Loads + verifies the bundled, Ed25519-signed Verified-templates catalog.
final templateServiceProvider = Provider<TemplateService>(
  (ref) => TemplateService(),
);

/// The Verified templates (blueprint §6.3), for the template picker (14b-2).
/// Throws if the bundled catalog fails Ed25519 verification.
final verifiedTemplatesProvider = FutureProvider<List<TemplateDefinition>>(
  (ref) => ref.watch(templateServiceProvider).verifiedTemplates(),
);
