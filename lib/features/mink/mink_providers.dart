import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audit/audit_providers.dart';
import '../chat/chat_providers.dart';
import '../documents/document_repository.dart';
import '../llm/llm_providers.dart';
import '../memory/memory_providers.dart';
import '../../services/authenticator.dart';
import 'context_assembler.dart';
import 'mink_service.dart';
import 'tool_registry.dart';

/// Executes Mink's tool calls (memory + read tools), delegating to existing
/// services. Permission/biometric gating happens in [MinkService].
final toolRegistryProvider = Provider<ToolRegistry>(
  (ref) => ToolRegistry(
    memoryRouter: ref.watch(memoryRouterProvider),
    documents: ref.watch(documentRepositoryProvider),
  ),
);

final contextAssemblerProvider = Provider<ContextAssembler>(
  (ref) => const ContextAssembler(),
);

/// Mink's conversational orchestrator. Resolves to the activated on-device
/// [LlmBackend] when AI is enabled, else the fail-loud unavailable backend (so
/// the chat surface degrades gracefully below the floor).
final minkServiceProvider = Provider<MinkService>(
  (ref) => MinkService(
    chat: ref.watch(chatRepositoryProvider),
    memoryRouter: ref.watch(memoryRouterProvider),
    tools: ref.watch(toolRegistryProvider),
    assembler: ref.watch(contextAssemblerProvider),
    llm: ref.watch(llmBackendProvider),
    audit: ref.watch(auditLogRepositoryProvider),
    authenticator: ref.watch(authenticatorProvider),
  ),
);
