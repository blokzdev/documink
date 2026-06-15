import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/llm/ai_model_controller.dart';
import '../../features/llm/device_capability_profiler.dart' show FloorReason;
import '../../features/llm/llm_providers.dart';
import '../../features/llm/model_manifest.dart';
import '../../features/llm/profiler_state.dart';
import '../../features/llm/tier_catalog.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/brand_mark.dart';

/// First-run **"Meet Mink"** Tier-4 decision step (Phase 11b / roadmap §11).
/// Runs the device profiler, then offers the recommended on-device model
/// (Accept & download / Show options / Skip), or an honest floor explanation on
/// a below-minimum device. Reuses [AiModelController]; reached via the router's
/// onboarding gate ([aiOnboardingProvider]) and dismissed with `markSeen()`.
class OnboardingAiScreen extends ConsumerStatefulWidget {
  const OnboardingAiScreen({super.key});

  @override
  ConsumerState<OnboardingAiScreen> createState() => _OnboardingAiScreenState();
}

/// One selectable model choice in the "Show options" list.
class _Choice {
  const _Choice({
    required this.tier,
    required this.variant,
    required this.sizeBytes,
    required this.isOptIn,
  });
  final String tier;
  final VariantKind variant;
  final int sizeBytes;
  final bool isOptIn;
}

enum _Stage { idle, downloading, loading }

class _OnboardingAiScreenState extends ConsumerState<OnboardingAiScreen> {
  bool _loading = true;
  Object? _error;
  ModelManifest? _manifest;
  ProfilerState? _state;

  bool _showOptions = false;
  _Choice? _selected;

  _Stage _stage = _Stage.idle;
  double _progress = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final manifest = await ref.read(modelManifestProvider.future);
      var state = await ref.read(profilerRepositoryProvider).load();
      // First run: the profiler has never run — run it now (persists a state).
      state ??= await ref.read(profilerServiceProvider).runProfile(manifest);
      if (!mounted) return;
      setState(() {
        _manifest = manifest;
        _state = state;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _done() {
    ref.read(aiOnboardingProvider.notifier).markSeen();
    if (mounted) context.go(Routes.home);
  }

  Future<void> _recheck() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final next = await ref.read(aiModelControllerProvider).recheck();
      if (!mounted) return;
      setState(() {
        _state = next;
        _selected = null;
        _showOptions = false;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept() async {
    if (_busy) return;
    final controller = ref.read(aiModelControllerProvider);
    final state = _state!;
    final choice = _selected;
    setState(() {
      _busy = true;
      _stage = _Stage.downloading;
      _progress = 0;
      _error = null;
    });
    void onProgress(double p) => setState(() {
      _progress = p;
      if (p >= 1.0) _stage = _Stage.loading;
    });
    try {
      if (choice == null ||
          (choice.tier == state.tier && choice.variant == state.variant)) {
        await controller.enableRecommended(onProgress: onProgress);
      } else if (choice.tier != state.tier) {
        await controller.overrideTier(choice.tier, onProgress: onProgress);
      } else {
        await controller.switchVariant(choice.variant, onProgress: onProgress);
      }
      _done();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _stage = _Stage.idle;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(AppTokens.spacingLg),
                    children: _body(l10n, theme),
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(AppLocalizations l10n, ThemeData theme) {
    final intro = [
      const Center(child: BrandMark(size: 56)),
      const SizedBox(height: AppTokens.spacingMd),
      Text(
        l10n.onboardingTitle,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall,
      ),
      const SizedBox(height: AppTokens.spacingSm),
      Text(
        l10n.onboardingIntro,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: AppTokens.spacingLg),
    ];

    final state = _state;
    if (_error != null && _stage == _Stage.idle && state == null) {
      return [...intro, Text(l10n.aiError, textAlign: TextAlign.center)];
    }
    if (state != null && state.isFloor) {
      return [...intro, ..._floor(l10n, theme, state)];
    }
    return [...intro, ..._recommend(l10n, theme, state!)];
  }

  List<Widget> _floor(AppLocalizations l10n, ThemeData theme, ProfilerState s) {
    final reason = switch (s.floorReason) {
      FloorReason.insufficientScore => l10n.aiFloorScore,
      FloorReason.insufficientRam => l10n.aiFloorRam,
      FloorReason.insufficientStorage => l10n.aiFloorStorage,
      FloorReason.noQualifyingTier || null => l10n.aiFloorNoTier,
    };
    return [
      Text(l10n.aiFloorTitle, style: theme.textTheme.titleMedium),
      const SizedBox(height: AppTokens.spacingSm),
      Text(reason),
      const SizedBox(height: AppTokens.spacingSm),
      Text(l10n.aiFloorStillWorks, style: theme.textTheme.bodySmall),
      const SizedBox(height: AppTokens.spacingLg),
      Row(
        children: [
          OutlinedButton.icon(
            key: const Key('onboarding-recheck'),
            onPressed: _busy ? null : _recheck,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.aiRecheck),
          ),
          const Spacer(),
          FilledButton(
            key: const Key('onboarding-continue'),
            onPressed: _busy ? null : _done,
            child: Text(l10n.onboardingContinue),
          ),
        ],
      ),
    ];
  }

  List<Widget> _recommend(
    AppLocalizations l10n,
    ThemeData theme,
    ProfilerState s,
  ) {
    if (_stage != _Stage.idle) {
      return [
        Row(
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
        ),
      ];
    }

    final rec = _variant(s.tier, s.variant);
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aiTierRecommended, style: theme.textTheme.labelMedium),
              const SizedBox(height: AppTokens.spacingXs),
              Text('${l10n.aiTierLabel}: ${s.tier}'),
              if (rec != null)
                Text('${l10n.aiSizeLabel}: ${_mb(rec.sizeBytes)}'),
              Text('${l10n.aiScoreLabel}: ${s.score.round()}'),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppTokens.spacingSm),
      if (_showOptions)
        ..._options(l10n, theme, s)
      else
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: const Key('onboarding-options'),
            onPressed: _busy ? null : () => setState(() => _showOptions = true),
            child: Text(l10n.onboardingShowOptions),
          ),
        ),
      const SizedBox(height: AppTokens.spacingMd),
      Row(
        children: [
          TextButton(
            key: const Key('onboarding-skip'),
            onPressed: _busy ? null : _done,
            child: Text(l10n.onboardingSkip),
          ),
          const Spacer(),
          FilledButton.icon(
            key: const Key('onboarding-accept'),
            onPressed: _busy ? null : _accept,
            icon: const Icon(Icons.download_outlined),
            label: Text(l10n.onboardingAccept),
          ),
        ],
      ),
    ];
  }

  List<Widget> _options(
    AppLocalizations l10n,
    ThemeData theme,
    ProfilerState s,
  ) {
    final choices = <_Choice>[];
    final balanced = _variant(s.tier, VariantKind.balanced);
    if (balanced != null) {
      choices.add(
        _Choice(
          tier: s.tier,
          variant: VariantKind.balanced,
          sizeBytes: balanced.sizeBytes,
          isOptIn: false,
        ),
      );
    }
    final specialized = _variant(s.tier, VariantKind.specialized);
    if (specialized != null) {
      choices.add(
        _Choice(
          tier: s.tier,
          variant: VariantKind.specialized,
          sizeBytes: specialized.sizeBytes,
          isOptIn: false,
        ),
      );
    }
    for (final t in s.optInAvailable) {
      final v = _variant(t, VariantKind.balanced);
      if (v != null) {
        choices.add(
          _Choice(
            tier: t,
            variant: VariantKind.balanced,
            sizeBytes: v.sizeBytes,
            isOptIn: true,
          ),
        );
      }
    }
    final selected = _selected ?? choices.first;
    String id(_Choice c) => '${c.tier}/${c.variant.id}';
    return [
      RadioGroup<String>(
        groupValue: id(selected),
        onChanged: (v) {
          if (_busy || v == null) return;
          setState(() => _selected = choices.firstWhere((c) => id(c) == v));
        },
        child: Column(
          children: [
            for (final c in choices)
              RadioListTile<String>(
                value: id(c),
                title: Text(
                  '${c.tier} · ${c.variant == VariantKind.specialized ? l10n.aiVariantSpecialized : l10n.aiVariantBalanced}',
                ),
                subtitle: Text(
                  c.isOptIn
                      ? '${_mb(c.sizeBytes)} · ${l10n.onboardingOptInWarning}'
                      : _mb(c.sizeBytes),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  ModelVariant? _variant(String tier, VariantKind kind) {
    for (final t in _manifest!.catalog.tiers) {
      if (t.tier == tier) return t.variants[kind];
    }
    return null;
  }

  String _mb(int bytes) => '${(bytes / 1e6).round()} MB';
}
