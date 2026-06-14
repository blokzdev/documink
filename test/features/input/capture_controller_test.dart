import 'package:documink/features/input/capture_controller.dart';
import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/ingested_text.dart';
import 'package:documink/features/input/input_providers.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:documink/features/input/pdf_source.dart';
import 'package:documink/features/input/pdf_text_extractor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/input_fakes.dart';

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
      ocr: FakeOcr('x'),
      source: FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );
    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });

  test('scan success moves to ready with the ingested text', () async {
    final c = _container(
      ocr: FakeOcr('Patient: Jane Roe'),
      source: FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );

    await c.read(captureControllerProvider.notifier).scan();

    final state = c.read(captureControllerProvider);
    expect(state.status, CaptureStatus.ready);
    expect(state.result!.text, 'Patient: Jane Roe');
    expect(state.result!.source, InputSourceKind.cameraScan);
  });

  test('cancelled pick returns to idle', () async {
    final c = _container(
      ocr: FakeOcr('unused'),
      source: FakeImageSource(pick: null),
    );

    await c.read(captureControllerProvider.notifier).importImage();

    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });

  test('OCR failure surfaces as error state', () async {
    final c = _container(
      ocr: FakeOcr('', throwError: true),
      source: FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );

    await c.read(captureControllerProvider.notifier).scan();

    final state = c.read(captureControllerProvider);
    expect(state.status, CaptureStatus.error);
    expect(state.error, isNotNull);
  });

  test('reset clears back to idle', () async {
    final c = _container(
      ocr: FakeOcr('hello'),
      source: FakeImageSource(pick: const PickedImage(path: '/a.jpg')),
    );

    await c.read(captureControllerProvider.notifier).scan();
    c.read(captureControllerProvider.notifier).reset();

    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });

  test('importPdf success moves to ready with the extracted text', () async {
    final c = _container(
      ocr: FakeOcr('unused'),
      source: FakeImageSource(),
      pdfSource: FakePdfSource('/tmp/doc.pdf'),
      pdfTextExtractor: FakePdfTextExtractor(const ['Contract body.']),
    );

    await c.read(captureControllerProvider.notifier).importPdf();

    final state = c.read(captureControllerProvider);
    expect(state.status, CaptureStatus.ready);
    expect(state.result!.text, 'Contract body.');
    expect(state.result!.source, InputSourceKind.pdfImport);
  });

  test('importPdf cancel returns to idle', () async {
    final c = _container(
      ocr: FakeOcr('unused'),
      source: FakeImageSource(),
      pdfSource: FakePdfSource(null),
    );

    await c.read(captureControllerProvider.notifier).importPdf();

    expect(c.read(captureControllerProvider).status, CaptureStatus.idle);
  });
}
