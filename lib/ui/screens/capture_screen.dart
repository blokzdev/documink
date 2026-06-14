import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/input/capture_controller.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/app_error_state.dart';

/// Which input the capture screen acquires.
enum CaptureMode { scan, import }

/// Phase 4 input screen: acquire a page (camera scan) or an image (system
/// picker) → OCR → review the recognized text → hand it to the redaction
/// editor. The native camera/picker/OCR sit behind seams
/// ([captureControllerProvider]); this screen is widget-tested with fakes.
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key, required this.mode});

  final CaptureMode mode;

  bool get _isScan => mode == CaptureMode.scan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureControllerProvider);
    final controller = ref.read(captureControllerProvider.notifier);
    final theme = Theme.of(context);

    Future<void> acquire() =>
        _isScan ? controller.scan() : controller.importImage();

    return Scaffold(
      appBar: AppBar(title: Text(_isScan ? 'Scan' : 'Import')),
      body: SafeArea(
        child: switch (state.status) {
          CaptureStatus.working => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppTokens.spacingMd),
                Text('Recognizing text…'),
              ],
            ),
          ),
          CaptureStatus.error => AppErrorState(
            title: 'Could not read that',
            message: state.error,
            onRetry: acquire,
          ),
          CaptureStatus.ready => _ReadyView(
            text: state.result!.text,
            warnings: state.result!.warnings,
            onRedact: () {
              final text = state.result!.text;
              controller.reset();
              context.push(Routes.paste, extra: text);
            },
            onRetry: acquire,
            retryLabel: _isScan ? 'Capture another' : 'Choose another',
          ),
          CaptureStatus.idle => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isScan
                        ? Icons.document_scanner_outlined
                        : Icons.image_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                  Text(
                    _isScan
                        ? 'Capture a document with the camera, then redact the '
                              'recognized text.'
                        : 'Pick an image to extract and redact its text.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppTokens.spacingLg),
                  FilledButton.icon(
                    onPressed: acquire,
                    icon: Icon(
                      _isScan
                          ? Icons.camera_alt_outlined
                          : Icons.image_outlined,
                    ),
                    label: Text(_isScan ? 'Capture page' : 'Choose image'),
                  ),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.text,
    required this.warnings,
    required this.onRedact,
    required this.onRetry,
    required this.retryLabel,
  });

  final String text;
  final List<String> warnings;
  final VoidCallback onRedact;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = text.trim().isNotEmpty;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      children: [
        for (final warning in warnings) ...[
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
          Text('Recognized text', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTokens.spacingSm),
          Container(
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
          const SizedBox(height: AppTokens.spacingMd),
          FilledButton.icon(
            onPressed: onRedact,
            icon: const Icon(Icons.shield_outlined),
            label: const Text('Redact this text'),
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
