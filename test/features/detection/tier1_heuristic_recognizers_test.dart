import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/detection/recognizers/date_recognizer.dart';
import 'package:documink/features/detection/recognizers/mrn_recognizer.dart';
import 'package:documink/features/detection/recognizers/passport_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateRecognizer', () {
    final r = DateRecognizer();

    test('matches ISO, numeric, and textual dates', () {
      expect(r.recognize('on 2020-01-31 today').single.text, '2020-01-31');
      expect(r.recognize('due 1/31/2020.').single.text, '1/31/2020');
      expect(r.recognize('dated 31.01.2020').single.text, '31.01.2020');
      expect(
        r.recognize('born January 5, 2020').single.text,
        'January 5, 2020',
      );
      expect(r.recognize('on 5th Jan 2020').single.text, '5th Jan 2020');
    });

    test('labels as DATE and does not duplicate overlapping patterns', () {
      final spans = r.recognize('2020-01-31');
      expect(spans.length, 1);
      expect(spans.single.label, PiiLabels.date);
    });

    test('ignores invalid month/day numbers', () {
      expect(r.recognize('2020-13-40'), isEmpty);
    });
  });

  group('MrnRecognizer', () {
    final r = MrnRecognizer();

    test(
      'captures the number after an MRN prefix (span excludes the label)',
      () {
        final span = r.recognize('Patient MRN: 1234567 admitted').single;
        expect(span.label, PiiLabels.mrn);
        expect(span.text, '1234567');
      },
    );

    test('matches the "Medical Record No." phrasing', () {
      expect(r.recognize('Medical Record No. 9876543').single.text, '9876543');
    });

    test('does not match bare numbers without the MRN keyword', () {
      expect(r.recognize('order 1234567 shipped'), isEmpty);
    });
  });

  group('PassportRecognizer', () {
    final r = PassportRecognizer();

    test('captures an alphanumeric number after a passport prefix', () {
      expect(r.recognize('Passport No. AB1234567').single.text, 'AB1234567');
      expect(r.recognize('passport: X12345678').single.text, 'X12345678');
    });

    test('requires a digit (ignores letter-only words like "details")', () {
      expect(r.recognize('passport details follow'), isEmpty);
    });

    test('does not match alphanumerics without the passport keyword', () {
      expect(r.recognize('code AB1234567 here'), isEmpty);
    });
  });
}
