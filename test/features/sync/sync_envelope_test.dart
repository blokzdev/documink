import 'dart:typed_data';

import 'package:documink/features/sync/sync_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uint8List key(int fill) => Uint8List.fromList(List.filled(32, fill));
  final envelope = SyncEnvelope(key(0x11));
  final delta = Uint8List.fromList(List.generate(64, (i) => i));

  test('round-trips a delta', () async {
    final blob = await envelope.seal(delta, deltaId: 'd1', deviceId: 'devA');
    expect(blob.first, SyncEnvelope.version);
    final opened = await envelope.open(blob, deltaId: 'd1', deviceId: 'devA');
    expect(opened, delta);
  });

  test('round-trips an empty delta', () async {
    final blob = await envelope.seal(const [], deltaId: 'd', deviceId: 'x');
    expect(await envelope.open(blob, deltaId: 'd', deviceId: 'x'), isEmpty);
  });

  test('rejects a mismatched delta id (AAD binding)', () async {
    final blob = await envelope.seal(delta, deltaId: 'd1', deviceId: 'devA');
    expect(
      () => envelope.open(blob, deltaId: 'd2', deviceId: 'devA'),
      throwsA(isA<SyncEnvelopeError>()),
    );
  });

  test('rejects a mismatched device id (AAD binding)', () async {
    final blob = await envelope.seal(delta, deltaId: 'd1', deviceId: 'devA');
    expect(
      () => envelope.open(blob, deltaId: 'd1', deviceId: 'devB'),
      throwsA(isA<SyncEnvelopeError>()),
    );
  });

  test('rejects the wrong key', () async {
    final blob = await envelope.seal(delta, deltaId: 'd1', deviceId: 'devA');
    final other = SyncEnvelope(key(0x22));
    expect(
      () => other.open(blob, deltaId: 'd1', deviceId: 'devA'),
      throwsA(isA<SyncEnvelopeError>()),
    );
  });

  test('rejects tampered ciphertext', () async {
    final blob = await envelope.seal(delta, deltaId: 'd1', deviceId: 'devA');
    blob[blob.length - 1] ^= 0xff; // flip a tag/ct byte
    expect(
      () => envelope.open(blob, deltaId: 'd1', deviceId: 'devA'),
      throwsA(isA<SyncEnvelopeError>()),
    );
  });

  test('rejects an unknown version byte', () async {
    final blob = await envelope.seal(delta, deltaId: 'd1', deviceId: 'devA');
    blob[0] = 0x09;
    expect(
      () => envelope.open(blob, deltaId: 'd1', deviceId: 'devA'),
      throwsA(isA<SyncEnvelopeError>()),
    );
  });

  test('rejects a truncated blob', () async {
    expect(
      () => envelope.open(
        Uint8List.fromList([SyncEnvelope.version, 1, 2]),
        deltaId: 'd',
        deviceId: 'x',
      ),
      throwsA(isA<SyncEnvelopeError>()),
    );
  });

  test('nonce is random — same input seals to different blobs', () async {
    final a = await envelope.seal(delta, deltaId: 'd', deviceId: 'x');
    final b = await envelope.seal(delta, deltaId: 'd', deviceId: 'x');
    expect(a, isNot(b));
  });
}
