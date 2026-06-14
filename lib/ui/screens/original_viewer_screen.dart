import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../features/security/screen_security.dart';
import '../../l10n/gen/app_localizations.dart';

/// Transient, biometric-gated viewer for a decrypted original document (Phase
/// 4c). FLAG_SECURE is on while it's visible; on close it clears FLAG_SECURE,
/// evicts the image cache, and disposes the PDF controller. Backgrounding the
/// app pops it so decrypted content isn't left on screen / in recents.
class OriginalViewerScreen extends ConsumerStatefulWidget {
  const OriginalViewerScreen({
    super.key,
    required this.bytes,
    required this.mime,
  });

  final Uint8List bytes;
  final String mime;

  @override
  ConsumerState<OriginalViewerScreen> createState() =>
      _OriginalViewerScreenState();
}

class _OriginalViewerScreenState extends ConsumerState<OriginalViewerScreen>
    with WidgetsBindingObserver {
  late final ScreenSecurity _screenSecurity;
  PdfController? _pdf;

  bool get _isImage => widget.mime.startsWith('image/');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenSecurity = ref.read(screenSecurityProvider);
    _screenSecurity.enable();
    if (widget.mime == 'application/pdf') {
      _pdf = PdfController(document: PdfDocument.openData(widget.bytes));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't leave decrypted content visible when the app is backgrounded.
    if (state == AppLifecycleState.paused && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenSecurity.disable();
    _pdf?.dispose();
    // Best-effort eviction of the decrypted image bytes from Flutter's cache.
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.originalViewerTitle)),
      body: SafeArea(
        child: _isImage
            ? InteractiveViewer(
                child: Center(
                  child: Image.memory(
                    widget.bytes,
                    key: const Key('original-image'),
                  ),
                ),
              )
            : _pdf != null
            ? PdfView(controller: _pdf!)
            : Center(child: Text(l10n.originalViewerUnsupported)),
      ),
    );
  }
}
