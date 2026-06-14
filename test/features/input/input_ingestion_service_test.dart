import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/ingested_text.dart';
import 'package:documink/features/input/input_ingestion_service.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake OCR returning a fixed string (or throwing) for the given path.
class _FakeOcr implements OcrRecognizer {
  _FakeOcr(this._text, {this.throwError = false});
  final String _text;
  final bool throwError;
  String? lastPath;

  @override
  Future<String> recognizeImage(String imagePath) async {
    lastPath = imagePath;
    if (throwError) throw const OcrUnavailableException();
    return _text;
  }
}

/// Fake source returning a fixed pick (or null = cancelled) per entry point.
class _FakeImageSource implements ImageInputSource {
  _FakeImageSource({this.camera, this.gallery});
  final PickedImage? camera;
  final PickedImage? gallery;

  @override
  Future<PickedImage?> capturePhoto() async => camera;

  @override
  Future<PickedImage?> pickImage() async => gallery;
}

void main() {
  test('captureFromCamera OCRs the captured image into IngestedText', () async {
    final ocr = _FakeOcr('John Doe lives at 1 Main St.');
    final service = InputIngestionService(
      ocr: ocr,
      imageSource: _FakeImageSource(
        camera: const PickedImage(path: '/tmp/a.jpg'),
      ),
    );

    final result = await service.captureFromCamera();

    expect(result, isNotNull);
    expect(result!.text, 'John Doe lives at 1 Main St.');
    expect(result.source, InputSourceKind.cameraScan);
    expect(result.warnings, isEmpty);
    expect(result.isEmpty, isFalse);
    expect(ocr.lastPath, '/tmp/a.jpg');
  });

  test('importImage OCRs the picked image and tags the source', () async {
    final service = InputIngestionService(
      ocr: _FakeOcr('Acme Corp invoice'),
      imageSource: _FakeImageSource(
        gallery: const PickedImage(path: '/tmp/b.png'),
      ),
    );

    final result = await service.importImage();

    expect(result!.text, 'Acme Corp invoice');
    expect(result.source, InputSourceKind.imageImport);
  });

  test('returns null when the user cancels capture', () async {
    final service = InputIngestionService(
      ocr: _FakeOcr('unused'),
      imageSource: _FakeImageSource(camera: null),
    );

    expect(await service.captureFromCamera(), isNull);
  });

  test('returns null when the user cancels the picker', () async {
    final service = InputIngestionService(
      ocr: _FakeOcr('unused'),
      imageSource: _FakeImageSource(gallery: null),
    );

    expect(await service.importImage(), isNull);
  });

  test('empty OCR yields a warning and an empty result', () async {
    final service = InputIngestionService(
      ocr: _FakeOcr('   '),
      imageSource: _FakeImageSource(
        camera: const PickedImage(path: '/tmp/c.jpg'),
      ),
    );

    final result = await service.captureFromCamera();

    expect(result!.isEmpty, isTrue);
    expect(result.warnings, isNotEmpty);
  });

  test('OCR failures propagate (never silently empty)', () async {
    final service = InputIngestionService(
      ocr: _FakeOcr('', throwError: true),
      imageSource: _FakeImageSource(
        camera: const PickedImage(path: '/tmp/d.jpg'),
      ),
    );

    expect(
      service.captureFromCamera(),
      throwsA(isA<OcrUnavailableException>()),
    );
  });

  test('unwired seams fail loudly rather than returning empty', () async {
    expect(
      const UnavailableOcrRecognizer().recognizeImage('/x'),
      throwsA(isA<OcrUnavailableException>()),
    );
    expect(
      const UnavailableImageInputSource().capturePhoto(),
      throwsA(isA<ImageSourceUnavailableException>()),
    );
    expect(
      const UnavailableImageInputSource().pickImage(),
      throwsA(isA<ImageSourceUnavailableException>()),
    );
  });
}
