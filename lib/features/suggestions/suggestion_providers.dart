import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audit/audit_providers.dart';
import 'deterministic_suggestion_rules.dart';
import 'proactive_suggester.dart';

/// The proactive-suggestion orchestrator (blueprint §5.5). This slice wires only
/// the deterministic, all-tiers, no-model source; the optional on-device LLM
/// source is appended in a later slice. Audited via the shared audit log.
final proactiveSuggesterProvider = Provider<ProactiveSuggester>(
  (ref) => ProactiveSuggester(
    sources: const [DeterministicSuggestionSource()],
    audit: ref.watch(auditLogRepositoryProvider),
  ),
);
