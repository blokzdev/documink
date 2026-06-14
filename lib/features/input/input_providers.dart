import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_input_source.dart';
import 'input_ingestion_service.dart';
import 'ocr_recognizer.dart';

/// On-device text recognizer. Defaults to the always-failing
/// [UnavailableOcrRecognizer]; bootstrap overrides it with `MlKitTextRecognizer`
/// and tests override it with a fake.
final ocrRecognizerProvider = Provider<OcrRecognizer>(
  (ref) => const UnavailableOcrRecognizer(),
);

/// Camera / photo-picker source. Defaults to [UnavailableImageInputSource];
/// bootstrap overrides it with `SystemImageSource`, tests with a fake.
final imageInputSourceProvider = Provider<ImageInputSource>(
  (ref) => const UnavailableImageInputSource(),
);

/// The pure-Dart ingestion orchestrator, composed from the two seams above.
final inputIngestionServiceProvider = Provider<InputIngestionService>(
  (ref) => InputIngestionService(
    ocr: ref.watch(ocrRecognizerProvider),
    imageSource: ref.watch(imageInputSourceProvider),
  ),
);
