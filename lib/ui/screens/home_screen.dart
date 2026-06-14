import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/theme_mode_controller.dart';
import '../theme/tokens.dart';
import '../widgets/brand_mark.dart';
import '../widgets/primary_action_card.dart';

/// The Home hub: brand header + primary actions (blueprint §Phase 5), with a
/// theme quick-toggle and a Settings entry.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _actions = <_HomeAction>[
    _HomeAction(
      icon: Icons.document_scanner_outlined,
      label: 'Scan',
      description: 'Capture a document with the camera',
      route: Routes.scan,
    ),
    _HomeAction(
      icon: Icons.content_paste_outlined,
      label: 'Paste text',
      description: 'Detect & redact pasted text',
      route: Routes.paste,
    ),
    _HomeAction(
      icon: Icons.file_open_outlined,
      label: 'Import',
      description: 'Pick an image or PDF',
      route: Routes.import,
    ),
    _HomeAction(
      icon: Icons.create_new_folder_outlined,
      label: 'New Project',
      description: 'Create a scoped workspace',
      route: Routes.newProject,
    ),
    _HomeAction(
      icon: Icons.chat_bubble_outline,
      label: 'Chat with Mink',
      description: 'Your on-device assistant',
      route: Routes.chat,
    ),
    _HomeAction(
      icon: Icons.folder_outlined,
      label: 'My documents',
      description: 'Browse your saved vault',
      route: Routes.vault,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_themeIcon(themeMode)),
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              children: [
                const BrandLockup(markSize: 36),
                const SizedBox(height: AppTokens.spacingLg),
                Text(l10n.homeTagline, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTokens.spacingXs),
                Text(
                  l10n.homeSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.spacingLg),
                for (final action in _actions) ...[
                  PrimaryActionCard(
                    icon: action.icon,
                    label: action.label,
                    description: action.description,
                    onTap: () => context.push(action.route),
                  ),
                  const SizedBox(height: AppTokens.spacingSm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };
}

class _HomeAction {
  const _HomeAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String description;
  final String route;
}
