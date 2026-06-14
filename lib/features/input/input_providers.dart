import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_input_source.dart';
import 'input_ingestion_service.dart';
import 'ocr_recognizer.dart';
import 'pdf_page_rasterizer.dart';
import 'pdf_source.dart';
import 'pdf_text_extractor.dart';
import 'share_intent_receiver.dart';
import 'temp_file_disposer.dart';

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

/// PDF file picker. Defaults to [UnavailablePdfSource]; bootstrap overrides it
/// with `FileSelectorPdfSource`, tests with a fake.
final pdfSourceProvider = Provider<PdfSource>(
  (ref) => const UnavailablePdfSource(),
);

/// PDF text-layer extractor. Defaults to [UnavailablePdfTextExtractor];
/// bootstrap overrides it with `FlutterPdfTextExtractor`, tests with a fake.
final pdfTextExtractorProvider = Provider<PdfTextExtractor>(
  (ref) => const UnavailablePdfTextExtractor(),
);

/// PDF page rasterizer (scanned-page OCR). Defaults to
/// [UnavailablePdfPageRasterizer]; bootstrap overrides it with
/// `PdfxPageRasterizer`, tests with a fake.
final pdfPageRasterizerProvider = Provider<PdfPageRasterizer>(
  (ref) => const UnavailablePdfPageRasterizer(),
);

/// Deletes transient files we create (rasterized PDF pages). Defaults to the
/// real [IoTempFileDisposer] (dart:io works everywhere); tests override with a
/// recording fake to assert cleanup.
final tempFileDisposerProvider = Provider<TempFileDisposer>(
  (ref) => const IoTempFileDisposer(),
);

/// Receives inbound `ACTION_SEND` shares. Defaults to [NoShareIntentReceiver];
/// bootstrap overrides it with the real `receive_sharing_intent` adapter, tests
/// with a fake.
final shareIntentReceiverProvider = Provider<ShareIntentReceiver>(
  (ref) => const NoShareIntentReceiver(),
);

/// The pure-Dart ingestion orchestrator, composed from the seams above.
final inputIngestionServiceProvider = Provider<InputIngestionService>(
  (ref) => InputIngestionService(
    ocr: ref.watch(ocrRecognizerProvider),
    imageSource: ref.watch(imageInputSourceProvider),
    pdfSource: ref.watch(pdfSourceProvider),
    pdfTextExtractor: ref.watch(pdfTextExtractorProvider),
    pdfPageRasterizer: ref.watch(pdfPageRasterizerProvider),
    tempFileDisposer: ref.watch(tempFileDisposerProvider),
  ),
);
