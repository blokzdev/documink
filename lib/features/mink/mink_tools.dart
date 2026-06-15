import 'dart:convert';

/// A tool call Mink emitted in its completion. Mink requests a tool by replying
/// with a single JSON object `{"tool": <name>, "args": {…}}`; anything else is a
/// plain assistant reply (blueprint §5 dispatch flow).
class MinkToolInvocation {
  const MinkToolInvocation(this.name, [this.args = const {}]);

  final String name;
  final Map<String, dynamic> args;
}

/// Extracts a tool invocation from a raw LLM completion, mirroring the tolerant
/// JSON-extraction used by `DomainInferenceService` (first `{` … last `}` →
/// `jsonDecode`). Returns null when the completion is not a tool call — that is
/// the signal to treat the text as Mink's final answer.
MinkToolInvocation? parseToolInvocation(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) return null;

  Object? decoded;
  try {
    decoded = jsonDecode(raw.substring(start, end + 1));
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;

  final name = decoded['tool'];
  if (name is! String || name.isEmpty) return null;

  final args = decoded['args'];
  return MinkToolInvocation(
    name,
    args is Map ? args.cast<String, dynamic>() : const {},
  );
}
