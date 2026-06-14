import 'dart:async';
import 'dart:isolate';

/// Outcome of a sandboxed regex preview.
enum RegexPreviewStatus {
  /// Pattern compiled and matching finished within the time budget.
  ok,

  /// Pattern failed to compile.
  error,

  /// Matching exceeded the time budget and was aborted (likely catastrophic
  /// backtracking / ReDoS).
  timedOut,
}

/// A single preview match (offsets into the sample).
class RegexPreviewMatch {
  const RegexPreviewMatch(this.start, this.end, this.text);
  final int start;
  final int end;
  final String text;
}

/// Result of [RegexSandbox.preview].
class RegexPreviewResult {
  const RegexPreviewResult.ok(this.matches)
    : status = RegexPreviewStatus.ok,
      errorMessage = null;
  const RegexPreviewResult.error(this.errorMessage)
    : status = RegexPreviewStatus.error,
      matches = const [];
  const RegexPreviewResult.timedOut()
    : status = RegexPreviewStatus.timedOut,
      matches = const [],
      errorMessage = null;

  final RegexPreviewStatus status;
  final List<RegexPreviewMatch> matches;
  final String? errorMessage;
}

/// Runs a user-supplied regex against sample text in a **disposable isolate**
/// with a hard timeout, so a catastrophic pattern (ReDoS) can never hang the UI
/// thread (roadmap §6 "regex sandbox with live preview"). On timeout the isolate
/// is killed immediately.
class RegexSandbox {
  const RegexSandbox({
    this.timeout = const Duration(milliseconds: 500),
    this.maxSampleLength = 10000,
  });

  final Duration timeout;

  /// The sample is truncated to this many characters before matching (defense
  /// in depth — bounds the work regardless of timeout).
  final int maxSampleLength;

  Future<RegexPreviewResult> preview(String pattern, String sample) async {
    final bounded = sample.length > maxSampleLength
        ? sample.substring(0, maxSampleLength)
        : sample;

    final receivePort = ReceivePort();
    final Isolate isolate;
    try {
      isolate = await Isolate.spawn(_worker, [
        receivePort.sendPort,
        pattern,
        bounded,
      ], errorsAreFatal: true);
    } catch (_) {
      receivePort.close();
      return const RegexPreviewResult.error('failed to start sandbox');
    }

    try {
      final message = await receivePort.first.timeout(timeout);
      final map = message as Map<String, dynamic>;
      if (map.containsKey('error')) {
        return RegexPreviewResult.error(map['error'] as String);
      }
      final ranges = (map['matches'] as List<dynamic>).cast<List<dynamic>>();
      return RegexPreviewResult.ok([
        for (final r in ranges)
          RegexPreviewMatch(
            r[0] as int,
            r[1] as int,
            bounded.substring(r[0] as int, r[1] as int),
          ),
      ]);
    } on TimeoutException {
      return const RegexPreviewResult.timedOut();
    } finally {
      isolate.kill(priority: Isolate.immediate);
      receivePort.close();
    }
  }

  static void _worker(List<dynamic> args) {
    final send = args[0] as SendPort;
    final pattern = args[1] as String;
    final sample = args[2] as String;
    try {
      final regExp = RegExp(pattern);
      final matches = <List<int>>[
        for (final m in regExp.allMatches(sample))
          if (m.end > m.start) [m.start, m.end],
      ];
      send.send(<String, dynamic>{'matches': matches});
    } catch (e) {
      send.send(<String, dynamic>{'error': e.toString()});
    }
  }
}
