import 'package:documink/features/input/capture_controller.dart';
import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/ingested_text.dart';
import 'package:documink/features/input/input_providers.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:documink/features/input/pdf_source.dart';
import 'package:documink/features/input/pdf_text_extractor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOcr implements OcrRecognizer {
  _FakeOcr(this._text, {this.throwError = false});
  final String _text;
  final bool throwError;
  @override
  Future<String> recognizeImage(String imagePath) async {
    if (throwError) throw const OcrUnavailableException();
    return _text;
  }
}

class _FakeImageSource implements ImageInputSource {
  _FakeImageSource({this.pick});
  final PickedImage? pick;
  @override
  Future<PickedImage?> capturePhoto() async => pick;
  @override
  Future<PickedImage?> pickImage() async => pick;
}

class _FakePdfSource implements PdfSource {
  _FakePdfSource(this._path);
  final String? _path;
  @override
  Future<String?> pickPdf() async => _path;
}

class _FakePdfTextExtractor implements PdfTextExtractor {
  _FakePdfTextExtractor(this._pages);
  final List<String> _pages;
  @override
  Future<List<String>> extractPages(String path) async => _pages;
}

ProviderContainer _container({
  required OcrRecognizer ocr,
  required ImageInputSource source,
  PdfSource? pdfSource,
  PdfTextExtractor? pdfTextExtractor,
}) {
  final container = ProviderContainer(
    overrides: [
      ocrRecognizerProvider.overrideWithValue(ocr),
      imageInputSourceProvider.overrideWithValue(source),
      if (pdfSource != null) pdfSourceProvider.overrideWithValue(pdfSource),
      if (pdfTextExtractor != null)
        pdfTextExtractorProvider.overrideWithValue(pdfTextExtractor),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('starts idle', () {
    final c = _container(
      ocr: _FakeOcr('x'),
      source: _FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );
    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });

  test('scan success moves to ready with the ingested text', () async {
    final c = _container(
      ocr: _FakeOcr('Patient: Jane Roe'),
      source: _FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );

    await c.read(captureControllerProvider.notifier).scan();

    final state = c.read(captureControllerProvider);
    expect(state.status, CaptureStatus.ready);
    expect(state.result!.text, 'Patient: Jane Roe');
    expect(state.result!.source, InputSourceKind.cameraScan);
  });

  test('cancelled pick returns to idle', () async {
    final c = _container(
      ocr: _FakeOcr('unused'),
      source: _FakeImageSource(pick: null),
    );

    await c.read(captureControllerProvider.notifier).importImage();

    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });

  test('OCR failure surfaces as error state', () async {
    final c = _container(
      ocr: _FakeOcr('', throwError: true),
      source: _FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );

    await c.read(captureControllerProvider.notifier).scan();

    final state = c.read(captureControllerProvider);
    expect(state.status, CaptureStatus.error);
    expect(state.error, isNotNull);
  });

  test('reset clears back to idle', () async {
    final c = _container(
      ocr: _FakeOcr('hello'),
      source: _FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );

    await c.read(captureControllerProvider.notifier).scan();
    c.read(captureControllerProvider.notifier).reset();

    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });

  test('importPdf success moves to ready with the extracted text', () async {
    final c = _container(
      ocr: _FakeOcr('unused'),
      source: _FakeImageSource(),
      pdfSource: _FakePdfSource('/tmp/doc.pdf'),
      pdfTextExtractor: _FakePdfTextExtractor(const ['Contract body.']),
    );

    await c.read(captureControllerProvider.notifier).importPdf();

    final state = c.read(captureControllerProvider);
    expect(state.status, CaptureStatus.ready);
    expect(state.result!.text, 'Contract body.');
    expect(state.result!.source, InputSourceKind.pdfImport);
  });

  test('importPdf cancel returns to idle', () async {
    final c = _container(
      ocr: _FakeOcr('unused'),
      source: _FakeImageSource(),
      pdfSource: _FakePdfSource(null),
    );

    await c.read(captureControllerProvider.notifier).importPdf();

    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });
}
