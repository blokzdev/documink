// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'dart:async';

const allowList = [
  'mit',
  'apache-2.0',
  'bsd-2-clause',
  'bsd-3-clause',
  'isc',
  'zlib',
  'unlicense',
  'cc0-1.0',
];

const denyListSPDXPrefixes = ['gpl', 'agpl', 'cc-by-nc'];

const denyListTextSnippets = [
  'Qwen Research License',
  'Falcon Research License',
  'Llama Community License',
  'commercial use is strictly prohibited',
];

class PackageInfo {
  final String name;
  final String version;
  PackageInfo(this.name, this.version);
}

void main() async {
  var file = File('pubspec.lock');
  if (!file.existsSync()) {
    print('pubspec.lock not found.');
    exit(1);
  }

  var lines = file.readAsLinesSync();
  var packages = <PackageInfo>[];

  String? currentPkg;
  String? currentVersion;
  bool isHosted = false;
  bool isPubDev = false;

  bool inPackages = false;
  for (var line in lines) {
    if (line == 'packages:') {
      inPackages = true;
      continue;
    }
    if (inPackages) {
      if (line.startsWith('  ') && !line.startsWith('    ')) {
        if (currentPkg != null &&
            isHosted &&
            isPubDev &&
            currentVersion != null) {
          packages.add(PackageInfo(currentPkg, currentVersion));
        }
        currentPkg = line.trim().replaceAll(':', '');
        currentVersion = null;
        isHosted = false;
        isPubDev = false;
      } else if (line.startsWith('    ')) {
        if (line.contains('source: hosted')) isHosted = true;
        if (line.contains('url: "https://pub.dev"')) isPubDev = true;
        if (line.contains('version: "')) {
          var match = RegExp(r'version: "(.*)"').firstMatch(line);
          if (match != null) currentVersion = match.group(1);
        }
      } else if (!line.startsWith(' ') && line.isNotEmpty) {
        break;
      }
    }
  }
  if (currentPkg != null && isHosted && isPubDev && currentVersion != null) {
    packages.add(PackageInfo(currentPkg, currentVersion));
  }

  print('Checking licenses for ${packages.length} hosted packages...');

  var client = HttpClient();
  int concurrencyLimit = 8;
  int activeRequests = 0;
  List<PackageInfo> queue = List.from(packages);
  List<String> failedPackages = [];
  bool hasErrors = false;

  Completer<void> completer = Completer();

  Future<void> processQueue() async {
    while (queue.isNotEmpty) {
      var pkg = queue.removeAt(0);
      activeRequests++;

      bool success = await checkPackageLicense(client, pkg);
      if (!success) {
        failedPackages.add(pkg.name);
        hasErrors = true;
      }

      activeRequests--;
    }
    if (activeRequests == 0 && !completer.isCompleted) {
      completer.complete();
    }
  }

  for (int i = 0; i < concurrencyLimit && i < packages.length; i++) {
    processQueue();
  }

  await completer.future;
  client.close();

  if (hasErrors) {
    print('\nLicense check failed for the following packages:');
    for (var p in failedPackages) {
      print(' - $p');
    }
    exit(1);
  } else {
    print('\nAll package licenses are compliant.');
  }
}

Future<bool> checkPackageLicense(HttpClient client, PackageInfo pkg) async {
  int retries = 0;
  int delayMs = 1000;

  while (retries <= 3) {
    try {
      var req = await client.getUrl(
        Uri.parse('https://pub.dev/api/packages/${pkg.name}/metrics'),
      );
      var res = await req.close();

      if (res.statusCode == 429) {
        retries++;
        if (retries > 3) break;
        print('Rate limited on ${pkg.name}, backing off for \${delayMs}ms...');
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
        continue;
      }

      if (res.statusCode != 200) {
        print('Error fetching metrics for ${pkg.name}: ${res.statusCode}');
        return false;
      }

      var body = await res.transform(utf8.decoder).join();
      var data = jsonDecode(body);

      var scorecard = data['scorecard'];
      if (scorecard == null || scorecard['panaReport'] == null) {
        return checkFallback(pkg);
      }
      var tags =
          (scorecard['panaReport']['derivedTags'] as List<dynamic>?) ??
          (scorecard['panaReport']['tags'] as List<dynamic>?) ??
          <dynamic>[];

      var licenseTags = tags
          .where((dynamic t) => t.toString().startsWith('license:'))
          .toList();
      if (licenseTags.isEmpty || licenseTags.contains('license:unidentified')) {
        return checkFallback(pkg);
      }

      for (var lt in licenseTags) {
        String spdx = lt.toString().replaceFirst('license:', '').toLowerCase();

        if (spdx.startsWith('lgpl-')) {
          print(
            'WARNING: Package ${pkg.name} uses LGPL ($spdx). Requires case-by-case review.',
          );
          continue;
        }

        bool isDenied = denyListSPDXPrefixes.any(
          (prefix) => spdx.startsWith(prefix),
        );
        if (isDenied) {
          print('ERROR: Package ${pkg.name} has denied license: $spdx');
          return false;
        }

        if (!allowList.contains(spdx) &&
            spdx != 'osi-approved' &&
            spdx != 'fsf-libre') {
          print(
            'ERROR: Package ${pkg.name} has non-allowlisted license: $spdx',
          );
          return false;
        }
      }

      return true;
    } catch (e) {
      retries++;
      if (retries > 3) {
        print('Exception checking ${pkg.name}: $e');
        break;
      }
      await Future<void>.delayed(Duration(milliseconds: delayMs));
      delayMs *= 2;
    }
  }

  return false;
}

bool checkFallback(PackageInfo pkg) {
  print('Resolving fallback license for ${pkg.name}...');
  String? cacheDir = Platform.environment['PUB_CACHE'];
  if (cacheDir == null || cacheDir.isEmpty) {
    if (Platform.isWindows) {
      cacheDir = '${Platform.environment['LOCALAPPDATA']}\\Pub\\Cache';
    } else {
      cacheDir = '${Platform.environment['HOME']}/.pub-cache';
    }
  }

  var pkgDir = Directory('$cacheDir/hosted/pub.dev/${pkg.name}-${pkg.version}');
  if (!pkgDir.existsSync()) {
    print('ERROR: Package directory not found for fallback: ${pkgDir.path}');
    return false;
  }

  File? licenseFile;
  for (var name in [
    'LICENSE',
    'LICENSE.txt',
    'LICENSE.md',
    'license',
    'license.txt',
    'license.md',
  ]) {
    var f = File('${pkgDir.path}/$name');
    if (f.existsSync()) {
      licenseFile = f;
      break;
    }
  }

  if (licenseFile == null) {
    print(
      'ERROR: Unresolvable license for ${pkg.name}. No LICENSE file found.',
    );
    return false;
  }

  String content = licenseFile.readAsStringSync();
  String lowerContent = content.toLowerCase();
  for (var snippet in denyListTextSnippets) {
    if (lowerContent.contains(snippet.toLowerCase())) {
      print(
        'ERROR: Package ${pkg.name} matches deny-list text snippet: "$snippet"',
      );
      return false;
    }
  }

  print(
    'WARNING: Package ${pkg.name} has unidentified license, but passed deny-list text checks.',
  );
  return true;
}
