import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// خلفية إسلامية فنية بنمط هندسي راقٍ.
/// تستخدم نجمة ثمانية كلاسيكية مع طبقات متدرجة من الإضاءة لإعطاء عمق بصري.
class IslamicPatternBackground extends StatelessWidget {
  final bool showGradient;
  final double opacity;
  final bool subtle;

  const IslamicPatternBackground({
    super.key,
    this.showGradient = true,
    this.opacity = 1.0,
    this.subtle = false,
  });

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
                          Color(0xFF081424),
                          Color(0xFF0A1A2E),
                        ]
                      : const [
                          AppColors.backgroundLight,
                          Color(0xFFFFFCF3),
                          AppColors.backgroundLightAlt,
                        ],
                ),
              )
            : null,
        child: Stack(
          children: [
            // طبقة التوهج الذهبية في الأعلى
            if (showGradient)
              Positioned(
                top: -120,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withValues(
                          alpha: isDark ? 0.10 : 0.07,
                        ),
                        AppColors.gold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            // طبقة التوهج الزرقاء في الأسفل
            if (showGradient)
              Positioned(
                bottom: -150,
                left: -120,
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primarySoft.withValues(
                          alpha: isDark ? 0.18 : 0.06,
                        ),
                        AppColors.primarySoft.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            // النمط الهندسي
            Positioned.fill(
              child: Opacity(
                opacity: opacity,
                child: CustomPaint(
                  painter: _IslamicPatternPainter(
                    isDark: isDark,
                    subtle: subtle,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final bool isDark;
  final bool subtle;
  _IslamicPatternPainter({required this.isDark, required this.subtle});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDark ? AppColors.gold : AppColors.primary;
    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = baseColor.withValues(alpha: subtle ? 0.025 : 0.045);

    final paintFill = Paint()
      ..style = PaintingStyle.fill
      ..color = baseColor.withValues(alpha: subtle ? 0.012 : 0.02);

    const step = 80.0;
    bool offsetRow = false;
    for (double y = -step; y < size.height + step; y += step * 0.85) {
      for (double x = -step; x < size.width + step; x += step) {
        final cx = x + (offsetRow ? step / 2 : 0);
        _drawEightStar(canvas, Offset(cx, y), 14, paintLine, paintFill);
      }
      offsetRow = !offsetRow;
    }
  }

  /// رسم نجمة ثمانية كلاسيكية إسلامية (نجمة سليمان)
  void _drawEightStar(
    Canvas canvas,
    Offset center,
    double r,
    Paint stroke,
    Paint fill,
  ) {
    final path = Path();
    const points = 8;
    for (int i = 0; i < points * 2; i++) {
      final angle = i * pi / points - pi / 2;
      final radius = i.isEven ? r : r * 0.42;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // نجمة داخلية أصغر
    final innerPath = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = i * pi / points - pi / 2 + pi / points;
      final radius = i.isEven ? r * 0.55 : r * 0.25;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      if (i == 0) {
        innerPath.moveTo(dx, dy);
      } else {
        innerPath.lineTo(dx, dy);
      }
    }
    innerPath.close();
    canvas.drawPath(innerPath, stroke);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.subtle != subtle;
}

/// قوس إسلامي زخرفي - عنصر زخرفي للأقسام
class IslamicArchOrnament extends StatelessWidget {
  final Color color;
  final double size;
  const IslamicArchOrnament({
    super.key,
    this.color = AppColors.gold,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.5,
      child: CustomPaint(painter: _ArchPainter(color: color)),
    );
  }
}

class _ArchPainter extends CustomPainter {
  final Color color;
  _ArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(0, h);
    path.quadraticBezierTo(w * 0.25, -h * 0.4, w / 2, h * 0.05);
    path.quadraticBezierTo(w * 0.75, -h * 0.4, w, h);
    canvas.drawPath(path, paint);

    // نقطة في القمة
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(w / 2, h * 0.05), 1.6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
