import 'package:documink/features/custom_entities/custom_entity_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = CustomEntityValidator();

  List<String> fields(List<CustomEntityFormError> errors) =>
      errors.map((e) => e.field).toList();

  test('accepts a well-formed definition with matching examples', () {
    final errors = validator.validate(
      label: 'PROVIDER_NPI',
      regexPattern: r'\d{10}',
      validator: 'none',
      defaultOperator: 'redact',
      examples: ['1234567890'],
    );
    expect(errors, isEmpty);
  });

  test('requires a label', () {
    final errors = validator.validate(
      label: '  ',
      regexPattern: r'\d{10}',
      defaultOperator: 'redact',
    );
    expect(fields(errors), contains('label'));
  });

  test('rejects an uncompilable regex', () {
    final errors = validator.validate(
      label: 'X',
      regexPattern: '(',
      defaultOperator: 'redact',
    );
    expect(fields(errors), contains('regex'));
  });

  test('rejects an unknown operator and validator', () {
    final errors = validator.validate(
      label: 'X',
      regexPattern: r'\d+',
      validator: 'sha256',
      defaultOperator: 'obfuscate',
    );
    expect(fields(errors), containsAll(['validator', 'operator']));
  });

  test('flags an example that does not match the pattern', () {
    final errors = validator.validate(
      label: 'X',
      regexPattern: r'\d{10}',
      defaultOperator: 'redact',
      examples: ['not-digits'],
    );
    expect(fields(errors), contains('examples'));
  });

  test('flags an example that fails the luhn validator', () {
    final errors = validator.validate(
      label: 'CARD',
      regexPattern: r'\d{16}',
      validator: 'luhn',
      defaultOperator: 'fpe',
      examples: ['4111111111111112'], // fails Luhn
    );
    expect(fields(errors), contains('examples'));
  });
}
