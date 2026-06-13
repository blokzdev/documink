import 'dart:math';
import 'dart:typed_data';

import 'package:documink/data/tokens_dao.dart';
import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymization_service.dart';
import 'package:documink/features/anonymization/anonymizer.dart';
import 'package:documink/features/anonymization/reversible_operators.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uint8List bytes(int fill) => Uint8List.fromList(List.filled(32, fill));
  final crypto = TokenCrypto(dek: bytes(0x11), fingerprintHmacKey: bytes(0x22));

  AnonymizationService service() => AnonymizationService(
    const Anonymizer(),
    ReversibleOperators(crypto, random: Random(7)),
  );

  DetectedSpan span(int start, int end, String label, String text) =>
      DetectedSpan(
        start: start,
        end: end,
        label: label,
        text: text,
        detector: 'test',
      );

  test(
    'applies reversible + irreversible ops and returns persistable tokens',
    () async {
      const text = 'Hi Alice email a@b.co SSN 123-45-6789';
      expect(text.substring(3, 8), 'Alice');
      expect(text.substring(15, 21), 'a@b.co');
      expect(text.substring(26, 37), '123-45-6789');

      final policy = AnonymizationPolicy.fromYaml('''
PERSON: token_random
EMAIL: encrypt
SSN: redact
''');
      final outcome = await service().anonymize(text, [
        span(3, 8, PiiLabels.person, 'Alice'),
        span(15, 21, PiiLabels.email, 'a@b.co'),
        span(26, 37, PiiLabels.ssn, '123-45-6789'),
      ], policy);

      // One Token-Random record to persist (PERSON); EMAIL is stateless inline.
      expect(outcome.tokens.length, 1);
      final record = outcome.tokens.single;
      expect(record.surrogate, matches(RegExp(r'^<PERSON_[0-9A-Za-z]{6}>$')));

      // The PERSON surrogate is reversible via the stored record...
      expect(await ReversibleOperators(crypto).revealToken(record), 'Alice');
      // ...the redacted text shows surrogate, inline wrapper, and [REDACTED].
      expect(
        outcome.result.text,
        startsWith('Hi ${record.surrogate} email <ENC:'),
      );
      expect(outcome.result.text, endsWith(' SSN [REDACTED]'));
    },
  );

  test(
    'FPE (3c) is format-preserving, keeps last 4, and is reversible',
    () async {
      const text = 'card 4111 1111 1111 1234';
      expect(text.substring(5, 24), '4111 1111 1111 1234');
      final policy = AnonymizationPolicy.fromYaml('CREDIT_CARD: fpe');
      final outcome = await service().anonymize(
        text,
        [span(5, 24, PiiLabels.creditCard, '4111 1111 1111 1234')],
        policy,
        workspaceId: 'ws1',
      );
      expect(outcome.tokens, isEmpty); // FPE is stateless (no token row)
      final fpeValue = outcome.result.text.substring(5, 24);
      expect(fpeValue, matches(RegExp(r'^\d{4} \d{4} \d{4} \d{4}$')));
      expect(fpeValue, isNot('4111 1111 1111 1234'));
      expect(fpeValue.endsWith('1234'), isTrue); // keep last 4
      // Reversible with the same (label, workspaceId, keepClear).
      final reversed = ReversibleOperators(crypto).fpeReverse(
        fpeValue,
        label: PiiLabels.creditCard,
        workspaceId: 'ws1',
        keepClear: 4,
      );
      expect(reversed, '4111 1111 1111 1234');
    },
  );
}
