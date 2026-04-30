import 'package:flutter/material.dart';
import '../models/prayer_time.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class PrayerCard extends StatelessWidget {
  final PrayerTime prayer;
  final bool isCurrent;
  final bool isNext;

  const PrayerCard({
    super.key,
    required this.prayer,
    this.isCurrent = false,
    this.isNext = false,
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

  IconData _iconFor(String key) {
    switch (key) {
      case 'fajr':
        return Icons.nights_stay_rounded;
      case 'sunrise':
        return Icons.wb_twighlight;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_cloudy_rounded;
      case 'maghrib':
        return Icons.brightness_4_rounded;
      case 'isha':
        return Icons.dark_mode_rounded;
    }
    return Icons.access_time;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(prayer.key);
    final highlight = isNext;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(prayer.key), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Text(
                  prayer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 8),
                if (isNext)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'القادمة',
                      style: TextStyle(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  )
                else if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'الحالية',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            Formatters.formatTime12(prayer.time),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}
