import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';

/// NIST SP 800-38G **FF1** format-preserving encryption (Algorithm 7/8), built
/// on AES (pointycastle). FF1 only — **never FF3/FF3-1** (NIST withdrew it,
/// Feb 2025; blueprint §15 #/§7.1).
///
/// Operates on numeral lists (each element in `[0, radix)`). The string-level
/// digit handling + tweak derivation live in `FpeOperator`. Deterministic given
/// key + tweak, so reversal needs no stored state.
class Ff1 {
  Ff1({required Uint8List key, required this.radix})
    : assert(radix >= 2 && radix <= 65536, 'radix out of range'),
      _aes = AESEngine()..init(true, KeyParameter(key));

  final int radix;
  final AESEngine _aes;

  static const int _blockSize = 16;
  static const int _rounds = 10;

  /// FF1.Encrypt(K, T, X). [tweak] may be empty. Returns a new numeral list.
  List<int> encrypt(List<int> input, {required Uint8List tweak}) =>
      _feistel(input, tweak, encrypting: true);

  /// FF1.Decrypt(K, T, X).
  List<int> decrypt(List<int> input, {required Uint8List tweak}) =>
      _feistel(input, tweak, encrypting: false);

  List<int> _feistel(List<int> x, Uint8List t, {required bool encrypting}) {
    final n = x.length;
    if (n < 2) {
      throw ArgumentError('FF1 requires at least 2 numerals (got $n)');
    }
    final u = n ~/ 2;
    final v = n - u;
    var a = x.sublist(0, u);
    var b = x.sublist(u);

    final bLen = (_ceilLog2(radix) * v / 8).ceil();
    final d = 4 * ((bLen + 3) ~/ 4) + 4;
    final p = _buildP(n, t.length, u);

    final radixBigInt = BigInt.from(radix);
    final modU = radixBigInt.pow(u);
    final modV = radixBigInt.pow(v);

    for (var round = 0; round < _rounds; round++) {
      final i = encrypting ? round : _rounds - 1 - round;
      final m = (i % 2 == 0) ? u : v;
      final mod = (i % 2 == 0) ? modU : modV;

      // In decryption the halves are processed in reverse, operating on A.
      final feistelIn = encrypting ? b : a;
      final q = _buildQ(t, bLen, i, feistelIn);
      final r = _prf(Uint8List.fromList([...p, ...q]));
      final s = _expand(r, d);
      final y = _bytesToBigInt(s);

      final target = encrypting ? a : b;
      final BigInt c;
      if (encrypting) {
        c = (_numeralsToBigInt(target) + y) % mod;
      } else {
        c = (_numeralsToBigInt(target) - y) % mod;
      }
      final cNum = _bigIntToNumerals((c + mod) % mod, m);

      if (encrypting) {
        a = b;
        b = cNum;
      } else {
        b = a;
        a = cNum;
      }
    }
    return [...a, ...b];
  }

  /// P = [1,2,1, radix(3), 10, u mod 256, n(4), t(4)] — 16 bytes.
  Uint8List _buildP(int n, int t, int u) {
    final p = Uint8List(16);
    p[0] = 1;
    p[1] = 2;
    p[2] = 1;
    p[3] = (radix >> 16) & 0xff;
    p[4] = (radix >> 8) & 0xff;
    p[5] = radix & 0xff;
    p[6] = 10;
    p[7] = u & 0xff;
    _writeUint32(p, 7 + 1, n);
    _writeUint32(p, 11 + 1, t);
    return p;
  }

  /// Q = T ‖ 0^((-t-b-1) mod 16) ‖ [i] ‖ NUM_radix(B) as `bLen` bytes.
  Uint8List _buildQ(Uint8List t, int bLen, int i, List<int> feistelIn) {
    final pad = ((-t.length - bLen - 1) % _blockSize + _blockSize) % _blockSize;
    final numB = _bigIntToBytes(_numeralsToBigInt(feistelIn), bLen);
    return Uint8List.fromList([...t, ...List.filled(pad, 0), i, ...numB]);
  }

  /// PRF = AES-CBC-MAC with a zero IV over [x] (a multiple of 16 bytes).
  Uint8List _prf(Uint8List x) {
    var y = Uint8List(_blockSize);
    for (var off = 0; off < x.length; off += _blockSize) {
      final block = Uint8List(_blockSize);
      for (var j = 0; j < _blockSize; j++) {
        block[j] = y[j] ^ x[off + j];
      }
      y = _aesBlock(block);
    }
    return y;
  }

  /// S = first d bytes of R ‖ AES(R⊕[1]) ‖ AES(R⊕[2]) ‖ …
  Uint8List _expand(Uint8List r, int d) {
    final s = BytesBuilder()..add(r);
    var counter = 1;
    while (s.length < d) {
      final block = Uint8List(_blockSize);
      for (var j = 0; j < _blockSize; j++) {
        block[j] = r[j];
      }
      // XOR the big-endian counter into the low bytes.
      var c = counter;
      for (var j = _blockSize - 1; j >= 0 && c > 0; j--) {
        block[j] ^= c & 0xff;
        c >>= 8;
      }
      s.add(_aesBlock(block));
      counter++;
    }
    return s.toBytes().sublist(0, d);
  }

  Uint8List _aesBlock(Uint8List input) {
    final out = Uint8List(_blockSize);
    _aes.processBlock(input, 0, out, 0);
    return out;
  }

  static void _writeUint32(Uint8List buf, int offset, int value) {
    buf[offset] = (value >> 24) & 0xff;
    buf[offset + 1] = (value >> 16) & 0xff;
    buf[offset + 2] = (value >> 8) & 0xff;
    buf[offset + 3] = value & 0xff;
  }

  static int _ceilLog2(int radix) {
    var bits = 0;
    var pow = 1;
    while (pow < radix) {
      pow <<= 1;
      bits++;
    }
    return bits;
  }

  BigInt _numeralsToBigInt(List<int> numerals) {
    final r = BigInt.from(radix);
    var acc = BigInt.zero;
    for (final n in numerals) {
      acc = acc * r + BigInt.from(n);
    }
    return acc;
  }

  List<int> _bigIntToNumerals(BigInt value, int length) {
    final r = BigInt.from(radix);
    final out = List<int>.filled(length, 0);
    var v = value;
    for (var i = length - 1; i >= 0; i--) {
      out[i] = (v % r).toInt();
      v = v ~/ r;
    }
    return out;
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    var acc = BigInt.zero;
    for (final byte in bytes) {
      acc = (acc << 8) | BigInt.from(byte);
    }
    return acc;
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final out = Uint8List(length);
    var v = value;
    final mask = BigInt.from(0xff);
    for (var i = length - 1; i >= 0; i--) {
      out[i] = (v & mask).toInt();
      v = v >> 8;
    }
    return out;
  }
}
