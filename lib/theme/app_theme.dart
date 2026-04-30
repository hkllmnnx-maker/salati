import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

/// نظام السمات الفاخر (Premium Theme System)
/// يطبّق Material 3 مع تخصيص فني عربي/إسلامي راقٍ.
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════
  // نظام الطباعة - Premium Typography System
  // ═══════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(
    TextTheme base,
    Color primary,
    Color secondary,
    Color tertiary,
  ) {
    // Tajawal للنصوص العامة، Amiri للنصوص الدينية والعناوين الفاخرة
    return GoogleFonts.tajawalTextTheme(base).copyWith(
      // العناوين الكبيرة الفاخرة - Amiri (خط عربي كلاسيكي راقٍ)
      displayLarge: GoogleFonts.amiri(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.25,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.3,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.35,
      ),
      // العناوين - Tajawal (واضح وعصري)
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: primary,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: primary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.35,
      ),
      // العناوين الفرعية
      titleLarge: GoogleFonts.tajawal(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.4,
      ),
      // النصوص الأساسية
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.7,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.65,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: tertiary,
        height: 1.55,
      ),
      // العلامات
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: tertiary,
        letterSpacing: 0.4,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // السمة الفاتحة - Light Theme
  // ═══════════════════════════════════════════════════════
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    canvasColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD9E6F4),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.gold,
      onSecondary: Color(0xFF1A1A1A),
      secondaryContainer: AppColors.goldSoft,
      onSecondaryContainer: AppColors.goldDark,
      tertiary: AppColors.sage,
      onTertiary: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceLightElevated,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: Color(0xFFD8D4CB),
      outlineVariant: Color(0xFFEAE6DB),
      error: AppColors.error,
      onError: Colors.white,
      shadow: Color(0xFF0F2A47),
    ),
    textTheme: _buildTextTheme(
      ThemeData.light().textTheme,
      AppColors.textPrimaryLight,
      AppColors.textSecondaryLight,
      AppColors.textTertiaryLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
    dividerTheme: DividerThemeData(
      color: AppColors.primary.withValues(alpha: 0.06),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.tajawal(
        color: AppColors.textTertiaryLight,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.gold.withValues(alpha: 0.18),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.10)),
      labelStyle: GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      indicatorColor: AppColors.gold.withValues(alpha: 0.18),
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return IconThemeData(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.85),
        );
      }),
      elevation: 0,
      height: 70,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimaryLight,
      ),
      contentTextStyle: GoogleFonts.tajawal(
        fontSize: 14,
        color: AppColors.textSecondaryLight,
        height: 1.6,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      modalBackgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primaryDark,
      contentTextStyle: GoogleFonts.tajawal(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.gold,
      inactiveTrackColor: AppColors.gold.withValues(alpha: 0.18),
      thumbColor: AppColors.gold,
      overlayColor: AppColors.gold.withValues(alpha: 0.18),
      trackHeight: 4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.gold;
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.gold.withValues(alpha: 0.45);
        }
        return AppColors.primary.withValues(alpha: 0.15);
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.gold,
      linearTrackColor: Color(0x1A0F2A47),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.primary,
      textColor: AppColors.textPrimaryLight,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    splashFactory: InkRipple.splashFactory,
  );

  // ═══════════════════════════════════════════════════════
  // السمة الداكنة - Dark Theme
  // ═══════════════════════════════════════════════════════
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.gold,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    canvasColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: Color(0xFF071A30),
      primaryContainer: Color(0xFF3A2D14),
      onPrimaryContainer: AppColors.goldLight,
      secondary: AppColors.goldLight,
      onSecondary: Color(0xFF071A30),
      secondaryContainer: AppColors.surfaceDarkElevated,
      onSecondaryContainer: AppColors.goldLight,
      tertiary: AppColors.sageLight,
      onTertiary: Color(0xFF071A30),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceDarkElevated,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: Color(0xFF2A4060),
      outlineVariant: Color(0xFF1B3252),
      error: AppColors.errorLight,
      onError: Colors.white,
      shadow: Colors.black,
    ),
    textTheme: _buildTextTheme(
      ThemeData.dark().textTheme,
      AppColors.textPrimaryDark,
      AppColors.textSecondaryDark,
      AppColors.textTertiaryDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(color: AppColors.goldLight, size: 24),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.goldLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        side: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.4),
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.goldLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.goldLight, size: 24),
    dividerTheme: DividerThemeData(
      color: AppColors.gold.withValues(alpha: 0.10),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDarkElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.tajawal(
        color: AppColors.textTertiaryDark,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.10),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.10),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceDarkElevated,
      selectedColor: AppColors.gold.withValues(alpha: 0.25),
      side: BorderSide(color: AppColors.gold.withValues(alpha: 0.18)),
      labelStyle: GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      indicatorColor: AppColors.gold.withValues(alpha: 0.22),
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.gold);
        }
        return IconThemeData(
          color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
        );
      }),
      elevation: 0,
      height: 70,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimaryDark,
      ),
      contentTextStyle: GoogleFonts.tajawal(
        fontSize: 14,
        color: AppColors.textSecondaryDark,
        height: 1.6,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      modalBackgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceDarkElevated,
      contentTextStyle: GoogleFonts.tajawal(
        color: AppColors.textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.gold,
      inactiveTrackColor: AppColors.gold.withValues(alpha: 0.18),
      thumbColor: AppColors.gold,
      overlayColor: AppColors.gold.withValues(alpha: 0.18),
      trackHeight: 4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.gold;
        return AppColors.textTertiaryDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.gold.withValues(alpha: 0.45);
        }
        return AppColors.surfaceDarkElevated;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.gold,
      linearTrackColor: Color(0x33D4A84A),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.goldLight,
      textColor: AppColors.textPrimaryDark,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
