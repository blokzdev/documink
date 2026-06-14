import 'package:file_selector/file_selector.dart';

import 'pdf_source.dart';

/// Production [PdfSource] backed by `file_selector` (BSD-3, Flutter team).
///
/// **Device-only:** opens the native file picker, so it is not exercised by
/// headless tests — the orchestration it feeds is tested via a fake source.
/// Wired at bootstrap; device-verified (VERIFICATION.md).
class FileSelectorPdfSource implements PdfSource {
  const FileSelectorPdfSource();

  static const _pdfTypeGroup = XTypeGroup(
    label: 'PDF',
    extensions: ['pdf'],
    mimeTypes: ['application/pdf'],
  );

  @override
  Future<String?> pickPdf() async {
    final file = await openFile(acceptedTypeGroups: const [_pdfTypeGroup]);
    return file?.path;
  }
}
