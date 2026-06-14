// Signs assets/model_manifest/manifest.json with the Ed25519 manifest key and
// writes assets/model_manifest/manifest.signed.json (models.md §5 authoring
// flow, step 4). Run: dart run tool/scripts/sign_manifest.dart
//
// SECURITY: the seed below is a DEVELOPMENT/REVIEW key only. The production
// manifest key is held in external secure key management and never committed;
// the app pins the production public key. Ed25519 signing is deterministic, so
// re-running reproduces a stable signature for the same manifest body.
// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

// DEV-ONLY 32-byte seed. Do NOT use for production signing.
final List<int> _devSeed = List<int>.generate(32, (i) => i + 1);

Future<void> main() async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(_devSeed);
  final publicKey = await keyPair.extractPublicKey();

  final body = File('assets/model_manifest/manifest.json').readAsStringSync();
  final signature = await algorithm.sign(utf8.encode(body), keyPair: keyPair);

  final signed = <String, dynamic>{
    'alg': 'ed25519',
    'key_id': 'documink-dev-v1',
    'signature': base64.encode(signature.bytes),
    'body': body,
  };
  File('assets/model_manifest/manifest.signed.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(signed)}\n',
  );

  print('Wrote assets/model_manifest/manifest.signed.json');
  print('Pinned public key (base64): ${base64.encode(publicKey.bytes)}');
}
