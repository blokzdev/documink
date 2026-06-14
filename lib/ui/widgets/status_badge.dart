import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A small status pill for a document lifecycle state (draft / redacted /
/// exported). Colour-coded, tone-mapped for light & dark.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final String status;

  static const _green = Color(0xFF16A34A);
  static const _amber = Color(0xFFD97706);
  static const _teal = Color(0xFF0D9488);
  static const _slate = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final (label, hue) = switch (status) {
      'redacted' => ('Redacted', _green),
      'draft' => ('Draft', _amber),
      'exported' => ('Exported', _teal),
      _ => (status, _slate),
    };
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Color.lerp(hue, Colors.white, 0.55)! : hue;

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingSm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: hue.withValues(alpha: dark ? 0.24 : 0.14),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
