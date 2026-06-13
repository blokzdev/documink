import '../detection/pii_span.dart';
import 'anonymization_policy.dart';
import 'operator.dart';

/// A single applied replacement (for audit + reversal bookkeeping).
class AppliedOperator {
  const AppliedOperator({
    required this.span,
    required this.operator,
    required this.replacement,
  });

  final DetectedSpan span;
  final Operator operator;
  final String replacement;
}

/// The output of anonymization: the transformed text plus the operators applied
/// (in document order).
class AnonymizationResult {
  const AnonymizationResult({required this.text, required this.applied});

  final String text;
  final List<AppliedOperator> applied;
}

/// Computes the surrogate for a reversible operator (Token-Random/FPE/Encrypt).
/// Supplied by the vault-backed layer (3b/3c); absent in 3a.
typedef ReversibleSurrogate =
    String Function(DetectedSpan span, Operator operator);

/// Applies a policy's operators to detected spans, producing redacted text
/// (blueprint §4 "Apply operators" stage).
///
/// 3a implements the irreversible operators (Redact/Mask/Replace) as pure text
/// transforms. Reversible operators are delegated to an injected
/// [ReversibleSurrogate]; if one is encountered without a resolver, that is a
/// programming error ([StateError]) — the vault-backed layer wires it in 3b/3c.
///
/// Replacements are applied right-to-left so each span's offsets (into the
/// normalized text) stay valid as earlier text is rewritten.
class Anonymizer {
  const Anonymizer({
    this.maskChar = '•',
    this.redactPlaceholder = '[REDACTED]',
  });

  final String maskChar;
  final String redactPlaceholder;

  AnonymizationResult apply(
    String text,
    List<DetectedSpan> spans,
    AnonymizationPolicy policy, {
    ReversibleSurrogate? reversible,
  }) {
    final ordered = [...spans]..sort((a, b) => b.start.compareTo(a.start));
    final applied = <AppliedOperator>[];
    var out = text;
    for (final span in ordered) {
      final op = policy.operatorFor(span.label);
      final replacement = _replacement(span, op, reversible);
      out = out.replaceRange(span.start, span.end, replacement);
      applied.add(
        AppliedOperator(span: span, operator: op, replacement: replacement),
      );
    }
    // Return in document order.
    return AnonymizationResult(
      text: out,
      applied: applied.reversed.toList(growable: false),
    );
  }

  String _replacement(
    DetectedSpan span,
    Operator op,
    ReversibleSurrogate? reversible,
  ) {
    switch (op) {
      case Operator.redact:
        return redactPlaceholder;
      case Operator.mask:
        return maskChar * span.text.length;
      case Operator.replace:
        return '<${span.label}>';
      case Operator.tokenRandom:
      case Operator.fpe:
      case Operator.encrypt:
        if (reversible == null) {
          throw StateError(
            'Reversible operator ${op.policyName} requires a vault-backed '
            'resolver (wired in 3b/3c); none supplied.',
          );
        }
        return reversible(span, op);
    }
  }
}
