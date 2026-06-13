import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/detection/recognizers/credit_card_recognizer.dart';
import 'package:documink/features/detection/recognizers/email_recognizer.dart';
import 'package:documink/features/detection/recognizers/iban_recognizer.dart';
import 'package:documink/features/detection/recognizers/ip_address_recognizer.dart';
import 'package:documink/features/detection/recognizers/ssn_recognizer.dart';
import 'package:documink/features/detection/recognizers/url_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmailRecognizer', () {
    final r = EmailRecognizer();

    test('matches valid addresses with correct offsets', () {
      const text = 'contact a.b+c@sub.example.co.uk now';
      final spans = r.recognize(text);
      expect(spans.length, 1);
      expect(spans.single.label, PiiLabels.email);
      expect(spans.single.text, 'a.b+c@sub.example.co.uk');
      expect(
        text.substring(spans.single.start, spans.single.end),
        'a.b+c@sub.example.co.uk',
      );
    });

    test('rejects malformed addresses', () {
      expect(r.recognize('no-tld@example'), isEmpty);
      expect(r.recognize('@example.com'), isEmpty);
    });
  });

  group('UrlRecognizer', () {
    final r = UrlRecognizer();

    test('matches http(s) and www, excluding trailing punctuation', () {
      final spans = r.recognize(
        'see https://example.com/path. and www.foo.org',
      );
      expect(spans.map((s) => s.text), [
        'https://example.com/path',
        'www.foo.org',
      ]);
      expect(spans.every((s) => s.label == PiiLabels.url), isTrue);
    });
  });

  group('IpAddressRecognizer', () {
    final r = IpAddressRecognizer();

    test('matches valid IPv4 and range-checks octets', () {
      expect(r.recognize('host 192.168.1.1 up').single.text, '192.168.1.1');
      expect(r.recognize('255.255.255.255').single.text, '255.255.255.255');
      expect(r.recognize('999.1.1.1'), isEmpty);
    });

    test('matches IPv6 full and compressed forms', () {
      expect(r.recognize('addr 2001:db8::1 end').single.text, '2001:db8::1');
      expect(r.recognize('loopback ::1').single.text, '::1');
      expect(
        r.recognize('2001:0db8:0000:0000:0000:0000:0000:0001').single.text,
        '2001:0db8:0000:0000:0000:0000:0000:0001',
      );
    });
  });

  group('SsnRecognizer', () {
    final r = SsnRecognizer();

    test('matches valid SSNs (dash and space separators)', () {
      expect(r.recognize('SSN 123-45-6789.').single.text, '123-45-6789');
      expect(r.recognize('123 45 6789').single.text, '123 45 6789');
    });

    test('rejects structurally invalid SSNs', () {
      for (final bad in [
        '000-12-3456',
        '666-12-3456',
        '900-12-3456',
        '123-00-6789',
        '123-45-0000',
      ]) {
        expect(r.recognize(bad), isEmpty, reason: bad);
      }
    });
  });

  group('CreditCardRecognizer', () {
    final r = CreditCardRecognizer();

    test('matches Luhn-valid numbers (grouped or contiguous)', () {
      expect(
        r.recognize('4111 1111 1111 1111').single.text,
        '4111 1111 1111 1111',
      );
      expect(r.recognize('5555555555554444').single.text, '5555555555554444');
    });

    test('rejects Luhn-invalid and too-short numbers', () {
      expect(r.recognize('4111 1111 1111 1112'), isEmpty);
      expect(r.recognize('1234 5678 9012'), isEmpty); // 12 digits
    });
  });

  group('IbanRecognizer', () {
    final r = IbanRecognizer();

    test('matches mod-97-valid IBANs', () {
      expect(
        r.recognize('GB82WEST12345698765432').single.text,
        'GB82WEST12345698765432',
      );
      expect(
        r.recognize('DE89370400440532013000').single.text,
        'DE89370400440532013000',
      );
    });

    test('rejects IBANs that fail the checksum', () {
      expect(r.recognize('GB82WEST12345698765431'), isEmpty);
    });
  });

  group('pipeline with Tier 1 recognizers', () {
    test('detects multiple entity types in one document', () async {
      final pipeline = DetectionPipeline([
        EmailRecognizer(),
        UrlRecognizer(),
        IpAddressRecognizer(),
        SsnRecognizer(),
        CreditCardRecognizer(),
        IbanRecognizer(),
      ]);
      final result = await pipeline.detect(
        'Email alice@example.com, SSN 123-45-6789, card 4111 1111 1111 1111, '
        'IP 10.0.0.1, IBAN GB82WEST12345698765432, site https://x.io',
      );
      final labels = result.spans.map((s) => s.label).toSet();
      expect(
        labels,
        containsAll(<String>{
          PiiLabels.email,
          PiiLabels.ssn,
          PiiLabels.creditCard,
          PiiLabels.ipAddress,
          PiiLabels.iban,
          PiiLabels.url,
        }),
      );
      // Spans are non-overlapping and sorted by start.
      for (var i = 1; i < result.spans.length; i++) {
        expect(result.spans[i].start >= result.spans[i - 1].end, isTrue);
      }
    });
  });
}
