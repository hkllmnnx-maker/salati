import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/quran_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';
import 'surah_screen.dart';

/// شاشة القرآن الكريم - بتصميم مستوحى من المخطوطات الإسلامية الفاخرة.
/// تتضمن بحثًا أنيقًا، فلاتر تصنيف، وقائمة سور بأرقام داخل نجوم ذهبية.
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  String _query = '';
  _SurahFilter _filter = _SurahFilter.all;
  late final AnimationController _entryCtrl;
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Surah> _filtered() {
    return QuranData.surahs.where((s) {
      // تصفية حسب التصنيف
      switch (_filter) {
        case _SurahFilter.makki:
          if (!s.revelation.contains('مكية')) return false;
          break;
        case _SurahFilter.madani:
          if (!s.revelation.contains('مدنية')) return false;
          break;
        case _SurahFilter.withContent:
          if (s.sampleAyat.isEmpty) return false;
          break;
        case _SurahFilter.all:
          break;
      }
      // البحث
      if (_query.isEmpty) return true;
      final q = _query.trim();
      return s.nameAr.contains(q) ||
          s.nameEnglish.toLowerCase().contains(q.toLowerCase()) ||
          s.number.toString() == q ||
          Formatters.toArabicDigits(s.number.toString()).contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          // توهج ذهبي علوي
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            height: 280,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: isDark ? 0.10 : 0.07),
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
                AppPageHeader(
                  title: 'القرآن الكريم',
                  subtitle: 'كتاب الله المُنَزَّل',
                  leadingIcon: Icons.menu_book_rounded,
                  centerTitle: false,
                ),
                _PremiumSearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _FilterChips(
                  current: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: AppSpacing.xs),
                // معلومات الإحصاء
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: SectionHeader(
                    title: 'السور',
                    subtitle:
                        '${Formatters.toArabicDigits(filtered.length.toString())} من ${Formatters.toArabicDigits(QuranData.surahs.length.toString())} سورة',
                    icon: Icons.format_list_numbered_rounded,
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const _NoResultsState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.lg,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final s = filtered[i];
                            return _SurahTile(
                              surah: s,
                              onTap: () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: AppDurations.slow,
                                  pageBuilder: (_, __, ___) =>
                                      SurahScreen(surah: s),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.04),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: AppCurves.emphasized,
                                        )),
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                              ),
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

enum _SurahFilter { all, makki, madani, withContent }

// ═══════════════════════════════════════════════════════════════════════
// شريط البحث الفاخر
// ═══════════════════════════════════════════════════════════════════════

class _PremiumSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _PremiumSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDark
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.primary.withValues(alpha: 0.08),
          ),
          boxShadow: AppShadows.soft(isDark: isDark),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن سورة (الاسم أو الرقم)...',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 38,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: onClear,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// رقائق الفلاتر
// ═══════════════════════════════════════════════════════════════════════

class _FilterChips extends StatelessWidget {
  final _SurahFilter current;
  final ValueChanged<_SurahFilter> onChanged;

  const _FilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = const [
      (_SurahFilter.all, 'الكل', Icons.apps_rounded),
      (_SurahFilter.makki, 'مكية', Icons.location_city_rounded),
      (_SurahFilter.madani, 'مدنية', Icons.mosque_rounded),
      (_SurahFilter.withContent, 'متاحة', Icons.menu_book_rounded),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          return _FilterChip(
            label: f.$2,
            icon: f.$3,
            selected: current == f.$1,
            onTap: () => onChanged(f.$1),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: AppDurations.normal,
          curve: AppCurves.emphasized,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.goldGradient : null,
            color: selected
                ? null
                : (isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.85)),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : (isDark
                      ? AppColors.gold.withValues(alpha: 0.14)
                      : AppColors.primary.withValues(alpha: 0.08)),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : (isDark ? AppColors.goldLight : AppColors.primary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// بطاقة سورة فاخرة
// ═══════════════════════════════════════════════════════════════════════

class _SurahTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasContent = surah.sampleAyat.isNotEmpty;
    final isMakki = surah.revelation.contains('مكية');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: AppColors.gold.withValues(alpha: 0.06),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark
                    ? AppColors.gold.withValues(alpha: 0.10)
                    : AppColors.primary.withValues(alpha: 0.06),
              ),
              boxShadow: AppShadows.soft(isDark: isDark),
            ),
            child: Row(
              children: [
                // النجمة الذهبية مع رقم السورة
                _SurahNumberBadge(number: surah.number),
                const SizedBox(width: AppSpacing.md),
                // اسم السورة والمعلومات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              surah.nameAr,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                fontFamily: 'Amiri',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            surah.nameEnglish,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // وسم نوع النزول
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (isMakki
                                      ? AppColors.warning
                                      : AppColors.info)
                                  .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xs),
                              border: Border.all(
                                color: (isMakki
                                        ? AppColors.warning
                                        : AppColors.info)
                                    .withValues(alpha: 0.32),
                                width: 0.6,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isMakki
                                      ? Icons.location_city_rounded
                                      : Icons.mosque_rounded,
                                  size: 10,
                                  color: isMakki
                                      ? AppColors.warning
                                      : AppColors.info,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  surah.revelation,
                                  style: TextStyle(
                                    color: isMakki
                                        ? AppColors.warning
                                        : AppColors.info,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.format_quote_rounded,
                            size: 11,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${Formatters.toArabicDigits(surah.ayahCount.toString())} آية',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // أيقونة الحالة
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hasContent
                        ? AppColors.gold.withValues(alpha: 0.12)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: hasContent
                          ? AppColors.gold.withValues(alpha: 0.28)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    hasContent
                        ? Icons.menu_book_rounded
                        : Icons.lock_outline_rounded,
                    color: hasContent
                        ? AppColors.gold
                        : (isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// شارة رقم السورة - نجمة ذهبية فاخرة
// ═══════════════════════════════════════════════════════════════════════

class _SurahNumberBadge extends StatelessWidget {
  final int number;
  const _SurahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // نجمة ذهبية في الخلفية
          CustomPaint(
            size: const Size(52, 52),
            painter: _StarPainter(),
          ),
          // الرقم
          Text(
            Formatters.toArabicDigits(number.toString()),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.46;
    final innerRadius = outerRadius * 0.62;

    // ظل ذهبي
    final glow = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final glowPath = _starPath(center, outerRadius * 1.05, innerRadius * 1.05);
    canvas.drawPath(glowPath, glow);

    // النجمة الرئيسية بتدرج
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.goldSoft,
        AppColors.gold,
        AppColors.goldDark,
      ],
    ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = shader;
    final path = _starPath(center, outerRadius, innerRadius);
    canvas.drawPath(path, fill);

    // حدود ذهبية أغمق
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.goldDark.withValues(alpha: 0.55);
    canvas.drawPath(path, stroke);

    // نجمة داخلية رفيعة
    final innerStar = _starPath(center, innerRadius * 0.85, innerRadius * 0.45);
    final innerStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppColors.primaryDark.withValues(alpha: 0.18);
    canvas.drawPath(innerStar, innerStroke);
  }

  Path _starPath(Offset center, double outerR, double innerR) {
    const points = 8;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = -math.pi / 2 + i * math.pi / points;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════
// حالة عدم وجود نتائج
// ═══════════════════════════════════════════════════════════════════════

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'لا توجد نتائج',
      subtitle: 'جرب البحث بكلمة أخرى أو اختر تصنيفًا مختلفًا',
    );
  }
}
