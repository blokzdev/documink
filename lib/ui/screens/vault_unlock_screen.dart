import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/llm/llm_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/vault_providers.dart';
import '../../services/vault_service.dart';
import '../theme/tokens.dart';
import '../widgets/brand_mark.dart';

/// Minimum passphrase length for a new vault (UX guard; the KDF is the real
/// strength). Kept modest so it's memorable; biometrics are a later fast-path.
const int _minPassphraseLength = 8;

/// Passphrase gate (blueprint §8.2). First run creates the vault (passphrase +
/// confirm → `initialize`); thereafter it unlocks (`unlock`). On success the
/// router redirect moves on; a wrong passphrase leaves the vault locked. An
/// existing vault that can no longer be opened (e.g. secure storage wiped) can be
/// erased via "reset & start over".
class VaultUnlockScreen extends ConsumerStatefulWidget {
  const VaultUnlockScreen({super.key});

  @override
  ConsumerState<VaultUnlockScreen> createState() => _VaultUnlockScreenState();
}

class _VaultUnlockScreenState extends ConsumerState<VaultUnlockScreen> {
  final _passphrase = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _passphrase.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool creating}) async {
    final l10n = AppLocalizations.of(context);
    final passphrase = _passphrase.text;
    setState(() => _error = null);

    if (creating) {
      if (passphrase.length < _minPassphraseLength) {
        setState(() => _error = l10n.vaultErrTooShort(_minPassphraseLength));
        return;
      }
      if (passphrase != _confirm.text) {
        setState(() => _error = l10n.vaultErrMismatch);
        return;
      }
    } else if (passphrase.isEmpty) {
      setState(() => _error = l10n.vaultErrEmpty);
      return;
    }

    final vault = ref.read(vaultServiceProvider.notifier);
    try {
      if (creating) {
        // Owe the first-run "Meet Mink" onboarding step before the unlock
        // redirect fires, so a freshly created vault routes to onboarding
        // (never flashing Home). Phase 11b.
        ref.read(aiOnboardingProvider.notifier).require();
        await vault.initialize(passphrase);
      } else {
        await vault.unlock(passphrase);
      }
    } catch (error, stackTrace) {
      // Surface the real failure to the device log (crypto/IO only — never
      // passphrase or PII) so a bricked-vault report is diagnosable, instead of
      // silently collapsing every cause into one message.
      developer.log(
        creating ? 'vault initialize failed' : 'vault unlock failed',
        name: 'documink.vault',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(
        () => _error = creating ? l10n.vaultErrCreate : l10n.vaultErrUnlock,
      );
    }
  }

  Future<void> _resetVault() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.vaultResetTitle),
        content: Text(l10n.vaultResetBody),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: Text(l10n.vaultResetCancel),
          ),
          FilledButton(
            key: const Key('vault-reset-confirm'),
            onPressed: () => navigator.pop(true),
            child: Text(l10n.vaultResetConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(vaultServiceProvider.notifier).reset();
    ref.invalidate(vaultExistsProvider);
    if (!mounted) return;
    _passphrase.clear();
    _confirm.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existsAsync = ref.watch(vaultExistsProvider);
    final unlocking =
        ref.watch(vaultServiceProvider).status == VaultStatus.unlocking;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: existsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => Text(l10n.vaultStateReadError),
            data: (exists) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(AppTokens.spacingLg),
                children: [
                  const Center(child: BrandMark(size: 56)),
                  const SizedBox(height: AppTokens.spacingMd),
                  Text(
                    exists ? l10n.vaultUnlockTitle : l10n.vaultCreateTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTokens.spacingSm),
                  Text(
                    exists
                        ? l10n.vaultUnlockSubtitle
                        : l10n.vaultCreateSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTokens.spacingLg),
                  TextField(
                    controller: _passphrase,
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.vaultPassphraseLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: exists
                        ? (_) => _submit(creating: false)
                        : null,
                  ),
                  if (!exists) ...[
                    const SizedBox(height: AppTokens.spacingMd),
                    TextField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.vaultConfirmLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: AppTokens.spacingMd),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: AppTokens.spacingLg),
                  FilledButton(
                    onPressed: unlocking
                        ? null
                        : () => _submit(creating: !exists),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.spacingSm),
                      child: unlocking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              exists
                                  ? l10n.vaultUnlockButton
                                  : l10n.vaultCreateButton,
                            ),
                    ),
                  ),
                  // Recovery escape hatch: an existing vault that can't be opened
                  // (forgotten passphrase, or wiped secure storage) can be erased
                  // to start over, rather than being permanently stuck.
                  if (exists) ...[
                    const SizedBox(height: AppTokens.spacingSm),
                    TextButton(
                      key: const Key('vault-reset'),
                      onPressed: unlocking ? null : _resetVault,
                      child: Text(l10n.vaultResetButton),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
