import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/vault_providers.dart';
import '../../services/vault_service.dart';
import '../theme/tokens.dart';

/// Minimum passphrase length for a new vault (UX guard; the KDF is the real
/// strength). Kept modest so it's memorable; biometrics are a later fast-path.
const int _minPassphraseLength = 8;

/// Passphrase gate (blueprint §8.2). First run creates the vault (passphrase +
/// confirm → `initialize`); thereafter it unlocks (`unlock`). On success the
/// router redirect moves on; a wrong passphrase leaves the vault locked.
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
    final passphrase = _passphrase.text;
    setState(() => _error = null);

    if (creating) {
      if (passphrase.length < _minPassphraseLength) {
        setState(
          () => _error = 'Use at least $_minPassphraseLength characters.',
        );
        return;
      }
      if (passphrase != _confirm.text) {
        setState(() => _error = 'Passphrases do not match.');
        return;
      }
    } else if (passphrase.isEmpty) {
      setState(() => _error = 'Enter your passphrase.');
      return;
    }

    final vault = ref.read(vaultServiceProvider.notifier);
    try {
      if (creating) {
        await vault.initialize(passphrase);
      } else {
        await vault.unlock(passphrase);
      }
    } catch (_) {
      setState(
        () => _error = creating
            ? 'Could not create the vault.'
            : 'Incorrect passphrase.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final existsAsync = ref.watch(vaultExistsProvider);
    final unlocking =
        ref.watch(vaultServiceProvider).status == VaultStatus.unlocking;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: existsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Could not read vault state.'),
            data: (exists) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(AppTokens.spacingLg),
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                  Text(
                    exists ? 'Unlock DocuMink' : 'Create your vault',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTokens.spacingSm),
                  Text(
                    exists
                        ? 'Enter your passphrase to unlock your encrypted vault.'
                        : 'Choose a passphrase. It encrypts everything on this '
                              'device and cannot be recovered if forgotten.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTokens.spacingLg),
                  TextField(
                    controller: _passphrase,
                    obscureText: true,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Passphrase',
                      border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Confirm passphrase',
                        border: OutlineInputBorder(),
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
                          : Text(exists ? 'Unlock' : 'Create vault'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
