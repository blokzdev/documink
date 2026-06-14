import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gates a privacy-sensitive action (e.g. revealing a reversible token, §5
/// `decode`) behind device auth. Implemented by the platform biometric/credential
/// prompt in production; tests inject a fake.
abstract interface class Authenticator {
  /// Returns true iff the user successfully authenticated.
  Future<bool> authenticate({required String reason});
}

/// Always-deny [Authenticator] — the safe default so a reveal can never bypass
/// auth if the real implementation wasn't wired. Bootstrap overrides this with
/// the platform authenticator; tests override with a controllable fake.
class DenyingAuthenticator implements Authenticator {
  const DenyingAuthenticator();

  @override
  Future<bool> authenticate({required String reason}) async => false;
}

/// The app authenticator. Overridden at bootstrap with the platform
/// implementation; defaults to deny-all (never reveals without real auth).
final authenticatorProvider = Provider<Authenticator>(
  (ref) => const DenyingAuthenticator(),
);
