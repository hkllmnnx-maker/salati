import 'package:flutter/material.dart';

/// نظام الألوان الخاص بتطبيق "صلاتي"
/// مستوحى من ألوان الأيقونة: أزرق ليلي عميق وذهب فاخر
class AppColors {
  AppColors._();

  // الألوان الأساسية - مستوحاة من الأيقونة
  static const Color primary = Color(0xFF0E3A5F); // أزرق ليلي
  static const Color primaryLight = Color(0xFF1B5283);
  static const Color primaryDark = Color(0xFF062340);

  static const Color gold = Color(0xFFD4AF37); // ذهبي فاخر
  static const Color goldLight = Color(0xFFE8C66B);
  static const Color goldDark = Color(0xFFB08D1F);

  // ألوان الخلفية
  static const Color backgroundLight = Color(0xFFF7F5EF);
  static const Color backgroundDark = Color(0xFF0A1929);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF132B45);

  // ألوان النصوص
  static const Color textPrimaryLight = Color(0xFF0E1F33);
  static const Color textSecondaryLight = Color(0xFF5A6A7A);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  // ألوان الحالة
  static const Color success = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFFD89A2C);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF2C7CB0);

  // ألوان مخصصة لكل صلاة
  static const Color fajr = Color(0xFF3B5998); // أزرق هادئ - الفجر
  static const Color sunrise = Color(0xFFE6A23C); // برتقالي ذهبي - الشروق
  static const Color dhuhr = Color(0xFFF1C40F); // أصفر ساطع - الظهر
  static const Color asr = Color(0xFFE67E22); // برتقالي - العصر
  static const Color maghrib = Color(0xFFC0392B); // أحمر غروب - المغرب
  static const Color isha = Color(0xFF1A2942); // أزرق ليلي - العشاء

  // تدرجات للخلفيات
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF062340), Color(0xFF0E3A5F), Color(0xFF1B5283)],
  );

  static const LinearGradient dayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8C66B), Color(0xFFF7F5EF), Color(0xFFFFFFFF)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C66B), Color(0xFFD4AF37), Color(0xFFB08D1F)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5283), Color(0xFF0E3A5F)],
  );
}
