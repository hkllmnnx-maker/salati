import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/quran_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';

/// شاشة تفاصيل السورة - بتصميم مستوحى من المخطوطات الإسلامية القديمة.
/// تتضمن ترويسة فاخرة، البسملة بخط أنيق، آيات في إطارات مذهّبة.
class SurahScreen extends StatelessWidget {
  final Surah surah;
  const SurahScreen({super.key, required this.surah});

  bool get _startsWithBasmala =>
      surah.sampleAyat.isNotEmpty &&
      surah.sampleAyat.first.contains('بِسْمِ اللَّهِ');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasContent = surah.sampleAyat.isNotEmpty;

    // الفاتحة كل آياتها هي السورة (تشمل البسملة كآية أولى)
    // باقي السور: نعرض البسملة كترويسة (إن لم تكن التوبة)
    final showBasmalaHeader = !_startsWithBasmala && surah.number != 9;
    final ayahs = hasContent && _startsWithBasmala && surah.number != 1
        ? surah.sampleAyat.skip(1).toList()
        : surah.sampleAyat;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          // توهج ذهبي علوي
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            height: 320,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: isDark ? 0.14 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppPageHeader(
                    title: 'سورة ${surah.nameAr}',
                    subtitle: surah.nameEnglish,
                    showBackButton: true,
                    centerTitle: true,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.huge,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // البطاقة الفاخرة - عنوان السورة
                      _SurahHeroCard(surah: surah),
                      const SizedBox(height: AppSpacing.lg),
                      if (hasContent && showBasmalaHeader) ...[
                        const _BasmalaBanner(),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (hasContent) ...[
                        SectionHeader(
                          title: surah.number == 1
                              ? 'الآيات الكريمة'
                              : 'الآيات (مختارات)',
                          subtitle:
                              '${Formatters.toArabicDigits(ayahs.length.toString())} آية',
                          icon: Icons.auto_stories_rounded,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        for (int i = 0; i < ayahs.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _AyahCard(
                              ayah: ayahs[i],
                              number: surah.number == 1 ? i + 1 : i + 1,
                              isFirst: i == 0,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        const _EndOfSelectionFooter(),
                      ] else ...[
                        const _ComingSoonCard(),
                      ],
                    ]),
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
// بطاقة السورة البطلة
// ═══════════════════════════════════════════════════════════════════════

class _SurahHeroCard extends StatelessWidget {
  final Surah surah;
  const _SurahHeroCard({required this.surah});

  @override
  Widget build(BuildContext context) {
    final isMakki = surah.revelation.contains('مكية');
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.36),
          width: 1.2,
        ),
        boxShadow: AppShadows.strong(isDark: true),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // زخرفة هندسية في الزوايا
          Positioned(
            top: -8,
            right: -8,
            child: _CornerOrnament(),
          ),
          Positioned(
            bottom: -8,
            left: -8,
            child: Transform.rotate(
              angle: math.pi,
              child: _CornerOrnament(),
            ),
          ),
          Column(
            children: [
              // رقم السورة في إطار ذهبي
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryDark,
                      border: Border.all(
                        color: AppColors.goldLight.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        Formatters.toArabicDigits(surah.number.toString()),
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // اسم السورة بخط فاخر
              ShaderMask(
                shaderCallback: (rect) =>
                    AppColors.goldGradient.createShader(rect),
                child: Text(
                  'سورة ${surah.nameAr}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    fontFamily: 'Amiri',
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                surah.nameEnglish,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // إحصائيات السورة
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.24),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Stat(
                      icon: isMakki
                          ? Icons.location_city_rounded
                          : Icons.mosque_rounded,
                      label: surah.revelation,
                      color: isMakki
                          ? AppColors.warningLight
                          : AppColors.infoLight,
                    ),
                    _Divider(),
                    _Stat(
                      icon: Icons.format_quote_rounded,
                      label:
                          '${Formatters.toArabicDigits(surah.ayahCount.toString())} آية',
                      color: AppColors.goldLight,
                    ),
                    _Divider(),
                    _Stat(
                      icon: Icons.numbers_rounded,
                      label:
                          'الترتيب ${Formatters.toArabicDigits(surah.number.toString())}',
                      color: Colors.white,
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

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Stat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.gold.withValues(alpha: 0.32),
    );
  }
}

class _CornerOrnament extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(painter: _CornerOrnamentPainter()),
    );
  }
}

class _CornerOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // ربع دائرة مزخرفة
    final rect =
        Rect.fromCircle(center: Offset(size.width, 0), radius: size.width);
    canvas.drawArc(rect, math.pi * 0.5, math.pi * 0.5, false, paint);

    final inner = Rect.fromCircle(
      center: Offset(size.width, 0),
      radius: size.width * 0.7,
    );
    canvas.drawArc(inner, math.pi * 0.5, math.pi * 0.5, false, paint);

    // نقاط ذهبية
    final dot = Paint()..color = AppColors.gold.withValues(alpha: 0.5);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      1.2,
      dot,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════
// بانر البسملة
// ═══════════════════════════════════════════════════════════════════════

class _BasmalaBanner extends StatelessWidget {
  const _BasmalaBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.55)
            : AppColors.surfaceLightElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: AppShadows.soft(isDark: isDark),
      ),
      child: Column(
        children: [
          // خط ذهبي علوي
          Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ShaderMask(
            shaderCallback: (rect) =>
                AppColors.goldGradient.createShader(rect),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFamily: 'Amiri',
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// بطاقة الآية
// ═══════════════════════════════════════════════════════════════════════

class _AyahCard extends StatelessWidget {
  final String ayah;
  final int number;
  final bool isFirst;

  const _AyahCard({
    required this.ayah,
    required this.number,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.surfaceDark.withValues(alpha: 0.78),
                  AppColors.surfaceDarkElevated.withValues(alpha: 0.55),
                ],
              )
            : LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  AppColors.backgroundLightAlt.withValues(alpha: 0.5),
                ],
              ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.14),
        ),
        boxShadow: AppShadows.soft(isDark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah,
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 23,
                height: 2.1,
                fontWeight: FontWeight.w600,
                fontFamily: 'Amiri',
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              // وردة ذهبية مع رقم الآية
              _AyahNumberRose(number: number),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppColors.gold.withValues(alpha: 0.36),
                        AppColors.gold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AyahNumberRose extends StatelessWidget {
  final int number;
  const _AyahNumberRose({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(32, 32), painter: _RosePainter()),
          Text(
            Formatters.toArabicDigits(number.toString()),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _RosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.45;

    // وردة ذهبية بـ 8 بتلات
    final shader = const LinearGradient(
      colors: [AppColors.goldSoft, AppColors.gold, AppColors.goldDark],
    ).createShader(Rect.fromCircle(center: center, radius: r));

    final fill = Paint()..shader = shader;
    final path = Path();
    const petals = 8;
    for (int i = 0; i < petals * 2; i++) {
      final radius = i.isEven ? r : r * 0.55;
      final angle = -math.pi / 2 + i * math.pi / petals;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fill);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = AppColors.goldDark.withValues(alpha: 0.6);
    canvas.drawPath(path, stroke);

    // دائرة داخلية
    final innerStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4
      ..color = AppColors.primaryDark.withValues(alpha: 0.2);
    canvas.drawCircle(center, r * 0.42, innerStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════
// تذييل نهاية المختارات
// ═══════════════════════════════════════════════════════════════════════

class _EndOfSelectionFooter extends StatelessWidget {
  const _EndOfSelectionFooter();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0),
                        AppColors.gold.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 8,
                  height: 8,
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
                        AppColors.gold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'صدق الله العظيم',
            style: TextStyle(
              color: isDark ? AppColors.goldLight : AppColors.goldDark,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'Amiri',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// بطاقة "قريبًا"
// ═══════════════════════════════════════════════════════════════════════

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.24),
        ),
        boxShadow: AppShadows.medium(isDark: isDark),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.18),
                  AppColors.gold.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 44,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'قريبًا',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'محتوى هذه السورة سيتم توفيره في تحديثات قادمة عبر مصدر معتمد للقرآن الكريم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.7,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.32),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 6),
                Text(
                  'متاح حاليًا: الفاتحة وقصار المفصّل',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
