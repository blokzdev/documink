import 'input_exceptions.dart';

/// Recognizes text in an image file (a camera capture or an imported photo).
///
/// Device-only in production (ML Kit Text Recognition runs on-device via
/// platform channels + a downloaded Latin model). Kept behind this interface so
/// [InputIngestionService] orchestration is fully unit-testable with a fake; the
/// production adapter lives in `mlkit_text_recognizer.dart` and is composed at
/// bootstrap.
abstract interface class OcrRecognizer {
  /// Returns the recognized text for the image at [imagePath]. May be an empty
  /// string when the image contains no detectable text.
  Future<String> recognizeImage(String imagePath);
}

/// Thrown when OCR is requested but no platform recognizer was wired (the safe
/// default). Surfaces a clear, user-facing message rather than silently
/// returning empty text.
class OcrUnavailableException implements InputUnavailableException {
  const OcrUnavailableException();

  @override
  String toString() => 'Text recognition is not available on this device.';
}

/// Safe default [OcrRecognizer] — fails loudly until the real recognizer is
/// composed at bootstrap. Never silently yields empty text (which would look
/// like "no PII found" and risk leaking unredacted content).
class UnavailableOcrRecognizer implements OcrRecognizer {
  const UnavailableOcrRecognizer();

  @override
  Future<String> recognizeImage(String imagePath) async =>
      throw const OcrUnavailableException();
}
