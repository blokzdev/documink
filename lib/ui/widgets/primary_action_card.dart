import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A tappable primary-action tile on the Home hub: a tonal icon badge, a title +
/// description, and a chevron, with an ink ripple over the whole card.
class PrimaryActionCard extends StatelessWidget {
  const PrimaryActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.enabled = true,
    this.disabledTooltip,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  /// When false the card is greyed out and not tappable (disabled-not-hidden,
  /// e.g. a Tier-4 surface on a below-floor device). Phase 11b.
  final bool enabled;

  /// A11y/tooltip text explaining why the card is disabled (announced by
  /// TalkBack and shown on long-press). Used only when [enabled] is false.
  final String? disabledTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = enabled
        ? theme.colorScheme.onSurfaceVariant
        : theme.disabledColor;
    final card = Card(
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                      ),
                    ],
                  ),
                ),
                Icon(
                  enabled ? Icons.chevron_right : Icons.lock_outline,
                  color: fg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (enabled) return card;
    // Disabled: announce the reason (TalkBack) and show it on long-press.
    return Semantics(
      enabled: false,
      button: true,
      label: '$label. ${disabledTooltip ?? ''}'.trim(),
      excludeSemantics: true,
      child: disabledTooltip == null
          ? card
          : Tooltip(message: disabledTooltip!, child: card),
    );
  }
}
