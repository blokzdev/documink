import 'package:flutter/material.dart';

import '../../features/memory/token_reference.dart';
import '../theme/app_typography.dart';

/// Renders chat/memory text with inline token references (`<<tok_…>>`, Form B)
/// **masked**. Masking is the privacy default (memory.md §8); a per-view
/// biometric reveal arrives with `decode_token` wiring — until then references
/// always render as a muted `⟨hidden⟩` chip so decoded values never surface.
class TokenText extends StatelessWidget {
  const TokenText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium;
    final masked = AppTypography.mono(context).copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    final matches = inlineTokenMarker.allMatches(text).toList();
    if (matches.isEmpty) return Text(text, style: base);

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start)));
      }
      spans.add(TextSpan(text: '⟨hidden⟩', style: masked));
      cursor = m.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
