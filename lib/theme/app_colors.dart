import 'package:flutter/material.dart';

/// نظام الألوان الفاخر لتطبيق "صلاتي"
/// مستوحى من الفن الإسلامي الأندلسي والعثماني، بلمسة عصرية راقية.
///
/// الفلسفة اللونية:
/// - الأزرق العميق (Midnight Sapphire): يرمز إلى السماء الليلية والسكينة الروحية.
/// - الذهب الملكي (Royal Gold): يرمز إلى قبب المساجد والزخارف العريقة.
/// - الكريمي الدافئ (Warm Ivory): يرمز إلى صفحات المخطوطات القديمة.
/// - الأخضر الفيروزي الإسلامي (Sage Teal): يرمز إلى الراحة والأمل.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════
  // الألوان الأساسية - Brand Core
  // ═══════════════════════════════════════════════════════

  /// أزرق ياقوتي عميق - اللون الأساسي
  static const Color primary = Color(0xFF0F2A47);
  static const Color primaryLight = Color(0xFF1B4574);
  static const Color primaryDark = Color(0xFF071A30);
  static const Color primarySoft = Color(0xFF2A5C8F);

  /// ذهب ملكي - اللون الثانوي
  static const Color gold = Color(0xFFD4A84A);
  static const Color goldLight = Color(0xFFE9C77B);
  static const Color goldDark = Color(0xFFA8842F);
  static const Color goldSoft = Color(0xFFF3E0AC);

  /// أخضر فيروزي إسلامي - لمسة هادئة
  static const Color sage = Color(0xFF3D7A6E);
  static const Color sageLight = Color(0xFF6BA89B);

  // ═══════════════════════════════════════════════════════
  // الخلفيات والأسطح - Backgrounds & Surfaces
  // ═══════════════════════════════════════════════════════

  /// خلفية فاتحة كريمية دافئة (مستوحاة من ورق المخطوطات)
  static const Color backgroundLight = Color(0xFFFAF7F0);
  static const Color backgroundLightAlt = Color(0xFFF5F1E8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightElevated = Color(0xFFFEFCF7);

  /// خلفية داكنة - أزرق ليلي عميق
  static const Color backgroundDark = Color(0xFF050E1C);
  static const Color backgroundDarkAlt = Color(0xFF0A1628);
  static const Color surfaceDark = Color(0xFF101F36);
  static const Color surfaceDarkElevated = Color(0xFF152944);

  // ═══════════════════════════════════════════════════════
  // النصوص - Typography Colors
  // ═══════════════════════════════════════════════════════

  static const Color textPrimaryLight = Color(0xFF0E1F33);
  static const Color textSecondaryLight = Color(0xFF5C6A7A);
  static const Color textTertiaryLight = Color(0xFF8B98A8);
  static const Color textPrimaryDark = Color(0xFFF5F1E8);
  static const Color textSecondaryDark = Color(0xFFB8C2D1);
  static const Color textTertiaryDark = Color(0xFF7A8699);

  // ═══════════════════════════════════════════════════════
  // ألوان الحالة - Semantic Colors
  // ═══════════════════════════════════════════════════════

  static const Color success = Color(0xFF2E8E5F);
  static const Color successLight = Color(0xFF4FB683);
  static const Color warning = Color(0xFFD89A2C);
  static const Color warningLight = Color(0xFFEDB857);
  static const Color error = Color(0xFFC0392B);
  static const Color errorLight = Color(0xFFE05C4D);
  static const Color info = Color(0xFF2C7CB0);
  static const Color infoLight = Color(0xFF5BA0D1);

  // ═══════════════════════════════════════════════════════
  // ألوان الصلوات - Prayer-specific Colors
  // ═══════════════════════════════════════════════════════

  /// الفجر - أزرق فضي قبل الفجر
  static const Color fajr = Color(0xFF4A6FA5);
  static const Color fajrAccent = Color(0xFF7B97C5);

  /// الشروق - برتقالي ذهبي ناعم
  static const Color sunrise = Color(0xFFE89B4A);
  static const Color sunriseAccent = Color(0xFFF4BD7E);

  /// الظهر - ذهبي مشمس
  static const Color dhuhr = Color(0xFFE6B33D);
  static const Color dhuhrAccent = Color(0xFFF1CD75);

  /// العصر - برتقالي دافئ
  static const Color asr = Color(0xFFD9803F);
  static const Color asrAccent = Color(0xFFE8A672);

  /// المغرب - أحمر غروب ناعم
  static const Color maghrib = Color(0xFFB54E45);
  static const Color maghribAccent = Color(0xFFD4796F);

  /// العشاء - أزرق ليلي عميق
  static const Color isha = Color(0xFF2D3F66);
  static const Color ishaAccent = Color(0xFF526990);

  // ═══════════════════════════════════════════════════════
  // التدرجات الفاخرة - Premium Gradients
  // ═══════════════════════════════════════════════════════

  /// تدرج ليلي عميق - للبطاقات الرئيسية
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF071A30), Color(0xFF0F2A47), Color(0xFF1B4574)],
    stops: [0.0, 0.55, 1.0],
  );

  /// تدرج النهار - للوضع الفاتح
  static const LinearGradient dayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF7F0), Color(0xFFF5F1E8), Color(0xFFEEE5D0)],
  );

  /// تدرج ذهبي ملكي
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3E0AC), Color(0xFFD4A84A), Color(0xFFA8842F)],
    stops: [0.0, 0.5, 1.0],
  );

  /// تدرج البطاقة البطلة - أزرق فاخر
  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B4574),
      Color(0xFF0F2A47),
      Color(0xFF071A30),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// توافقية قديمة - تدرج البطاقة (alias)
  static const LinearGradient cardGradient = heroCardGradient;

  /// توهج ذهبي خفيف للخلفيات
  static const RadialGradient goldGlow = RadialGradient(
    colors: [Color(0x40D4A84A), Color(0x00D4A84A)],
    radius: 0.8,
  );

  /// تدرج زجاجي فاتح
  static LinearGradient glassLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.95),
      Colors.white.withValues(alpha: 0.75),
    ],
  );

  /// تدرج زجاجي داكن
  static LinearGradient glassDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF152944).withValues(alpha: 0.85),
      const Color(0xFF0A1628).withValues(alpha: 0.75),
    ],
  );

  /// خط ذهبي رفيع للحدود
  static LinearGradient goldBorderGradient = const LinearGradient(
    colors: [
      Color(0x00D4A84A),
      Color(0xFFD4A84A),
      Color(0xFFE9C77B),
      Color(0xFFD4A84A),
      Color(0x00D4A84A),
    ],
  );

  // ═══════════════════════════════════════════════════════
  // ألوان مساعدة للأشكال الزجاجية
  // ═══════════════════════════════════════════════════════

  static Color glassBgLight(double opacity) =>
      Colors.white.withValues(alpha: opacity);

  static Color glassBgDark(double opacity) =>
      const Color(0xFF152944).withValues(alpha: opacity);

  static Color overlayDark(double opacity) =>
      Colors.black.withValues(alpha: opacity);
}
