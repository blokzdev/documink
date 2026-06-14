import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/flavors/flavor.dart';
import '../../core/routes.dart';
import '../theme/theme_mode_controller.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            const SectionHeader('Appearance'),
            RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (m) =>
                  ref.read(themeModeProvider.notifier).set(m ?? themeMode),
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(_themeLabel(mode)),
                    ),
                ],
              ),
            ),
            const Divider(),

            const SectionHeader('Security'),
            const ListTile(
              leading: Icon(Icons.lock_clock_outlined),
              title: Text('Auto-lock'),
              subtitle: Text('Configured after vault unlock (later phase)'),
              enabled: false,
            ),
            const ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Biometric unlock'),
              subtitle: Text('Available on device (later phase)'),
              enabled: false,
            ),
            const Divider(),

            const SectionHeader('Privacy'),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Audit log'),
              subtitle: const Text('View privacy-relevant actions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.auditLog),
            ),
            const ListTile(
              leading: Icon(Icons.label_outline),
              title: Text('Custom entity types'),
              subtitle: Text('Define your own detectors (later phase)'),
              enabled: false,
            ),
            const Divider(),

            const SectionHeader('About'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('DocuMink'),
              subtitle: Text(
                'Privacy-first, on-device redaction · ${flavor.name} build',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System default',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}
