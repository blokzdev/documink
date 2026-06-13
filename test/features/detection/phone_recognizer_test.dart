import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/detection/recognizers/phone_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final r = PhoneRecognizer();

  test('detects valid US numbers (international and national format)', () {
    expect(
      r.recognize('call +1 415 555 2671 now').single.label,
      PiiLabels.phone,
    );
    expect(
      r.recognize('call (415) 555-2671 now').single.text,
      '(415) 555-2671',
    );
  });

  test('detects a valid international (+CC) number', () {
    final span = r.recognize('UK office +44 20 7946 0018 today').single;
    expect(span.label, PiiLabels.phone);
    expect(span.text, '+44 20 7946 0018');
  });

  test('rejects look-alikes that fail phone validation', () {
    // SSN, ISO date, and a short order number are not valid phone numbers.
    expect(r.recognize('SSN 123-45-6789'), isEmpty);
    expect(r.recognize('dated 2020-01-31'), isEmpty);
    expect(r.recognize('order 1234567 shipped'), isEmpty);
  });

  test('span offsets index the matched candidate', () {
    const text = 'reach me at +1 415 555 2671.';
    final span = r.recognize(text).single;
    expect(text.substring(span.start, span.end), '+1 415 555 2671');
  });
}
