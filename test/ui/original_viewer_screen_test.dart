import 'dart:convert';

import 'package:documink/features/security/screen_security.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/original_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingSecurity implements ScreenSecurity {
  int enabled = 0;
  int disabled = 0;
  @override
  Future<void> enable() async => enabled++;
  @override
  Future<void> disable() async => disabled++;
}

// A minimal valid 1×1 transparent PNG.
final _png1x1 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M8A'
  'AAMBAQDJ/pLvAAAAAElFTkSuQmCC',
);

void main() {
  testWidgets('image viewer renders the image and toggles FLAG_SECURE', (
    tester,
  ) async {
    final security = _RecordingSecurity();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [screenSecurityProvider.overrideWithValue(security)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OriginalViewerScreen(bytes: _png1x1, mime: 'image/png'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('original-image')), findsOneWidget);
    expect(security.enabled, 1);
    expect(security.disabled, 0);

    // Leaving the screen clears FLAG_SECURE.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(security.disabled, 1);
  });
}
