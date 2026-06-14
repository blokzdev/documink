import '../detection/pii_recognizer.dart';
import '../detection/pii_span.dart';
import 'custom_entity_definition.dart';
import 'custom_validators.dart';

/// A [PiiRecognizer] that runs the user's [CustomEntityDefinition]s over the
/// normalized text (roadmap §6). Each compiled pattern's matches become spans
/// (after the entity's validator), labelled with the entity's `label`.
///
/// Patterns are compiled once at construction. The definitions should already
/// be vetted by `CustomEntityValidator`; ReDoS-safe execution for *live preview*
/// is handled by the sandbox (6b).
class CustomEntityRecognizer implements PiiRecognizer {
  CustomEntityRecognizer(
    List<CustomEntityDefinition> entities, {
    this.priority = 5,
  }) : _compiled = [
         for (final e in entities) (entity: e, regExp: RegExp(e.regexPattern)),
       ];

  final List<({CustomEntityDefinition entity, RegExp regExp})> _compiled;

  @override
  final int priority;

  @override
  String get name => 'custom';

  @override
  List<DetectedSpan> recognize(String text) {
    final spans = <DetectedSpan>[];
    for (final c in _compiled) {
      for (final match in c.regExp.allMatches(text)) {
        if (match.end <= match.start) continue; // skip zero-width matches
        final matchText = match.group(0)!;
        if (!applyCustomValidator(c.entity.validator, matchText)) continue;
        spans.add(
          DetectedSpan(
            start: match.start,
            end: match.end,
            label: c.entity.label,
            text: matchText,
            detector: name,
            priority: priority,
          ),
        );
      }
    }
    return spans;
  }
}
