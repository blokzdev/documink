import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audit/audit_providers.dart';
import '../llm/llm_providers.dart';
import 'deterministic_suggestion_rules.dart';
import 'llm_suggestion_source.dart';
import 'proactive_suggester.dart';

/// The proactive-suggestion orchestrator (blueprint §5.5). Sources are consulted
/// in order: the deterministic, all-tiers, no-model rules first (so they win when
/// both fire), then the optional on-device LLM enrichment (consulted only when a
/// model is available). Audited via the shared audit log.
final proactiveSuggesterProvider = Provider<ProactiveSuggester>(
  (ref) => ProactiveSuggester(
    sources: [
      const DeterministicSuggestionSource(),
      LlmSuggestionSource(ref.watch(llmBackendProvider)),
    ],
    audit: ref.watch(auditLogRepositoryProvider),
  ),
);
