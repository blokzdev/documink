import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects IPv4 and (common-form) IPv6 addresses (blueprint §4.2).
///
/// IPv4 octets are range-checked (0–255) in the regex. IPv6 covers the full
/// 8-group form and `::` compression (including IPv4-mapped tails) pragmatically
/// — not every exotic RFC 4291 edge, which is acceptable for redaction.
class IpAddressRecognizer extends RegexRecognizer {
  @override
  String get name => 'ip_address';

  @override
  String get label => PiiLabels.ipAddress;

  @override
  RegExp get pattern => _pattern;

  static const String _octet = r'(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)';

  static final RegExp _pattern = RegExp(
    // IPv4
    r'(?<![\w.])(?:'
    '$_octet'
    r'\.){3}'
    '$_octet'
    r'(?![\w.])'
    // IPv6 (full and :: compressed)
    r'|(?<![\w:])(?:'
    r'(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}'
    r'|(?:[A-Fa-f0-9]{1,4}:){1,7}:'
    r'|(?:[A-Fa-f0-9]{1,4}:){1,6}:[A-Fa-f0-9]{1,4}'
    r'|(?:[A-Fa-f0-9]{1,4}:){1,5}(?::[A-Fa-f0-9]{1,4}){1,2}'
    r'|(?:[A-Fa-f0-9]{1,4}:){1,4}(?::[A-Fa-f0-9]{1,4}){1,3}'
    r'|(?:[A-Fa-f0-9]{1,4}:){1,3}(?::[A-Fa-f0-9]{1,4}){1,4}'
    r'|(?:[A-Fa-f0-9]{1,4}:){1,2}(?::[A-Fa-f0-9]{1,4}){1,5}'
    r'|[A-Fa-f0-9]{1,4}:(?::[A-Fa-f0-9]{1,4}){1,6}'
    r'|:(?::[A-Fa-f0-9]{1,4}){1,7}'
    r'|::'
    r')(?![\w:])',
  );

  @override
  double scoreFor(RegExpMatch match) => 0.9;
}
