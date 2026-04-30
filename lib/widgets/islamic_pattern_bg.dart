import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// خلفية إسلامية عصرية بنمط هندسي خفيف
class IslamicPatternBackground extends StatelessWidget {
  final bool showGradient;
  const IslamicPatternBackground({super.key, this.showGradient = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Container(
        decoration: showGradient
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          AppColors.backgroundDark,
                          Color(0xFF0A1929),
                          Color(0xFF0E2540),
                        ]
                      : const [
                          AppColors.backgroundLight,
                          Color(0xFFFFFCF3),
                          Color(0xFFF7F5EF),
                        ],
                ),
              )
            : null,
        child: CustomPaint(
          painter: _IslamicPatternPainter(isDark: isDark),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final bool isDark;
  _IslamicPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = (isDark ? AppColors.gold : AppColors.primary).withValues(alpha: 0.04);

    const step = 60.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, Offset(x, y), 18, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const points = 8;
    for (int i = 0; i < points * 2; i++) {
      final angle = i * pi / points;
      final radius = i.isEven ? r : r * 0.5;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
