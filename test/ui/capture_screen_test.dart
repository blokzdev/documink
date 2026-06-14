import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/input_providers.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
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

Future<void> _pump(
  WidgetTester tester, {
  required CaptureMode mode,
  required OcrRecognizer ocr,
  required ImageInputSource source,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ocrRecognizerProvider.overrideWithValue(ocr),
        imageInputSourceProvider.overrideWithValue(source),
      ],
      child: MaterialApp(home: CaptureScreen(mode: mode)),
    ),
  );
}

void main() {
  testWidgets('scan mode shows the capture affordance', (tester) async {
    await _pump(
      tester,
      mode: CaptureMode.scan,
      ocr: _FakeOcr('x'),
      source: _FakeImageSource(const PickedImage(path: '/a.jpg')),
    );

    expect(find.text('Capture page'), findsOneWidget);
  });

  testWidgets('import mode shows the choose-image affordance', (tester) async {
    await _pump(
      tester,
      mode: CaptureMode.import,
      ocr: _FakeOcr('x'),
      source: _FakeImageSource(const PickedImage(path: '/a.jpg')),
    );

    expect(find.text('Choose image'), findsOneWidget);
  });

  testWidgets('capture → OCR shows recognized text and a redact action', (
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
