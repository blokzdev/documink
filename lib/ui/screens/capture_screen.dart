import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/input/capture_controller.dart';
import '../../features/input/ingested_text.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/app_error_state.dart';

/// Which input the capture screen acquires.
enum CaptureMode { scan, import }

/// Phase 4 input screen: acquire a page (camera scan / gallery) or a document
/// (image or PDF) → OCR / text extraction → review the recognized text → hand
/// it to the redaction editor. The native camera/picker/OCR/PDF bits sit behind
/// seams ([captureControllerProvider]); this screen is widget-tested with fakes.
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key, required this.mode});

  final CaptureMode mode;

  bool get _isScan => mode == CaptureMode.scan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureControllerProvider);
    final controller = ref.read(captureControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isScan ? l10n.captureScanTitle : l10n.captureImportTitle),
      ),
      body: SafeArea(
        child: switch (state.status) {
          CaptureStatus.working => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppTokens.spacingMd),
                Text(l10n.captureRecognizing),
              ],
            ),
          ),
          CaptureStatus.error => AppErrorState(
            title: l10n.captureErrorTitle,
            message: state.error,
            onRetry: controller.reset,
          ),
          CaptureStatus.ready => _ReadyView(
            result: state.result!,
            onRedact: () {
              final text = state.result!.text;
              controller.reset();
              context.push(Routes.paste, extra: text);
            },
            onRetry: controller.reset,
            retryLabel: _isScan
                ? l10n.captureCaptureAnother
                : l10n.captureChooseAnother,
          ),
          CaptureStatus.idle => _IdleView(
            isScan: _isScan,
            onScan: controller.scan,
            onPickImage: controller.importImage,
            onPickPdf: controller.importPdf,
          ),
        },
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({
    required this.isScan,
    required this.onScan,
    required this.onPickImage,
    required this.onPickPdf,
  });

  final bool isScan;
  final VoidCallback onScan;
  final VoidCallback onPickImage;
  final VoidCallback onPickPdf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isScan
                  ? Icons.document_scanner_outlined
                  : Icons.file_open_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppTokens.spacingMd),
            Text(
              isScan ? l10n.captureScanPrompt : l10n.captureImportPrompt,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTokens.spacingLg),
            if (isScan) ...[
              FilledButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l10n.captureCapturePage),
              ),
              const SizedBox(height: AppTokens.spacingSm),
              OutlinedButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.captureChooseFromGallery),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(l10n.captureChooseImage),
              ),
              const SizedBox(height: AppTokens.spacingSm),
              OutlinedButton.icon(
                onPressed: onPickPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l10n.captureChoosePdf),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.result,
    required this.onRedact,
    required this.onRetry,
    required this.retryLabel,
  });

  final IngestedText result;
  final VoidCallback onRedact;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final text = result.text;
    final hasText = text.trim().isNotEmpty;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      children: [
        for (final warning in result.warnings) ...[
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppTokens.spacingSm),
              Expanded(
                child: Text(
                  warning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spacingMd),
        ],
        if (hasText) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.captureRecognizedText,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              _SourceBadge(source: result.source, pageCount: result.pageCount),
            ],
          ),
          const SizedBox(height: AppTokens.spacingSm),
          Semantics(
            label: l10n.captureRecognizedTextSemantics(text.length),
            container: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppTokens.radiusMd),
                ),
              ),
              child: SelectableText(
                text,
                key: const Key('recognized-text'),
                style: AppTypography.mono(context),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spacingMd),
          FilledButton.icon(
            onPressed: onRedact,
            icon: const Icon(Icons.shield_outlined),
            label: Text(l10n.captureRedactThis),
          ),
          const SizedBox(height: AppTokens.spacingSm),
        ],
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(retryLabel),
        ),
      ],
    );
  }
}

/// A small chip showing how the text was acquired (and PDF page count).
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.pageCount});

  final InputSourceKind source;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, icon) = switch (source) {
      InputSourceKind.cameraScan => (
        l10n.captureSourceCamera,
        Icons.document_scanner_outlined,
      ),
      InputSourceKind.imageImport => (
        l10n.captureSourceImage,
        Icons.image_outlined,
      ),
      InputSourceKind.pdfImport => (
        '${l10n.captureSourcePdf} · ${l10n.capturePageCount(pageCount)}',
        Icons.picture_as_pdf_outlined,
      ),
      InputSourceKind.sharedText => (
        l10n.captureSourceImage,
        Icons.share_outlined,
      ),
    };
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
