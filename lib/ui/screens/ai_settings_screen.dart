import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/llm/llm_backend.dart';
import '../../features/llm/llm_providers.dart';
import '../../features/llm/llm_runtime_coordinator.dart';
import '../../features/llm/tier_catalog.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/section_header.dart';

/// On-device AI (Tier-4) enablement + a prompt tester. Downloads + SHA-256-
/// verifies the model (10c), loads it via `flutter_gemma` (10b), and lets the
/// user run a prompt to confirm inference. Device-only end to end (the runtime
/// is the fail-loud `UnavailableLlmBackend` until activated). Targets the
/// Standard-tier Balanced variant directly so it works before the profiler
/// onboarding lands (Phase 11).
class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

enum _Stage { idle, downloading, loading, ready, error, unsupported }

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  _Stage _stage = _Stage.idle;
  double _progress = 0;
  String? _error;
  final _prompt = TextEditingController();
  String? _response;
  bool _running = false;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _enable() async {
    setState(() {
      _stage = _Stage.downloading;
      _progress = 0;
      _error = null;
    });
    try {
      final manifest = await ref.read(modelManifestProvider.future);
      final variant = LlmRuntimeCoordinator.variantIn(
        manifest,
        'standard',
        VariantKind.balanced,
      );
      if (variant == null) {
        setState(() => _stage = _Stage.unsupported);
        return;
      }
      final backend = await ref
          .read(llmRuntimeCoordinatorProvider)
          .activateVariant(
            variant,
            onProgress: (p) => setState(() {
              _progress = p;
              if (p >= 1.0) _stage = _Stage.loading;
            }),
          );
      ref.read(activeLlmBackendProvider.notifier).set(backend);
      if (!mounted) return;
      setState(() => _stage = _Stage.ready);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.error;
        _error = '$e';
      });
    }
  }

  Future<void> _run() async {
    final prompt = _prompt.text.trim();
    final backend = ref.read(llmBackendProvider);
    if (prompt.isEmpty || _running) return;
    setState(() {
      _running = true;
      _response = null;
    });
    try {
      final out = await backend.generate(prompt);
      if (!mounted) return;
      setState(() => _response = out);
    } on LlmUnavailableException {
      if (!mounted) return;
      setState(() => _response = null);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ready = ref.watch(activeLlmBackendProvider) != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              children: [
                Text(l10n.aiSubtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppTokens.spacingLg),
                _statusCard(l10n, theme, ready),
                if (ready) ...[
                  SectionHeader(l10n.aiResponseTitle),
                  TextField(
                    key: const Key('ai-prompt'),
                    controller: _prompt,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: l10n.aiPromptHint),
                  ),
                  const SizedBox(height: AppTokens.spacingSm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      key: const Key('ai-run'),
                      onPressed: _running ? null : _run,
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: Text(l10n.aiRun),
                    ),
                  ),
                  if (_response != null) ...[
                    const SizedBox(height: AppTokens.spacingMd),
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
                        _response!,
                        style: AppTypography.mono(context),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(AppLocalizations l10n, ThemeData theme, bool ready) {
    final (label, showSpinner, showButton) = switch (_stage) {
      _Stage.idle => (l10n.aiEnable, false, true),
      _Stage.downloading => (
        l10n.aiDownloading((_progress * 100).round()),
        true,
        false,
      ),
      _Stage.loading => (l10n.aiLoading, true, false),
      _Stage.ready => (l10n.aiReady, false, false),
      _Stage.error => (_error ?? l10n.aiError, false, true),
      _Stage.unsupported => (l10n.aiUnsupported, false, false),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        child: Row(
          children: [
            if (showSpinner)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                ready ? Icons.check_circle : Icons.smart_toy_outlined,
                color: ready ? theme.colorScheme.primary : null,
              ),
            const SizedBox(width: AppTokens.spacingMd),
            Expanded(child: Text(label)),
            if (showButton)
              FilledButton(
                key: const Key('ai-enable'),
                onPressed: _enable,
                child: Text(l10n.aiEnable),
              ),
          ],
        ),
      ),
    );
  }
}
