import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_recognizer.dart';

/// Production [OcrRecognizer] backed by ML Kit Text Recognition (Latin script).
///
/// **Device-only:** `processImage` runs the on-device OCR model via platform
/// channels, so this adapter is not exercised by headless `flutter test` — the
/// orchestration it feeds is tested with a fake recognizer
/// (`input_ingestion_service_test.dart`). Wired at bootstrap; OCR accuracy and
/// the model download are device-verified (VERIFICATION.md). The Latin model is
/// declared in `AndroidManifest.xml` (`com.google.mlkit.vision.DEPENDENCIES`)
/// so it installs with the app.
class MlKitTextRecognizer implements OcrRecognizer {
  MlKitTextRecognizer([TextRecognizer? recognizer])
    : _recognizer =
          recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> recognizeImage(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  /// Releases the native recognizer. Call when the app shuts down.
  Future<void> dispose() => _recognizer.close();
}
