import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/prayer_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selected = DateTime.now();
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(initialScrollOffset: 14 * 70.0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);

    final prayers = app.location != null ? app.prayersForDate(_selected) : null;
    final isToday = _selected.year == today.year &&
        _selected.month == today.month &&
        _selected.day == today.day;

    return Scaffold(
      appBar: AppBar(title: const Text('التقويم'), actions: [
        IconButton(
          icon: const Icon(Icons.today_rounded),
          tooltip: 'اليوم',
          onPressed: () => setState(() => _selected = today),
        ),
      ]),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: Column(
              children: [
                // شريط الأيام
                SizedBox(
                  height: 96,
                  child: ListView.builder(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: 30,
                    itemBuilder: (context, i) {
                      final d = base.add(Duration(days: i - 14));
                      final selected = d.year == _selected.year &&
                          d.month == _selected.month &&
                          d.day == _selected.day;
                      final isThisToday = d.year == today.year &&
                          d.month == today.month &&
                          d.day == today.day;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: selected ? AppColors.cardGradient : null,
                            color: selected ? null : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? AppColors.gold
                                  : isThisToday
                                      ? AppColors.gold.withValues(alpha: 0.5)
                                      : AppColors.primary.withValues(alpha: 0.06),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Formatters.arabicWeekdaysAr[(d.weekday - 1) % 7].substring(0, 3),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Formatters.toArabicDigits(d.day.toString()),
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.goldLight
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (isThisToday)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // عرض التواريخ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppColors.gold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatters.formatDateGregorianAr(_selected),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                Formatters.formatHijriAr(_selected),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.gold),
                              ),
                            ],
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('اليوم',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: prayers == null
                      ? const Center(child: Text('لا تتوفر بيانات الموقع'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: prayers.toList().length,
                          separatorBuilder: (_, __) => Divider(
                            color: Theme.of(context).dividerColor,
                            height: 1,
                          ),
                          itemBuilder: (_, i) {
                            return PrayerCard(prayer: prayers.toList()[i]);
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
