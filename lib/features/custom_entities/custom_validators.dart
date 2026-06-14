import 'custom_entity_definition.dart';

/// Applies a [CustomValidator] to a regex match's text (roadmap §6). Returns
/// true if the match should be kept as a span.
bool applyCustomValidator(CustomValidator validator, String matchText) {
  switch (validator) {
    case CustomValidator.none:
      return true;
    case CustomValidator.luhn:
      return _luhnValid(matchText);
  }
}

/// Luhn checksum over the digits in [text] (ignores non-digits so it tolerates
/// separators). False if there are no digits.
bool _luhnValid(String text) {
  var sum = 0;
  var doubleNext = false;
  var seenDigit = false;
  for (var i = text.length - 1; i >= 0; i--) {
    final c = text.codeUnitAt(i);
    if (c < 0x30 || c > 0x39) continue;
    seenDigit = true;
    var d = c - 0x30;
    if (doubleNext) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    doubleNext = !doubleNext;
  }
  return seenDigit && sum % 10 == 0;
}
