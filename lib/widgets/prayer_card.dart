import 'package:flutter/material.dart';
import '../models/prayer_time.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';

/// بطاقة صلاة فاخرة - تعرض اسم الصلاة، الأيقونة، والوقت بأسلوب فني راقٍ.
class PrayerCard extends StatelessWidget {
  final PrayerTime prayer;
  final bool isCurrent;
  final bool isNext;
  final bool compact;
  final VoidCallback? onTap;

  const PrayerCard({
    super.key,
    required this.prayer,
    this.isCurrent = false,
    this.isNext = false,
    this.compact = false,
    this.onTap,
  });

  Color _colorFor(String key) {
    switch (key) {
      case 'fajr':
        return AppColors.fajr;
      case 'sunrise':
        return AppColors.sunrise;
      case 'dhuhr':
        return AppColors.dhuhr;
      case 'asr':
        return AppColors.asr;
      case 'maghrib':
        return AppColors.maghrib;
      case 'isha':
        return AppColors.isha;
    }
    return AppColors.primary;
  }

  Color _accentFor(String key) {
    switch (key) {
      case 'fajr':
        return AppColors.fajrAccent;
      case 'sunrise':
        return AppColors.sunriseAccent;
      case 'dhuhr':
        return AppColors.dhuhrAccent;
      case 'asr':
        return AppColors.asrAccent;
      case 'maghrib':
        return AppColors.maghribAccent;
      case 'isha':
        return AppColors.ishaAccent;
    }
    return AppColors.primarySoft;
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'fajr':
        return Icons.nights_stay_rounded;
      case 'sunrise':
        return Icons.wb_twilight_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_cloudy_rounded;
      case 'maghrib':
        return Icons.brightness_4_rounded;
      case 'isha':
        return Icons.dark_mode_rounded;
    }
    return Icons.access_time_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(prayer.key);
    final accent = _accentFor(prayer.key);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlight = isNext;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: color.withValues(alpha: 0.06),
        highlightColor: color.withValues(alpha: 0.03),
        child: AnimatedContainer(
          duration: AppDurations.normal,
          curve: AppCurves.standard,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: compact ? 12 : 14,
          ),
          decoration: BoxDecoration(
            gradient: highlight
                ? LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      color.withValues(alpha: isDark ? 0.18 : 0.10),
                      color.withValues(alpha: isDark ? 0.06 : 0.02),
                    ],
                  )
                : null,
            color: highlight ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: highlight
                ? Border.all(
                    color: color.withValues(alpha: isDark ? 0.45 : 0.32),
                    width: 1.2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // أيقونة بتدرج لوني خاص
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.85),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: highlight
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.32),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(_iconFor(prayer.key), color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              // اسم الصلاة + الشارة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            prayer.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight:
                                      highlight ? FontWeight.w800 : FontWeight.w700,
                                  fontSize: 16,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isNext) _Badge(
                          text: 'القادمة',
                          color: AppColors.gold,
                          icon: Icons.notifications_active_rounded,
                        )
                        else if (isCurrent) _Badge(
                          text: 'الحالية',
                          color: AppColors.success,
                          icon: Icons.circle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // الوقت
              Text(
                Formatters.formatTime12(prayer.time),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: highlight
                          ? color
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _Badge({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.36), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == Icons.circle)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            )
          else ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
