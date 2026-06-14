import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../security/signed_manifest.dart';
import 'template_manifest.dart';

/// Raised when the templates manifest is missing or fails verification. The app
/// never falls back to an unsigned templates catalog (blueprint §6.4).
class TemplateManifestException implements Exception {
  const TemplateManifestException(this.message);
  final String message;
  @override
  String toString() => 'TemplateManifestException: $message';
}

/// Loads the bundled, Ed25519-signed Verified-templates catalog, verifies it
/// against the pinned templates key (shared verification core), and parses it
/// (blueprint §6.3/§6.4). The bundled asset is the offline last-known-good;
/// the signed **remote** refresh from documink.ai/templates and CRDT-synced
/// personal templates are later slices (14b-2/14d) — this service is the seam.
class TemplateService {
  TemplateService({
    AssetBundle? bundle,
    String? pinnedPublicKeyBase64,
    String assetPath = signedTemplatesAsset,
  }) : _bundle = bundle ?? rootBundle,
       _pinnedPublicKeyBase64 = pinnedPublicKeyBase64 ?? defaultPublicKeyBase64,
       _assetPath = assetPath;

  /// Path to the bundled, signed templates manifest (offline last-known-good).
  static const String signedTemplatesAsset =
      'assets/template_manifest/manifest.signed.json';

  /// The pinned templates **public** key (Ed25519, base64), distinct from the
  /// model-manifest key. Development/review key; production pinned at release.
  static const String defaultPublicKeyBase64 =
      'XkIwMwRPVqE6aGeZSHvL+mPdHjkgTOwn3TmibaphVig=';

  final AssetBundle _bundle;
  final String _pinnedPublicKeyBase64;
  final String _assetPath;

  /// Verifies and returns the bundled Verified-templates catalog. Throws
  /// [TemplateManifestException] on any signature/format failure — never
  /// returns an unverified catalog.
  Future<TemplateManifest> verifiedManifest() async {
    final String signed;
    try {
      signed = await _bundle.loadString(_assetPath);
    } catch (e) {
      throw TemplateManifestException('templates manifest asset missing: $e');
    }
    final String body;
    try {
      body = await verifyEd25519SignedManifest(
        signed,
        pinnedPublicKeyBase64: _pinnedPublicKeyBase64,
      );
    } on SignedManifestException catch (e) {
      throw TemplateManifestException(e.message);
    }
    try {
      return TemplateManifest.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );
    } catch (e) {
      throw TemplateManifestException('verified body failed to parse: $e');
    }
  }

  /// The Verified templates (convenience over [verifiedManifest]).
  Future<List<TemplateDefinition>> verifiedTemplates() async =>
      (await verifiedManifest()).templates;
}
