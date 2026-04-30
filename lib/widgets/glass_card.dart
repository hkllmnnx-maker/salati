import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// بطاقة زجاجية فاخرة بنمط Glassmorphism متعدد الطبقات.
/// تدعم تدرجات داخلية ناعمة وحدودًا ذهبية رفيعة وظلًا متعدد الطبقات.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool elevated;
  final bool goldBorder;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.radius = AppRadius.lg,
    this.elevated = false,
    this.goldBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = goldBorder
        ? AppColors.gold.withValues(alpha: isDark ? 0.32 : 0.28)
        : isDark
            ? AppColors.gold.withValues(alpha: 0.10)
            : AppColors.primary.withValues(alpha: 0.07);

    final card = AnimatedContainer(
      duration: AppDurations.normal,
      curve: AppCurves.standard,
      margin: margin,
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceDarkElevated.withValues(alpha: 0.92),
                  AppColors.surfaceDark.withValues(alpha: 0.82),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.97),
                  Colors.white.withValues(alpha: 0.85),
                ],
              ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: goldBorder ? 1.2 : 1),
        boxShadow: elevated
            ? AppShadows.medium(isDark: isDark)
            : AppShadows.soft(isDark: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            splashColor: AppColors.gold.withValues(alpha: 0.08),
            highlightColor: AppColors.gold.withValues(alpha: 0.04),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

/// بطاقة فاخرة بتدرج كامل (للعناصر البطلة)
class HeroGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Gradient? gradient;
  final bool showShine;

  const HeroGradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.radius = AppRadius.xl,
    this.gradient,
    this.showShine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: gradient ?? AppColors.heroCardGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 36,
            offset: const Offset(0, 16),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // طبقة الزخرفة العلوية
            if (showShine)
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.32),
                        AppColors.gold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            if (showShine)
              Positioned(
                bottom: -60,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primarySoft.withValues(alpha: 0.4),
                        AppColors.primarySoft.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            // حدود ذهبية لامعة داخلية
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// شريحة معلومة صغيرة (Pill / Badge)
class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool filled;

  const AppBadge({
    super.key,
    required this.text,
    this.color = AppColors.gold,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: filled
            ? null
            : Border.all(color: color.withValues(alpha: 0.32), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 11,
                color: filled ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// خط فاصل ذهبي رفيع مع نقطة في المنتصف (لمسة فنية)
class GoldDivider extends StatelessWidget {
  final double height;
  final double indent;
  const GoldDivider({super.key, this.height = 24, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(width: indent),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.0),
                    AppColors.gold.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.5),
                    AppColors.gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: indent),
        ],
      ),
    );
  }
}
