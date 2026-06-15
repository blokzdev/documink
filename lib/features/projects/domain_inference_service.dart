import 'dart:convert';

import '../llm/llm_backend.dart';

/// How confidently a [DomainSuggestion] matches a single template (blueprint
/// §6.2 Path B): a strong single match, a weak/ambiguous match (offer a few), or
/// no usable match (offer the full picker / AI-scaffold).
enum SuggestionStrength { strong, weak, none }

/// A structured suggestion from analyzing an uploaded document with the
/// on-device LLM (blueprint §6.2 Path B).
class DomainSuggestion {
  const DomainSuggestion({
    required this.domain,
    required this.confidence,
    required this.candidateTemplateIds,
  });

  final String domain;
  final double confidence;
  final List<String> candidateTemplateIds;

  /// §6.2 branching: strong (≥0.75 and a single candidate), none (<0.5 or no
  /// candidate), else weak.
  SuggestionStrength get strength {
    if (candidateTemplateIds.isEmpty || confidence < 0.5) {
      return SuggestionStrength.none;
    }
    if (confidence >= 0.75 && candidateTemplateIds.length == 1) {
      return SuggestionStrength.strong;
    }
    return SuggestionStrength.weak;
  }
}

/// Suggests a Project template from a document snippet using the on-device LLM
/// (blueprint §6.2, creation Path B). Returns `null` whenever the LLM is
/// unavailable (low tier / runtime not wired) or its output can't be parsed — so
/// the caller falls back to the template picker. This is the tier-based graceful
/// degradation from §4.7/§6.2, expressed behind the [LlmBackend] seam.
class DomainInferenceService {
  DomainInferenceService(this._llm, {List<String>? knownTemplateIds})
    : _known = knownTemplateIds ?? _defaultTemplateIds;

  final LlmBackend _llm;
  final List<String> _known;

  static const _defaultTemplateIds = <String>[
    'personal',
    'medical',
    'legal',
    'tax',
    'research',
    'creative',
    'engineering',
    'blank',
  ];

  /// Analyzes [documentSnippet] (the first 1–2 pages of an upload) and returns a
  /// suggestion, or null to fall back. Never throws on an unavailable model.
  Future<DomainSuggestion?> infer(String documentSnippet) async {
    final text = documentSnippet.trim();
    if (text.isEmpty) return null;
    if (!await _llm.isAvailable()) return null;

    final String raw;
    try {
      raw = await _llm.generate(_prompt(text));
    } on LlmUnavailableException {
      return null;
    } catch (_) {
      // Any runtime failure degrades to the fallback path, never crashes.
      return null;
    }
    return _parse(raw);
  }

  String _prompt(String snippet) =>
      'You classify a document into one DocuMink project template. '
      'Allowed template ids: ${_known.join(', ')}. '
      'Reply with ONLY a JSON object: '
      '{"domain": string, "confidence": number 0..1, "candidates": [template_id, ...]}. '
      'Pick 1 candidate if confident, 2-3 if unsure.\n\n'
      'Document:\n"""\n$snippet\n"""';

  /// Extracts the first JSON object from the model output (models often wrap it
  /// in prose), validates candidates against the known ids, and clamps
  /// confidence. Returns null on any parse/shape failure.
  DomainSuggestion? _parse(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw.substring(start, end + 1));
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    final candidates = <String>[
      for (final c in (decoded['candidates'] as List<dynamic>? ?? const []))
        if (c is String && _known.contains(c)) c,
    ];
    final confidence = switch (decoded['confidence']) {
      final num n => n.toDouble().clamp(0.0, 1.0),
      _ => 0.0,
    };
    final domain = decoded['domain'] is String
        ? decoded['domain'] as String
        : '';

    if (candidates.isEmpty) return null;
    return DomainSuggestion(
      domain: domain,
      confidence: confidence,
      candidateTemplateIds: candidates,
    );
  }
}
