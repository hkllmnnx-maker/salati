import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/prayer_card.dart';
import '../../widgets/section_header.dart';

/// شاشة التقويم - بتصميم فاخر مستوحى من المخطوطات الإسلامية القديمة
/// مع شريط أيام أنيق، بطاقة تاريخ بطلة، وقائمة صلوات راقية.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime _selected = DateTime.now();
  late final ScrollController _scroll;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  static const int _daysWindow = 60; // 30 يوم قبل و30 بعد
  static const int _todayIndex = 30;
  static const double _dayItemWidth = 68.0;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(
      initialScrollOffset: (_todayIndex - 2) * _dayItemWidth,
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: AppCurves.standard);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _selectDay(DateTime d) {
    setState(() => _selected = d);
    _fadeCtrl
      ..reset()
      ..forward();
  }

  void _jumpToToday() {
    final today = DateTime.now();
    _selectDay(DateTime(today.year, today.month, today.day));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        (_todayIndex - 2) * _dayItemWidth,
        duration: AppDurations.slow,
        curve: AppCurves.emphasized,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);

    final prayers = app.location != null ? app.prayersForDate(_selected) : null;
    final isToday = _selected.year == today.year &&
        _selected.month == today.month &&
        _selected.day == today.day;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          // توهج ذهبي علوي
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            height: 320,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: isDark ? 0.10 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // الترويسة الفاخرة
                AppPageHeader(
                  title: 'التقويم',
                  subtitle: 'مواقيت صلواتك على مدار الشهر',
                  leadingIcon: Icons.calendar_month_rounded,
                  centerTitle: false,
                  actions: [
                    CircleIconAction(
                      icon: Icons.today_rounded,
                      tooltip: 'اليوم',
                      onTap: _jumpToToday,
                    ),
                  ],
                ),
                // شريط الأيام الأفقي
                _DayStrip(
                  controller: _scroll,
                  base: base,
                  selected: _selected,
                  today: today,
                  daysWindow: _daysWindow,
                  todayIndex: _todayIndex,
                  itemWidth: _dayItemWidth,
                  onSelect: _selectDay,
                ),
                const SizedBox(height: AppSpacing.sm),
                // بطاقة التاريخ المختار - hero
                FadeTransition(
                  opacity: _fade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: _DateHeroCard(
                      date: _selected,
                      isToday: isToday,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // عنوان الصلوات
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: SectionHeader(
                    title: 'مواقيت الصلوات',
                    subtitle: isToday
                        ? 'صلوات اليوم'
                        : 'صلوات يوم ${Formatters.toArabicDigits(_selected.day.toString())}',
                    icon: Icons.access_time_rounded,
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: prayers == null
                        ? const _NoLocationState()
                        : _PrayersList(
                            prayers: prayers.toList(),
                            isToday: isToday,
                          ),
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

// ═══════════════════════════════════════════════════════════════════════
// شريط الأيام الأفقي
// ═══════════════════════════════════════════════════════════════════════

class _DayStrip extends StatelessWidget {
  final ScrollController controller;
  final DateTime base;
  final DateTime selected;
  final DateTime today;
  final int daysWindow;
  final int todayIndex;
  final double itemWidth;
  final ValueChanged<DateTime> onSelect;

  const _DayStrip({
    required this.controller,
    required this.base,
    required this.selected,
    required this.today,
    required this.daysWindow,
    required this.todayIndex,
    required this.itemWidth,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        itemCount: daysWindow,
        itemBuilder: (context, i) {
          final d = base.add(Duration(days: i - todayIndex));
          final isSelected = d.year == selected.year &&
              d.month == selected.month &&
              d.day == selected.day;
          final isThisToday = d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
          final isFriday = d.weekday == DateTime.friday;
          return _DayChip(
            date: d,
            isSelected: isSelected,
            isToday: isThisToday,
            isFriday: isFriday,
            onTap: () => onSelect(d),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isFriday;
  final VoidCallback onTap;

  const _DayChip({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isFriday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekdayShort =
        Formatters.arabicWeekdaysAr[(date.weekday - 1) % 7].substring(0, 3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: AppCurves.emphasized,
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.heroCardGradient : null,
          color: isSelected
              ? null
              : (isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : isToday
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : (isDark
                        ? AppColors.gold.withValues(alpha: 0.10)
                        : AppColors.primary.withValues(alpha: 0.08)),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.18),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
              : AppShadows.soft(isDark: isDark),
        ),
        child: Stack(
          children: [
            // وسم يوم الجمعة
            if (isFriday)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayShort,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.toArabicDigits(date.day.toString()),
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.goldLight
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // مؤشر اليوم الحالي
                  AnimatedContainer(
                    duration: AppDurations.normal,
                    width: isToday ? 16 : 0,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.goldLight
                          : AppColors.gold,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.gold.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// بطاقة التاريخ البطلة
// ═══════════════════════════════════════════════════════════════════════

class _DateHeroCard extends StatelessWidget {
  final DateTime date;
  final bool isToday;

  const _DateHeroCard({required this.date, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.heroCardGradient
            : LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  AppColors.backgroundLightAlt.withValues(alpha: 0.7),
                ],
              ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.32 : 0.22),
          width: 1,
        ),
        boxShadow: isDark
            ? AppShadows.strong(isDark: true)
            : AppShadows.medium(isDark: false),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // زخرفة ذهبية في الزاوية
          Positioned(
            top: -8,
            left: -8,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              // أيقونة فاخرة
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatDateGregorianAr(date),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.brightness_5_rounded,
                          size: 13,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            Formatters.formatHijriAr(date),
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success
                                  .withValues(alpha: 0.6),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'اليوم',
                        style: TextStyle(
                          color: AppColors.successLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// قائمة الصلوات
// ═══════════════════════════════════════════════════════════════════════

class _PrayersList extends StatelessWidget {
  final List prayers;
  final bool isToday;

  const _PrayersList({required this.prayers, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // تحديد الصلاة القادمة في حال اليوم الحالي
    int? nextIndex;
    if (isToday) {
      for (int i = 0; i < prayers.length; i++) {
        if (prayers[i].time.isAfter(now)) {
          nextIndex = i;
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? AppColors.gold.withValues(alpha: 0.12)
              : AppColors.primary.withValues(alpha: 0.06),
        ),
        boxShadow: AppShadows.soft(isDark: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          itemCount: prayers.length,
          separatorBuilder: (_, __) => Divider(
            color: isDark
                ? AppColors.gold.withValues(alpha: 0.06)
                : AppColors.primary.withValues(alpha: 0.05),
            height: 1,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
          itemBuilder: (_, i) {
            final isNext = nextIndex == i;
            return PrayerCard(
              prayer: prayers[i],
              isNext: isNext,
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// حالة عدم توفر الموقع
// ═══════════════════════════════════════════════════════════════════════

class _NoLocationState extends StatelessWidget {
  const _NoLocationState();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.location_off_rounded,
      title: 'لا تتوفر بيانات الموقع',
      subtitle: 'يرجى تفعيل الموقع من الإعدادات لعرض مواقيت الصلوات',
    );
  }
}
