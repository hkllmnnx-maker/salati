import 'package:flutter/material.dart';
import 'app_colors.dart';

/// رموز التصميم الموحدة (Design Tokens)
/// مستوحاة من أنظمة تصميم عالمية: Apple HIG, Material 3, Linear, Vercel
class AppSpacing {
  AppSpacing._();
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 56.0;
}

class AppRadius {
  AppRadius._();
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double pill = 999.0;
}

class AppShadows {
  AppShadows._();

  /// ظل ناعم - للبطاقات الخفيفة
  static List<BoxShadow> soft({bool isDark = false}) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.35)
              : AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// ظل متوسط - للبطاقات المرتفعة
  static List<BoxShadow> medium({bool isDark = false}) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : AppColors.primary.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// ظل قوي - للبطاقات البطلة
  static List<BoxShadow> strong({bool isDark = false}) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.55)
              : AppColors.primary.withValues(alpha: 0.18),
          blurRadius: 36,
          offset: const Offset(0, 14),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.30)
              : AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// ظل ذهبي مضيء - للعناصر الفاخرة
  static List<BoxShadow> goldGlow({double intensity = 0.3}) => [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: intensity),
          blurRadius: 32,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: AppColors.gold.withValues(alpha: intensity * 0.4),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  /// ظل مضيء داخلي للعناصر المضيئة
  static List<BoxShadow> innerLight({bool isDark = false}) => [
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.7),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ];
}

class AppDurations {
  AppDurations._();
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration slower = Duration(milliseconds: 600);
}

class AppCurves {
  AppCurves._();
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve decelerate = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve accelerate = Cubic(0.3, 0.0, 1.0, 1.0);
}
