// ignore_for_file: avoid_print
import 'dart:io';

const bannedPackages = [
  'firebase_analytics',
  'firebase_crashlytics',
  'mixpanel_flutter',
  'mixpanel',
  'amplitude_flutter',
  'segment_plugin',
  'analytics',
  'google_analytics',
  'google_tagmanager',
];

void main() {
  bool hasErrors = false;

  // 1. Check pubspec.lock
  var file = File('pubspec.lock');
  if (file.existsSync()) {
    var lines = file.readAsLinesSync();
    var packageRegex = RegExp(r'^  ([a-zA-Z0-9_]+):');
    bool inPackages = false;
    for (var line in lines) {
      if (line == 'packages:') {
        inPackages = true;
        continue;
      }
      if (inPackages) {
        if (line.startsWith('  ') && !line.startsWith('    ')) {
          var match = packageRegex.firstMatch(line);
          if (match != null) {
            String pkg = match.group(1)!;
            if (bannedPackages.contains(pkg) ||
                pkg.startsWith('ad_') ||
                pkg.startsWith('ads_') ||
                pkg.startsWith('admob_')) {
              print('ERROR: Banned package found in pubspec.lock: $pkg');
              hasErrors = true;
            }
          }
        } else if (!line.startsWith(' ') && line.isNotEmpty) {
          break;
        }
      }
    }
  }

  // 2. Scan Dart files in specific directories
  var dirsToScan = ['lib', 'test', 'integration_test', 'tool'];
  var dartFiles = <File>[];

  for (var dirName in dirsToScan) {
    var dir = Directory(dirName);
    if (dir.existsSync()) {
      dartFiles.addAll(
        dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
      );
    }
  }

  for (var f in dartFiles) {
    // Skip this script itself to prevent false positives
    if (f.path.contains('check_analytics_sdks.dart')) continue;

    var content = f.readAsStringSync();

    for (var banned in bannedPackages) {
      if (content.contains(banned)) {
        print('ERROR: Banned string "$banned" found in ${f.path}');
        hasErrors = true;
      }
    }

    // Dynamic import checks
    var lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.startsWith('import ') && line.contains('package:')) {
        var match = RegExp(r"package:([a-zA-Z0-9_]+)/").firstMatch(line);
        if (match != null) {
          String pkg = match.group(1)!;
          if (pkg.startsWith('ad_') ||
              pkg.startsWith('ads_') ||
              pkg.startsWith('admob_')) {
            print(
              'ERROR: Banned ad package import "$pkg" found in ${f.path}:${i + 1}',
            );
            hasErrors = true;
          }
        }
      }
    }
  }

  if (hasErrors) {
    print('Analytics/Ads check failed.');
    exit(1);
  } else {
    print('Analytics/Ads check passed.');
  }
}
