import '../detection/pii_span.dart';
import 'anonymization_policy.dart';
import 'anonymizer.dart';
import 'operator.dart';
import 'reversible_operators.dart';

/// Card-style labels keep their last 4 digits in the clear under FPE (§7.1).
const int _cardKeepClear = 4;

/// Anonymized text plus the [TokenRecord]s that the pipeline must persist
/// (one per Token-Random replacement) so the tokens are reversible later.
class AnonymizationOutcome {
  const AnonymizationOutcome({
    required this.result,
    required this.tokens,
    this.tokensBySpan = const {},
  });

  final AnonymizationResult result;

  /// All minted token records, in document-iteration order.
  final List<TokenRecord> tokens;

  /// The token record for each Token-Random span, so persistence can link a
  /// `tokens` row to its owning `entities` row (blueprint §3.1).
  final Map<DetectedSpan, TokenRecord> tokensBySpan;
}

/// Orchestrates anonymization end-to-end: it pre-computes the reversible
/// surrogates (async crypto — Token-Random ciphertext, inline Encrypt) and then
/// delegates to the synchronous [Anonymizer] for offset-correct replacement.
/// This keeps 3a's [Anonymizer] pure/sync while supporting async vault crypto.
///
/// FPE (FF1) is wired in 3c; until then a policy that maps a label to `fpe`
/// throws [UnsupportedError] rather than silently mis-handling it.
class AnonymizationService {
  const AnonymizationService(this._anonymizer, this._reversible);

  final Anonymizer _anonymizer;
  final ReversibleOperators _reversible;

  Future<AnonymizationOutcome> anonymize(
    String text,
    List<DetectedSpan> spans,
    AnonymizationPolicy policy, {
    String workspaceId = '',
  }) async {
    final surrogates = <DetectedSpan, String>{};
    final tokens = <TokenRecord>[];
    final tokensBySpan = <DetectedSpan, TokenRecord>{};

    for (final span in spans) {
      final op = policy.operatorFor(span.label);
      switch (op) {
        case Operator.tokenRandom:
          final record = await _reversible.tokenize(span.text, span.label);
          surrogates[span] = record.surrogate;
          tokens.add(record);
          tokensBySpan[span] = record;
        case Operator.encrypt:
          surrogates[span] = await _reversible.encryptInline(span.text);
        case Operator.fpe:
          surrogates[span] = _reversible.fpe(
            span.text,
            label: span.label,
            workspaceId: workspaceId,
            keepClear: span.label == PiiLabels.creditCard ? _cardKeepClear : 0,
          );
        case Operator.redact:
        case Operator.mask:
        case Operator.replace:
          break; // handled synchronously by the Anonymizer
      }
    }

    final result = _anonymizer.apply(
      text,
      spans,
      policy,
      reversible: (span, _) => surrogates[span]!,
    );
    return AnonymizationOutcome(
      result: result,
      tokens: tokens,
      tokensBySpan: tokensBySpan,
    );
  }
}
