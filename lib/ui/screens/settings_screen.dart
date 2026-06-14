import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/flavors/flavor.dart';
import '../../core/routes.dart';
import '../../features/documents/keep_original_setting.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/theme_mode_controller.dart';
import '../theme/tokens.dart';
import '../widgets/section_header.dart';

/// Settings (Phase 5c). Appearance (theme) is live now; security/privacy/AI
/// rows that depend on native features (biometrics, vault, models) are shown as
/// disabled placeholders until their phases land — tracked in VERIFICATION.md.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final flavor = ref.watch(currentFlavorProvider);
    final keepOriginal = ref.watch(keepOriginalProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppTokens.spacingLg),
              children: [
                SectionHeader(l10n.settingsSectionAppearance),
                _SettingsGroup(
                  child: RadioGroup<ThemeMode>(
                    groupValue: themeMode,
                    onChanged: (m) => ref
                        .read(themeModeProvider.notifier)
                        .set(m ?? themeMode),
                    child: Column(
                      children: [
                        for (final mode in ThemeMode.values)
                          RadioListTile<ThemeMode>(
                            value: mode,
                            title: Text(_themeLabel(l10n, mode)),
                          ),
                      ],
                    ),
                  ),
                ),

                SectionHeader(l10n.settingsSectionSecurity),
                _SettingsGroup(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_clock_outlined),
                        title: Text(l10n.settingsAutoLock),
                        subtitle: Text(l10n.settingsAutoLockSubtitle),
                        enabled: false,
                      ),
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: Text(l10n.settingsBiometricUnlock),
                        subtitle: Text(l10n.settingsBiometricUnlockSubtitle),
                        enabled: false,
                      ),
                    ],
                  ),
                ),

                SectionHeader(l10n.settingsSectionPrivacy),
                _SettingsGroup(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(l10n.settingsAuditLog),
                        subtitle: Text(l10n.settingsAuditLogSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.auditLog),
                      ),
                      ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: Text(l10n.settingsCustomEntities),
                        subtitle: Text(l10n.settingsCustomEntitiesSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.customEntities),
                      ),
                      SwitchListTile(
                        key: const Key('keep-original-toggle'),
                        secondary: const Icon(Icons.lock_outline),
                        title: Text(l10n.settingsKeepOriginal),
                        subtitle: Text(l10n.settingsKeepOriginalSubtitle),
                        value: keepOriginal,
                        onChanged: (v) =>
                            ref.read(keepOriginalProvider.notifier).set(v),
                      ),
                    ],
                  ),
                ),

                SectionHeader(l10n.settingsSectionAbout),
                _SettingsGroup(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.settingsAboutTitle),
                    subtitle: Text(l10n.settingsAboutSubtitle(flavor.name)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
    ThemeMode.system => l10n.settingsThemeSystem,
    ThemeMode.light => l10n.settingsThemeLight,
    ThemeMode.dark => l10n.settingsThemeDark,
  };
}

/// A settings section wrapped in a rounded card with consistent margins.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingMd),
    child: Card(child: child),
  );
}
