import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/input_providers.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:documink/features/input/pdf_page_rasterizer.dart';
import 'package:documink/features/input/pdf_source.dart';
import 'package:documink/features/input/pdf_text_extractor.dart';
import 'package:documink/features/input/temp_file_disposer.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOcr implements OcrRecognizer {
  _FakeOcr(this._text);
  final String _text;
  @override
  Future<String> recognizeImage(String imagePath) async => _text;
}

class _FakeImageSource implements ImageInputSource {
  _FakeImageSource(this._pick);
  final PickedImage? _pick;
  @override
  Future<PickedImage?> capturePhoto() async => _pick;
  @override
  Future<PickedImage?> pickImage() async => _pick;
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

class _FakeRasterizer implements PdfPageRasterizer {
  @override
  Future<String> renderPageToImage(String path, int pageIndex) async =>
      '/tmp/p$pageIndex.png';
}

/// No-op disposer — widget tests must not touch the real filesystem (real
/// dart:io async stalls pumpAndSettle under the fake-async clock).
class _NoopDisposer implements TempFileDisposer {
  const _NoopDisposer();
  @override
  Future<void> dispose(String path) async {}
}

Future<void> _pump(
  WidgetTester tester, {
  required CaptureMode mode,
  OcrRecognizer? ocr,
  ImageInputSource? source,
  PdfSource? pdfSource,
  PdfTextExtractor? pdfTextExtractor,
  PdfPageRasterizer? pdfPageRasterizer,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ocrRecognizerProvider.overrideWithValue(ocr ?? _FakeOcr('x')),
        imageInputSourceProvider.overrideWithValue(
          source ?? _FakeImageSource(const PickedImage(path: '/a.jpg')),
        ),
        if (pdfSource != null) pdfSourceProvider.overrideWithValue(pdfSource),
        if (pdfTextExtractor != null)
          pdfTextExtractorProvider.overrideWithValue(pdfTextExtractor),
        if (pdfPageRasterizer != null)
          pdfPageRasterizerProvider.overrideWithValue(pdfPageRasterizer),
        tempFileDisposerProvider.overrideWithValue(const _NoopDisposer()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaptureScreen(mode: mode),
      ),
    ),
  );
}

void main() {
  testWidgets('scan mode shows capture + gallery affordances', (tester) async {
    await _pump(tester, mode: CaptureMode.scan);
    expect(find.text('Capture page'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
  });

  testWidgets('import mode shows image + PDF affordances', (tester) async {
    await _pump(tester, mode: CaptureMode.import);
    expect(find.text('Choose image'), findsOneWidget);
    expect(find.text('Choose PDF'), findsOneWidget);
  });

  testWidgets('capture → OCR shows recognized text, badge, redact action', (
    tester,
  ) async {
    await _pump(
      tester,
      mode: CaptureMode.scan,
      ocr: _FakeOcr('Contact alice@example.com'),
      source: _FakeImageSource(const PickedImage(path: '/a.jpg')),
    );

    await tester.tap(find.text('Capture page'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recognized-text')), findsOneWidget);
    expect(find.textContaining('alice@example.com'), findsOneWidget);
    expect(find.text('Redact this text'), findsOneWidget);
    // Source badge.
    expect(find.text('Camera scan'), findsOneWidget);
  });

  testWidgets('PDF import shows extracted text, PDF badge with page count', (
    tester,
  ) async {
    await _pump(
      tester,
      mode: CaptureMode.import,
      pdfSource: _FakePdfSource('/tmp/doc.pdf'),
      pdfTextExtractor: _FakePdfTextExtractor(const ['Page one.', 'Page two.']),
      pdfPageRasterizer: _FakeRasterizer(),
    );

    await tester.tap(find.text('Choose PDF'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Page one.'), findsOneWidget);
    expect(find.textContaining('PDF · 2 pages'), findsOneWidget);
    expect(find.text('Redact this text'), findsOneWidget);
  });

  testWidgets('scanned PDF surfaces the OCR warning', (tester) async {
    await _pump(
      tester,
      mode: CaptureMode.import,
      ocr: _FakeOcr('recognized from scan'),
      pdfSource: _FakePdfSource('/tmp/scan.pdf'),
      pdfTextExtractor: _FakePdfTextExtractor(const ['']),
      pdfPageRasterizer: _FakeRasterizer(),
    );

    await tester.tap(find.text('Choose PDF'));
    await tester.pumpAndSettle();

    expect(find.textContaining('was scanned — used OCR'), findsOneWidget);
    expect(find.textContaining('recognized from scan'), findsOneWidget);
  });

  testWidgets('empty OCR shows a warning and no redact action', (tester) async {
    await _pump(
      tester,
      mode: CaptureMode.import,
      ocr: _FakeOcr('   '),
      source: _FakeImageSource(const PickedImage(path: '/a.jpg')),
    );

    await tester.tap(find.text('Choose image'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No text was recognized'), findsOneWidget);
    expect(find.text('Redact this text'), findsNothing);
  });

  testWidgets('a recognition failure shows the error state', (tester) async {
    await _pump(
      tester,
      mode: CaptureMode.scan,
      ocr: const UnavailableOcrRecognizer(),
      source: _FakeImageSource(const PickedImage(path: '/a.jpg')),
    );

    await tester.tap(find.text('Capture page'));
    await tester.pumpAndSettle();

    expect(find.text('Could not read that'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
