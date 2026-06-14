// Signs assets/template_manifest/manifest.json with the Ed25519 templates key
// and writes assets/template_manifest/manifest.signed.json (blueprint §6.4
// authoring flow). Run: dart run tool/scripts/sign_template_manifest.dart
//
// SECURITY: the seed below is a DEVELOPMENT/REVIEW key only, and is distinct
// from the model-manifest key. The production templates key is held in external
// secure key management and never committed; the app pins the production public
// key. Ed25519 signing is deterministic, so re-running reproduces a stable
// signature for the same manifest body.
// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

// DEV-ONLY 32-byte seed, distinct from the model-manifest seed. Do NOT use for
// production signing.
final List<int> _devSeed = List<int>.generate(32, (i) => i + 50);

Future<void> main() async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(_devSeed);
  final publicKey = await keyPair.extractPublicKey();

  final body = File(
    'assets/template_manifest/manifest.json',
  ).readAsStringSync();
  final signature = await algorithm.sign(utf8.encode(body), keyPair: keyPair);

  final signed = <String, dynamic>{
    'alg': 'ed25519',
    'key_id': 'documink-templates-dev-v1',
    'signature': base64.encode(signature.bytes),
    'body': body,
  };
  File('assets/template_manifest/manifest.signed.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(signed)}\n',
  );

  print('Wrote assets/template_manifest/manifest.signed.json');
  print('Pinned public key (base64): ${base64.encode(publicKey.bytes)}');
}
