import 'dart:async';

import '../pii_recognizer.dart';
import '../pii_span.dart';

/// A plugin-agnostic text annotation (offset range + the ML Kit entity type
/// names found there). Keeping this decoupled from `google_mlkit_*` types lets
/// the mapping logic be unit-tested without platform channels; the production
/// adapter (`mlkit_annotator.dart`) converts the plugin's `EntityAnnotation`
/// into this shape on-device.
class TextAnnotation {
  const TextAnnotation({
    required this.start,
    required this.end,
    required this.text,
    required this.types,
  });

  final int start;
  final int end;
  final String text;

  /// ML Kit `EntityType` names present at this range (e.g. `email`, `phone`).
  final List<String> types;
}

/// Produces annotations for [text] — `EntityExtractor.annotateText` (adapted) in
/// production; a fake in tests.
typedef TextAnnotator = Future<List<TextAnnotation>> Function(String text);

/// Tier 2 recognizer (blueprint §4.1/§4.3) wrapping ML Kit Entity Extraction.
///
/// The native annotation + on-device model are injected as a [TextAnnotator],
/// so this class — including the ML-Kit-type → [PiiLabels] mapping — is fully
/// unit-testable. Tier 2 outranks Tier 1 on overlap ties (higher [priority]),
/// being more context-aware.
class MlKitEntityRecognizer extends PiiRecognizer {
  MlKitEntityRecognizer(this._annotator);

  final TextAnnotator _annotator;

  /// Tier 2 overlap priority (above Tier 1's 10).
  static const int tier2Priority = 20;

  /// ML Kit `EntityType` name → DocuMink label. Types with no PII meaning
  /// (isbn, money, flightNumber, trackingNumber, unknown) are intentionally
  /// absent and dropped.
  static const Map<String, String> labelByType = {
    'email': PiiLabels.email,
    'phone': PiiLabels.phone,
    'iban': PiiLabels.iban,
    'paymentCard': PiiLabels.creditCard,
    'url': PiiLabels.url,
    'address': PiiLabels.location,
    'dateTime': PiiLabels.date,
  };

  @override
  String get name => 'mlkit';

  @override
  int get priority => tier2Priority;

  @override
  Future<List<DetectedSpan>> recognize(String text) async {
    final annotations = await _annotator(text);
    final spans = <DetectedSpan>[];
    for (final annotation in annotations) {
      final label = _labelFor(annotation.types);
      if (label == null) continue;
      spans.add(
        DetectedSpan(
          start: annotation.start,
          end: annotation.end,
          label: label,
          text: annotation.text,
          detector: name,
          score: 0.9,
          priority: priority,
        ),
      );
    }
    return spans;
  }

  /// First mappable type wins (ML Kit may report several for one range).
  String? _labelFor(List<String> types) {
    for (final type in types) {
      final label = labelByType[type];
      if (label != null) return label;
    }
    return null;
  }
}
