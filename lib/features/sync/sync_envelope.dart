import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Raised when a sync envelope fails to open: wrong key, tampered bytes, a
/// mismatched delta-id/device-id binding, or an unknown version.
class SyncEnvelopeError implements Exception {
  const SyncEnvelopeError(this.message);
  final String message;
  @override
  String toString() => 'SyncEnvelopeError: $message';
}

/// Seals/opens CRDT sync deltas for transport (blueprint §9.1/§9.2: "never sync
/// plaintext"; deltas stored as `deltas/<ulid>.cbor.enc`, AES-GCM-encrypted).
///
/// The delta payload bytes are opaque here (cr-sqlite's CBOR-encoded delta at
/// runtime). This layer adds the encryption envelope only: AES-256-GCM under the
/// **sync key** (HKDF-derived from the Master Key, `documink:sync:v1`), with the
/// **delta id** (the `<ulid>` filename) and **origin device id** bound as AAD so
/// a delta can't be relabelled, replayed under a different name, or attributed
/// to another device without failing authentication.
///
/// Wire format: `version(1) ‖ nonce(12) ‖ ciphertext ‖ mac(16)`.
class SyncEnvelope {
  SyncEnvelope(this.syncKey)
    : assert(syncKey.length == 32, 'sync key must be 32 bytes');

  /// 32-byte transport key (KeyService `syncKey`). Held only while unlocked.
  final Uint8List syncKey;

  static const int version = 1;
  static const int _nonceLength = 12;
  static const int _macLength = 16;

  final AesGcm _algorithm = AesGcm.with256bits();

  /// Seals [deltaBytes] into a transport blob, binding [deltaId] + [deviceId]
  /// as AAD.
  Future<Uint8List> seal(
    List<int> deltaBytes, {
    required String deltaId,
    required String deviceId,
  }) async {
    final box = await _algorithm.encrypt(
      deltaBytes,
      secretKey: SecretKey(syncKey),
      aad: _aad(deltaId, deviceId),
    );
    return Uint8List.fromList([version, ...box.concatenation()]);
  }

  /// Reverses [seal]. Throws [SyncEnvelopeError] on any failure (bad version,
  /// truncated blob, wrong key, tamper, or AAD mismatch).
  Future<Uint8List> open(
    Uint8List blob, {
    required String deltaId,
    required String deviceId,
  }) async {
    if (blob.isEmpty || blob[0] != version) {
      throw SyncEnvelopeError(
        'unsupported envelope version: ${blob.isEmpty ? 'none' : blob[0]}',
      );
    }
    if (blob.length < 1 + _nonceLength + _macLength) {
      throw const SyncEnvelopeError('truncated envelope');
    }
    final box = SecretBox.fromConcatenation(
      blob.sublist(1),
      nonceLength: _nonceLength,
      macLength: _macLength,
    );
    try {
      final clear = await _algorithm.decrypt(
        box,
        secretKey: SecretKey(syncKey),
        aad: _aad(deltaId, deviceId),
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      throw const SyncEnvelopeError(
        'authentication failed (wrong key, tampered bytes, or id/device mismatch)',
      );
    }
  }

  // Domain-separated AAD over the binding fields, 0x00-delimited so the encoding
  // is injective (distinct (deltaId, deviceId) pairs never collide).
  List<int> _aad(String deltaId, String deviceId) => <int>[
    ...utf8.encode('documink:sync:v1'),
    0,
    ...utf8.encode(deltaId),
    0,
    ...utf8.encode(deviceId),
  ];
}
