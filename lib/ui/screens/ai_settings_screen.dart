import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/llm/ai_model_controller.dart';
import '../../features/llm/device_capability_profiler.dart' show FloorReason;
import '../../features/llm/llm_backend.dart';
import '../../features/llm/llm_providers.dart';
import '../../features/llm/model_manifest.dart';
import '../../features/llm/profiler_state.dart';
import '../../features/llm/tier_catalog.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/section_header.dart';

/// Settings → AI Model (Phase 11a). Shows the profiler-driven Tier-4
/// recommendation and the controls to enable it: download, switch
/// Balanced↔Specialized, override the tier (qualifying tiers only), re-check the
/// device, and remove the model. Floor devices get an honest disabled state.
/// Every change is audited via [AiModelController] (no silent swaps). The model
/// download + inference are device-only; the orchestration is fake-tested.
class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

enum _Stage { idle, downloading, loading }

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  bool _loading = true;
  ModelManifest? _manifest;
  ProfilerState? _state;
  Object? _loadError;

  _Stage _stage = _Stage.idle;
  double _progress = 0;
  String? _opError;
  bool _busy = false;

  final _prompt = TextEditingController();
  String? _response;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final manifest = await ref.read(modelManifestProvider.future);
      final state = await ref.read(profilerRepositoryProvider).load();
      if (!mounted) return;
      setState(() {
        _manifest = manifest;
        _state = state;
        _loadError = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  AiModelController get _controller => ref.read(aiModelControllerProvider);

  /// Wraps a state-changing controller call: shows the busy/error UI, then
  /// refreshes [_state]. [download] toggles the download-progress affordance.
  Future<void> _run(
    Future<ProfilerState> Function({void Function(double)? onProgress}) op, {
    bool download = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _opError = null;
      if (download) {
        _stage = _Stage.downloading;
        _progress = 0;
      }
    });
    try {
      final next = await op(
        onProgress: download
            ? (p) => setState(() {
                _progress = p;
                if (p >= 1.0) _stage = _Stage.loading;
              })
            : null,
      );
      if (!mounted) return;
      setState(() {
        _state = next;
        _stage = _Stage.idle;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _opError = '$e';
        _stage = _Stage.idle;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recheck() => _run(({onProgress}) => _controller.recheck());

  Future<void> _enable() => _run(
    ({onProgress}) => _controller.enableRecommended(onProgress: onProgress),
    download: true,
  );

  Future<void> _switchVariant(VariantKind kind) => _run(
    ({onProgress}) => _controller.switchVariant(kind, onProgress: onProgress),
    download: true,
  );

  Future<void> _overrideTier(String tier) => _run(
    ({onProgress}) => _controller.overrideTier(tier, onProgress: onProgress),
    download: true,
  );

  Future<void> _remove() => _run(({onProgress}) => _controller.removeModel());

  Future<void> _runPrompt() async {
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(AppTokens.spacingMd),
                    children: _body(l10n, theme),
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(AppLocalizations l10n, ThemeData theme) {
    if (_loadError != null) {
      return [Text(l10n.aiError, style: theme.textTheme.bodyMedium)];
    }
    final state = _state;
    return [
      Text(l10n.aiSubtitle, style: theme.textTheme.bodyMedium),
      const SizedBox(height: AppTokens.spacingLg),
      if (state == null)
        _notProfiledCard(l10n)
      else if (state.isFloor)
        _floorCard(l10n, theme, state)
      else
        ..._recommendationCards(l10n, theme, state),
      if (_opError != null) ...[
        const SizedBox(height: AppTokens.spacingMd),
        Text(_opError!, style: TextStyle(color: theme.colorScheme.error)),
      ],
    ];
  }

  // ── Not yet profiled ──────────────────────────────────────────────────────
  Widget _notProfiledCard(AppLocalizations l10n) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.aiNotProfiled),
          const SizedBox(height: AppTokens.spacingMd),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const Key('ai-recheck'),
              onPressed: _busy ? null : _recheck,
              icon: const Icon(Icons.troubleshoot_outlined),
              label: Text(l10n.aiCheckDevice),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Floor (below minimum) ─────────────────────────────────────────────────
  Widget _floorCard(AppLocalizations l10n, ThemeData theme, ProfilerState s) {
    final reason = switch (s.floorReason) {
      FloorReason.insufficientScore => l10n.aiFloorScore,
      FloorReason.insufficientRam => l10n.aiFloorRam,
      FloorReason.insufficientStorage => l10n.aiFloorStorage,
      FloorReason.noQualifyingTier || null => l10n.aiFloorNoTier,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: AppTokens.spacingSm),
                Expanded(
                  child: Text(
                    l10n.aiFloorTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacingSm),
            Text(reason),
            const SizedBox(height: AppTokens.spacingSm),
            Text(l10n.aiFloorStillWorks, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppTokens.spacingMd),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: const Key('ai-recheck'),
                onPressed: _busy ? null : _recheck,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.aiRecheck),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Qualifying device ─────────────────────────────────────────────────────
  List<Widget> _recommendationCards(
    AppLocalizations l10n,
    ThemeData theme,
    ProfilerState s,
  ) {
    final manifest = _manifest!;
    final variant = _variantFor(manifest, s.tier, s.variant);
    final ready =
        s.downloadState == DownloadState.ready &&
        ref.watch(activeLlmBackendProvider) != null;

    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aiTierRecommended, style: theme.textTheme.labelMedium),
              const SizedBox(height: AppTokens.spacingXs),
              _kv(theme, l10n.aiTierLabel, s.tier),
              _kv(theme, l10n.aiVariantLabel, _variantLabel(l10n, s.variant)),
              if (variant != null)
                _kv(theme, l10n.aiModelLabel, variant.modelId),
              if (variant != null)
                _kv(theme, l10n.aiSizeLabel, _mb(variant.sizeBytes)),
              _kv(theme, l10n.aiScoreLabel, s.score.round().toString()),
              const SizedBox(height: AppTokens.spacingMd),
              if (_stage != _Stage.idle)
                _progressRow(l10n)
              else if (!ready)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('ai-enable'),
                    onPressed: _busy ? null : _enable,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l10n.aiEnable),
                  ),
                )
              else
                Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    const SizedBox(width: AppTokens.spacingSm),
                    Text(l10n.aiReady),
                  ],
                ),
            ],
          ),
        ),
      ),
      if (ready) ...[
        const SizedBox(height: AppTokens.spacingMd),
        ..._manageCards(l10n, theme, s, manifest),
        const SizedBox(height: AppTokens.spacingMd),
        ..._promptTester(l10n, theme),
      ],
    ];
  }

  List<Widget> _manageCards(
    AppLocalizations l10n,
    ThemeData theme,
    ProfilerState s,
    ModelManifest manifest,
  ) {
    final tier = manifest.catalog.tiers
        .where((t) => t.tier == s.tier)
        .cast<CatalogTier?>()
        .firstWhere((t) => true, orElse: () => null);
    final hasSpecialized =
        tier?.variants.containsKey(VariantKind.specialized) ?? false;
    final hasBalanced =
        tier?.variants.containsKey(VariantKind.balanced) ?? false;
    final qualifyingTiers = <String>{s.tier, ...s.optInAvailable}.toList();

    return [
      SectionHeader(l10n.aiManageTitle),
      _SettingsCard(
        child: Column(
          children: [
            if (hasBalanced && hasSpecialized)
              ListTile(
                title: Text(l10n.aiVariantLabel),
                subtitle: Text(_variantLabel(l10n, s.variant)),
                trailing: SegmentedButton<VariantKind>(
                  key: const Key('ai-variant-toggle'),
                  segments: [
                    ButtonSegment(
                      value: VariantKind.balanced,
                      label: Text(l10n.aiVariantBalanced),
                    ),
                    ButtonSegment(
                      value: VariantKind.specialized,
                      label: Text(l10n.aiVariantSpecialized),
                    ),
                  ],
                  selected: {s.variant},
                  onSelectionChanged: _busy
                      ? null
                      : (sel) => _switchVariant(sel.first),
                ),
              ),
            if (qualifyingTiers.length > 1)
              ListTile(
                title: Text(l10n.aiTierOverride),
                trailing: DropdownButton<String>(
                  key: const Key('ai-tier-override'),
                  value: s.tier,
                  onChanged: _busy
                      ? null
                      : (t) {
                          if (t != null && t != s.tier) _overrideTier(t);
                        },
                  items: [
                    for (final t in qualifyingTiers)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(l10n.aiRecheck),
              onTap: _busy ? null : _recheck,
            ),
            ListTile(
              key: const Key('ai-remove'),
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(l10n.aiRemove),
              onTap: _busy ? null : _remove,
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _promptTester(AppLocalizations l10n, ThemeData theme) => [
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
        onPressed: _running ? null : _runPrompt,
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
        child: SelectableText(_response!, style: AppTypography.mono(context)),
      ),
    ],
  ];

  Widget _progressRow(AppLocalizations l10n) => Row(
    children: [
      const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      const SizedBox(width: AppTokens.spacingMd),
      Expanded(
        child: Text(
          _stage == _Stage.loading
              ? l10n.aiLoading
              : l10n.aiDownloading((_progress * 100).round()),
        ),
      ),
    ],
  );

  Widget _kv(ThemeData theme, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTokens.spacingXs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 96, child: Text(k, style: theme.textTheme.bodySmall)),
        Expanded(child: Text(v)),
      ],
    ),
  );

  String _variantLabel(AppLocalizations l10n, VariantKind k) =>
      k == VariantKind.specialized
      ? l10n.aiVariantSpecialized
      : l10n.aiVariantBalanced;

  String _mb(int bytes) => '${(bytes / 1e6).round()} MB';

  ModelVariant? _variantFor(ModelManifest m, String tier, VariantKind kind) {
    for (final t in m.catalog.tiers) {
      if (t.tier == tier) return t.variants[kind];
    }
    return null;
  }
}

/// A grouped settings container matching the look of the main Settings screen.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Card(clipBehavior: Clip.antiAlias, child: child);
}
