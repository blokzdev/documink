import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// A compact, colour-coded pill for a detected PII entity type — a hue dot + the
/// label + an optional count. Colour comes from [AppColors.entityColor]; the
/// foreground is tone-mapped for contrast in light and dark.
class EntityChip extends StatelessWidget {
  const EntityChip({super.key, required this.label, this.count});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hue = AppColors.entityColor(label);
    final bg = hue.withValues(alpha: dark ? 0.24 : 0.14);
    final fg = dark ? Color.lerp(hue, Colors.white, 0.55)! : hue;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingSm,
        vertical: AppTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: hue, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTokens.spacingSm),
          Text(
            count == null ? label : '$label · $count',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
