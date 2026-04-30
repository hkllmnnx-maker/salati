import 'package:flutter/material.dart';
import '../../data/athkar_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';
import 'athkar_detail_screen.dart';

/// شاشة قائمة الأذكار - تصميم بطاقات فاخرة بتدرجات لونية مخصصة
class AthkarListScreen extends StatelessWidget {
  const AthkarListScreen({super.key});

  /// تخصيص لون لكل تصنيف من الأذكار
  Gradient _gradientFor(String id, bool isDark) {
    switch (id) {
      case 'morning':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE89B4A), Color(0xFFD9803F)],
        );
      case 'evening':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A6FA5), Color(0xFF2D3F66)],
        );
      case 'sleep':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3F66), Color(0xFF071A30)],
        );
      case 'after_prayer':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D7A6E), Color(0xFF1F4F47)],
        );
      case 'tasbeeh':
        return AppColors.goldGradient;
      default:
        return AppColors.heroCardGradient;
    }
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'morning':
        return Icons.wb_twilight_rounded;
      case 'evening':
        return Icons.nights_stay_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'after_prayer':
        return Icons.mosque_rounded;
      case 'tasbeeh':
        return Icons.fingerprint_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Column(
              children: [
                const AppPageHeader(
                  title: 'الأذكار',
                  subtitle: 'حصن المسلم - أذكار اليوم والليلة',
                  leadingIcon: Icons.menu_book_rounded,
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: AthkarData.all.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final c = AthkarData.all[i];
                      return _AthkarCategoryCard(
                        category: c,
                        gradient: _gradientFor(c.id, isDark),
                        icon: _iconFor(c.id),
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: AppDurations.slow,
                              pageBuilder: (_, anim, __) =>
                                  AthkarDetailScreen(category: c),
                              transitionsBuilder: (_, anim, __, child) {
                                return FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween(
                                      begin: const Offset(0, 0.04),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: anim,
                                      curve: AppCurves.emphasized,
                                    )),
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AthkarCategoryCard extends StatelessWidget {
  final AthkarCategory category;
  final Gradient gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _AthkarCategoryCard({
    required this.category,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDarkElevated.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.gold.withValues(alpha: 0.10)
              : AppColors.primary.withValues(alpha: 0.07),
        ),
        boxShadow: AppShadows.soft(isDark: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.gold.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // أيقونة بتدرج لوني فاخر
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // توهج داخلي
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(icon, color: Colors.white, size: 26),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                                height: 1.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11.5, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            AppBadge(
                              text: '${category.items.length} ذكرًا',
                              color: AppColors.gold,
                              icon: Icons.format_list_numbered_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


