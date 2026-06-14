/// Formats an epoch-millis timestamp as `YYYY-MM-DD HH:MM` (local), without
/// pulling in `intl`. Used for document/audit timestamps.
String formatTimestamp(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
