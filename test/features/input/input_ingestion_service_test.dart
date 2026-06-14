import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/ingested_text.dart';
import 'package:documink/features/input/input_ingestion_service.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:documink/features/input/pdf_page_rasterizer.dart';
import 'package:documink/features/input/pdf_source.dart';
import 'package:documink/features/input/pdf_text_extractor.dart';
import 'package:documink/features/input/temp_file_disposer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/input_fakes.dart';

/// Builds a service; unused seams default to fakes that are never invoked.
InputIngestionService _service({
  OcrRecognizer? ocr,
  ImageInputSource? imageSource,
  PdfSource? pdfSource,
  PdfTextExtractor? pdfTextExtractor,
  PdfPageRasterizer? pdfPageRasterizer,
  TempFileDisposer? tempFileDisposer,
}) => InputIngestionService(
  ocr: ocr ?? FakeOcr(''),
  imageSource: imageSource ?? FakeImageSource(),
  pdfSource: pdfSource ?? FakePdfSource(null),
  pdfTextExtractor: pdfTextExtractor ?? FakePdfTextExtractor(const []),
  pdfPageRasterizer: pdfPageRasterizer ?? FakeRasterizer(),
  tempFileDisposer: tempFileDisposer ?? FakeDisposer(),
);

void main() {
  group('image ingestion', () {
    test(
      'captureFromCamera OCRs the captured image into IngestedText',
      () async {
        final ocr = FakeOcr('John Doe lives at 1 Main St.');
        final service = _service(
          ocr: ocr,
          imageSource: FakeImageSource(
            camera: const PickedImage(path: '/tmp/a.jpg'),
          ),
        );

        final result = await service.captureFromCamera();

        expect(result, isNotNull);
        expect(result!.text, 'John Doe lives at 1 Main St.');
        expect(result.source, InputSourceKind.cameraScan);
        expect(result.warnings, isEmpty);
        expect(result.isEmpty, isFalse);
        expect(ocr.calls.single, '/tmp/a.jpg');
      },
    );

    test('importImage OCRs the picked image and tags the source', () async {
      final service = _service(
        ocr: FakeOcr('Acme Corp invoice'),
        imageSource: FakeImageSource(
          gallery: const PickedImage(path: '/tmp/b.png'),
        ),
      );

      final result = await service.importImage();

      expect(result!.text, 'Acme Corp invoice');
      expect(result.source, InputSourceKind.imageImport);
    });

    test('returns null when the user cancels capture', () async {
      final service = _service(imageSource: FakeImageSource(camera: null));
      expect(await service.captureFromCamera(), isNull);
    });

    test('returns null when the user cancels the picker', () async {
      final service = _service(imageSource: FakeImageSource(gallery: null));
      expect(await service.importImage(), isNull);
    });

    test('empty OCR yields a warning and an empty result', () async {
      final service = _service(
        ocr: FakeOcr('   '),
        imageSource: FakeImageSource(
          camera: const PickedImage(path: '/tmp/c.jpg'),
        ),
      );

      final result = await service.captureFromCamera();

      expect(result!.isEmpty, isTrue);
      expect(result.warnings, isNotEmpty);
    });

    test('OCR failures propagate (never silently empty)', () async {
      final service = _service(
        ocr: FakeOcr('', throwError: true),
        imageSource: FakeImageSource(
          camera: const PickedImage(path: '/tmp/d.jpg'),
        ),
      );

      expect(
        service.captureFromCamera(),
        throwsA(isA<OcrUnavailableException>()),
      );
    });
  });

  group('PDF ingestion', () {
    test('returns null when the user cancels the picker', () async {
      final service = _service(pdfSource: FakePdfSource(null));
      expect(await service.importPdf(), isNull);
    });

    test(
      'uses the text layer and does NOT rasterize/OCR when present',
      () async {
        final ocr = FakeOcr('should-not-be-called');
        final raster = FakeRasterizer();
        final disposer = FakeDisposer();
        final service = _service(
          ocr: ocr,
          pdfSource: FakePdfSource('/tmp/doc.pdf'),
          pdfTextExtractor: FakePdfTextExtractor(const ['Hello world.']),
          pdfPageRasterizer: raster,
          tempFileDisposer: disposer,
        );

        final result = await service.importPdf();

        expect(result!.text, 'Hello world.');
        expect(result.source, InputSourceKind.pdfImport);
        expect(result.pageCount, 1);
        expect(result.warnings, isEmpty);
        expect(raster.rendered, isEmpty);
        expect(ocr.calls, isEmpty);
        // No rasterization → nothing to clean up.
        expect(disposer.disposed, isEmpty);
      },
    );

    test('OCRs a scanned (text-less) page via the rasterizer', () async {
      final ocr = FakeOcr('OCR text from page 1');
      final raster = FakeRasterizer();
      final disposer = FakeDisposer();
      final service = _service(
        ocr: ocr,
        pdfSource: FakePdfSource('/tmp/scan.pdf'),
        pdfTextExtractor: FakePdfTextExtractor(const ['']),
        pdfPageRasterizer: raster,
        tempFileDisposer: disposer,
      );

      final result = await service.importPdf();

      expect(result!.text, 'OCR text from page 1');
      expect(raster.rendered, [0]);
      expect(ocr.calls, ['/tmp/page_0.png']);
      expect(result.warnings.single, contains('Page 1 was scanned'));
      // The rasterized page (PII) is deleted after OCR.
      expect(disposer.disposed, ['/tmp/page_0.png']);
    });

    test('deletes the rasterized page even when OCR throws', () async {
      final raster = FakeRasterizer();
      final disposer = FakeDisposer();
      final service = _service(
        ocr: FakeOcr('', throwError: true),
        pdfSource: FakePdfSource('/tmp/scan.pdf'),
        pdfTextExtractor: FakePdfTextExtractor(const ['']),
        pdfPageRasterizer: raster,
        tempFileDisposer: disposer,
      );

      await expectLater(
        service.importPdf(),
        throwsA(isA<OcrUnavailableException>()),
      );
      // finally{} ran: the PII page-image is not left behind.
      expect(disposer.disposed, ['/tmp/page_0.png']);
    });

    test(
      'multi-page: page markers, mixed text-layer + OCR, page count',
      () async {
        final ocr = FakeOcr('scanned page two');
        final raster = FakeRasterizer();
        final service = _service(
          ocr: ocr,
          pdfSource: FakePdfSource('/tmp/mixed.pdf'),
          // Page 1 has a text layer; page 2 is scanned (empty).
          pdfTextExtractor: FakePdfTextExtractor(const ['Page one body.', '']),
          pdfPageRasterizer: raster,
        );

        final result = await service.importPdf();

        expect(result!.pageCount, 2);
        expect(result.text, contains('--- Page 1 ---'));
        expect(result.text, contains('Page one body.'));
        expect(result.text, contains('--- Page 2 ---'));
        expect(result.text, contains('scanned page two'));
        expect(raster.rendered, [1]); // only the scanned page
        expect(result.warnings.single, contains('Page 2 was scanned'));
      },
    );

    test('warns when nothing could be extracted', () async {
      final service = _service(
        ocr: FakeOcr(''),
        pdfSource: FakePdfSource('/tmp/empty.pdf'),
        pdfTextExtractor: FakePdfTextExtractor(const ['']),
        pdfPageRasterizer: FakeRasterizer(),
      );

      final result = await service.importPdf();

      expect(result!.isEmpty, isTrue);
      expect(
        result.warnings,
        contains('No text could be extracted from the PDF.'),
      );
    });
  });

  group('shared input', () {
    test('ingestSharedText wraps text (no OCR) tagged sharedText', () {
      final ocr = FakeOcr('unused');
      final result = _service(ocr: ocr).ingestSharedText('Shared note.');

      expect(result.text, 'Shared note.');
      expect(result.source, InputSourceKind.sharedText);
      expect(result.warnings, isEmpty);
      expect(ocr.calls, isEmpty); // text is not OCR'd
    });

    test('ingestSharedText warns on empty text', () {
      final result = _service().ingestSharedText('   ');
      expect(result.isEmpty, isTrue);
      expect(result.warnings, isNotEmpty);
    });

    test('ingestSharedImage OCRs the path tagged sharedText', () async {
      final ocr = FakeOcr('Recognized from shared image');
      final result = await _service(ocr: ocr).ingestSharedImage('/tmp/s.jpg');

      expect(result.text, 'Recognized from shared image');
      expect(result.source, InputSourceKind.sharedText);
      expect(ocr.calls, ['/tmp/s.jpg']);
    });
  });

  group('original-source fields (Phase 4c)', () {
    test('captured/imported image carries originalPath + mime', () async {
      final camera = await _service(
        ocr: FakeOcr('x'),
        imageSource: FakeImageSource(
          camera: const PickedImage(path: '/tmp/a.jpg'),
        ),
      ).captureFromCamera();
      expect(camera!.originalPath, '/tmp/a.jpg');
      expect(camera.mime, 'image/jpeg');

      final png = await _service(
        ocr: FakeOcr('x'),
        imageSource: FakeImageSource(
          gallery: const PickedImage(path: '/tmp/b.PNG'),
        ),
      ).importImage();
      expect(png!.mime, 'image/png');
    });

    test('imported PDF carries originalPath + application/pdf', () async {
      final result = await _service(
        pdfSource: FakePdfSource('/tmp/doc.pdf'),
        pdfTextExtractor: FakePdfTextExtractor(const ['text']),
      ).importPdf();
      expect(result!.originalPath, '/tmp/doc.pdf');
      expect(result.mime, 'application/pdf');
    });

    test('shared/pasted text has no original', () {
      final shared = _service().ingestSharedText('hello');
      expect(shared.originalPath, isNull);
      expect(shared.mime, isNull);
    });
  });

  group('unwired seams fail loudly rather than returning empty', () {
    test('image + OCR seams', () async {
      expect(
        const UnavailableOcrRecognizer().recognizeImage('/x'),
        throwsA(isA<OcrUnavailableException>()),
      );
      expect(
        const UnavailableImageInputSource().capturePhoto(),
        throwsA(isA<ImageSourceUnavailableException>()),
      );
    });

    test('PDF seams', () async {
      expect(
        const UnavailablePdfSource().pickPdf(),
        throwsA(isA<PdfSourceUnavailableException>()),
      );
      expect(
        const UnavailablePdfTextExtractor().extractPages('/x'),
        throwsA(isA<PdfTextExtractorUnavailableException>()),
      );
      expect(
        const UnavailablePdfPageRasterizer().renderPageToImage('/x', 0),
        throwsA(isA<PdfPageRasterizerUnavailableException>()),
      );
    });
  });
}
