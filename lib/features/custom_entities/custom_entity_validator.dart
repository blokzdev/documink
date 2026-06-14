import '../anonymization/operator.dart';
import 'custom_entity_definition.dart';
import 'custom_validators.dart';

/// A single validation problem with a custom-entity form field.
class CustomEntityFormError {
  const CustomEntityFormError(this.field, this.message);
  final String field;
  final String message;

  @override
  String toString() => '$field: $message';
}

/// Validates the "Add Custom Entity" form before persistence (roadmap §6):
/// label, regex (compiles), validator + operator (known), and that any provided
/// examples actually match the pattern and pass the validator. Pure; the
/// ReDoS-safe live-preview sandbox is a separate concern (6b).
class CustomEntityValidator {
  const CustomEntityValidator();

  List<CustomEntityFormError> validate({
    required String label,
    required String regexPattern,
    String validator = 'none',
    required String defaultOperator,
    List<String> examples = const [],
  }) {
    final errors = <CustomEntityFormError>[];

    if (label.trim().isEmpty) {
      errors.add(const CustomEntityFormError('label', 'Label is required'));
    }

    RegExp? compiled;
    if (regexPattern.isEmpty) {
      errors.add(const CustomEntityFormError('regex', 'Pattern is required'));
    } else {
      try {
        compiled = RegExp(regexPattern);
      } on FormatException catch (e) {
        errors.add(
          CustomEntityFormError('regex', 'Invalid pattern: ${e.message}'),
        );
      }
    }

    CustomValidator? parsedValidator;
    try {
      parsedValidator = CustomValidator.fromId(validator);
    } on FormatException catch (e) {
      errors.add(CustomEntityFormError('validator', e.message));
    }

    try {
      Operator.fromPolicyName(defaultOperator);
    } on FormatException catch (e) {
      errors.add(CustomEntityFormError('operator', e.message));
    }

    // Examples must match the pattern and pass the validator (live correctness).
    if (compiled != null) {
      for (final example in examples) {
        final match = compiled.firstMatch(example);
        if (match == null) {
          errors.add(
            CustomEntityFormError(
              'examples',
              'Example "$example" does not match the pattern',
            ),
          );
        } else if (parsedValidator != null &&
            !applyCustomValidator(parsedValidator, match.group(0)!)) {
          errors.add(
            CustomEntityFormError(
              'examples',
              'Example "$example" fails the ${parsedValidator.id} validator',
            ),
          );
        }
      }
    }

    return errors;
  }
}
