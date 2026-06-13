import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

import 'mlkit_entity_recognizer.dart';

/// Builds a [TextAnnotator] backed by ML Kit Entity Extraction (blueprint §4.3,
/// Tier 2). **Device-only:** it calls platform channels and needs the
/// downloaded English entity model, so it is not exercised by headless
/// `flutter test` — the mapping it feeds is tested via a fake annotator in
/// `mlkit_entity_recognizer_test.dart`. Model download/lifecycle (via
/// `EntityExtractorModelManager`) and disposal are wired at Phase 5 bootstrap.
///
/// `EntityType.name` (e.g. `email`, `paymentCard`) is the key
/// `MlKitEntityRecognizer.labelByType` maps from.
TextAnnotator mlKitAnnotator(EntityExtractor extractor) {
  return (String text) async {
    final annotations = await extractor.annotateText(text);
    return [
      for (final annotation in annotations)
        TextAnnotation(
          start: annotation.start,
          end: annotation.end,
          text: annotation.text,
          types: [for (final entity in annotation.entities) entity.type.name],
        ),
    ];
  };
}
