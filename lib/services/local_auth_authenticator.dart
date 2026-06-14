import 'package:local_auth/local_auth.dart';

import 'authenticator.dart';

/// Platform [Authenticator] backed by `local_auth` (Android BiometricPrompt /
/// device credential; Windows Hello on V2). Wired at bootstrap.
class LocalAuthAuthenticator implements Authenticator {
  LocalAuthAuthenticator([LocalAuthentication? localAuth])
    : _auth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      // Treat any platform error (no enrollment, cancelled, unavailable) as a
      // denial — never reveal on an ambiguous result.
      return false;
    }
  }
}
