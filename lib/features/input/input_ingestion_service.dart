import 'image_input_source.dart';
import 'ingested_text.dart';
import 'ocr_recognizer.dart';

/// Orchestrates turning a raw input source into [IngestedText] for the redaction
/// pipeline (roadmap Phase 4 — input handlers).
///
/// Pure-Dart and fully unit-testable: the device-only bits (camera/picker, OCR)
/// are injected as seams ([ImageInputSource], [OcrRecognizer]). This is the
/// headless-verifiable orchestration; the native adapters are device-verified
/// (see VERIFICATION.md).
class InputIngestionService {
  InputIngestionService({
    required OcrRecognizer ocr,
    required ImageInputSource imageSource,
  }) : _ocr = ocr,
       _imageSource = imageSource;

  final OcrRecognizer _ocr;
  final ImageInputSource _imageSource;

  /// Capture a page with the camera and OCR it. Returns null if the user
  /// cancels the capture; throws [OcrUnavailableException] /
  /// [ImageSourceUnavailableException] when a seam is unwired.
  Future<IngestedText?> captureFromCamera() async {
    final picked = await _imageSource.capturePhoto();
    if (picked == null) return null;
    return _ingestImage(picked, InputSourceKind.cameraScan);
  }

  /// Pick an image from the system photo picker and OCR it. Returns null if the
  /// user cancels.
  Future<IngestedText?> importImage() async {
    final picked = await _imageSource.pickImage();
    if (picked == null) return null;
    return _ingestImage(picked, InputSourceKind.imageImport);
  }

  Future<IngestedText> _ingestImage(
    PickedImage picked,
    InputSourceKind kind,
  ) async {
    final recognized = await _ocr.recognizeImage(picked.path);
    return IngestedText(
      text: recognized,
      source: kind,
      warnings: recognized.trim().isEmpty
          ? const ['No text was recognized in the image.']
          : const [],
    );
  }
}
