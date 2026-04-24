// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  var file = File('tool/model_hashes.json');
  if (!file.existsSync()) {
    print('tool/model_hashes.json not found.');
    exit(1);
  }

  var content = file.readAsStringSync();
  var data = jsonDecode(content);
  var models = data['models'] as List<dynamic>?;

  if (models == null || models.isEmpty) {
    print('No bundled models to verify');
    exit(0);
  }

  bool hasErrors = false;
  for (var m in models) {
    String path = m['path'] as String;
    String expectedHash = m['sha256'] as String;

    var modelFile = File(path);
    if (!modelFile.existsSync()) {
      print('ERROR: Model file not found: $path');
      hasErrors = true;
      continue;
    }

    var bytes = modelFile.readAsBytesSync();
    var digest = sha256.convert(bytes);

    if (digest.toString() != expectedHash) {
      print('ERROR: Hash mismatch for $path');
      print('  Expected: $expectedHash');
      print('  Actual:   $digest');
      hasErrors = true;
    } else {
      print('Verified: $path');
    }
  }

  if (hasErrors) {
    exit(1);
  }
}
