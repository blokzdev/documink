import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// The DocuMink glyph — a rounded "document" tile with redaction bars (one
/// accent), painted as a vector so it needs no image asset and scales crisply.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandPainter(
          tile: scheme.primary,
          bar: scheme.onPrimary,
          accent: AppColors.accent,
        ),
      ),
    );
  }
}

class _BrandPainter extends CustomPainter {
  _BrandPainter({required this.tile, required this.bar, required this.accent});

  final Color tile;
  final Color bar;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & Size(s, s),
      Radius.circular(s * 0.28),
    );
    canvas.drawRRect(rrect, Paint()..color = tile);

    // Three redaction bars; the middle one is the accent (a "revealed" line).
    final left = s * 0.22;
    final barHeight = s * 0.1;
    final radius = Radius.circular(barHeight / 2);
    final widths = [0.56, 0.42, 0.5];
    final colors = [bar, accent, bar];
    for (var i = 0; i < 3; i++) {
      final top = s * (0.3 + i * 0.18);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, s * widths[i], barHeight),
        radius,
      );
      canvas.drawRRect(
        r,
        Paint()..color = colors[i].withValues(alpha: i == 1 ? 1 : 0.92),
      );
    }
  }

  @override
  bool shouldRepaint(_BrandPainter old) =>
      old.tile != tile || old.bar != bar || old.accent != accent;
}

/// Glyph + wordmark ("Docu" + accented "Mink"). Used on unlock / home headers.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.markSize = 40});

  final double markSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'DocuMink',
      container: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: markSize),
            const SizedBox(width: AppTokens.spacingSm),
            Text.rich(
              TextSpan(
                style: theme.textTheme.headlineSmall,
                children: [
                  const TextSpan(text: 'Docu'),
                  TextSpan(
                    text: 'Mink',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
