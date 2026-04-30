import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';

/// شاشة "عن التطبيق" بأسلوب فني فاخر:
/// - بطل ذهبي مع شعار التطبيق وتوهج
/// - بطاقة ميزات راقية بأيقونات ذهبية ملونة
/// - بطاقة "صنع بـ ♥" أنيقة
/// - دعاء ختامي بخط الأمري
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: IslamicPatternBackground()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── شريط علوي ───
                SliverToBoxAdapter(
                  child: AppPageHeader(
                    title: 'عن التطبيق',
                    subtitle: 'صلاتي · رفيقك في العبادة',
                    showBackButton: true,
                  ),
                ),

                // ─── البطل الذهبي ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: _AppHero(glowCtrl: _glowCtrl),
                  ),
                ),

                // ─── الوصف ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      goldBorder: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: AppColors.gold.withValues(alpha: 0.5),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تطبيق إسلامي عربي احترافي يجمع أوقات الصلاة، '
                            'الأذكار، القبلة، التقويم الهجري، والقرآن الكريم '
                            'في تجربة واحدة بتصميم عصري راقٍ.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  height: 1.85,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── قائمة الميزات ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: const SectionHeader(
                      title: 'الميزات',
                      subtitle: 'كل ما تحتاجه في تطبيق واحد',
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: const [
                          _FeatureRow(
                            icon: Icons.access_time_rounded,
                            title: 'أوقات الصلاة',
                            subtitle: 'حسابات دقيقة بطرق متعددة',
                            color: AppColors.fajr,
                          ),
                          _FeatureDivider(),
                          _FeatureRow(
                            icon: Icons.menu_book_rounded,
                            title: 'الأذكار',
                            subtitle: 'الصباح، المساء، النوم، الاستيقاظ',
                            color: AppColors.sage,
                          ),
                          _FeatureDivider(),
                          _FeatureRow(
                            icon: Icons.fingerprint_rounded,
                            title: 'السبحة الإلكترونية',
                            subtitle: 'عد التسبيح بأناقة',
                            color: AppColors.dhuhr,
                          ),
                          _FeatureDivider(),
                          _FeatureRow(
                            icon: Icons.menu_book_outlined,
                            title: 'القرآن الكريم',
                            subtitle: '114 سورة بترتيب المصحف',
                            color: AppColors.gold,
                          ),
                          _FeatureDivider(),
                          _FeatureRow(
                            icon: Icons.explore_rounded,
                            title: 'بوصلة القبلة',
                            subtitle: 'تحديد اتجاه الكعبة المشرّفة',
                            color: AppColors.maghrib,
                          ),
                          _FeatureDivider(),
                          _FeatureRow(
                            icon: Icons.calendar_month_rounded,
                            title: 'التقويم الهجري',
                            subtitle: 'تقويم هجري وميلادي مزدوج',
                            color: AppColors.info,
                          ),
                          _FeatureDivider(),
                          _FeatureRow(
                            icon: Icons.notifications_active_rounded,
                            title: 'إشعارات الصلاة',
                            subtitle: 'تنبيهات قبل كل صلاة',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── معلومات تقنية ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: const SectionHeader(
                      title: 'معلومات تقنية',
                      subtitle: 'تفاصيل التطبيق والمنصة',
                      icon: Icons.code_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: const [
                          _InfoRow(
                            label: 'الإصدار',
                            value: '1.0.0',
                            icon: Icons.tag_rounded,
                          ),
                          SizedBox(height: 14),
                          _InfoRow(
                            label: 'المنصة',
                            value: 'Flutter',
                            icon: Icons.flutter_dash_rounded,
                          ),
                          SizedBox(height: 14),
                          _InfoRow(
                            label: 'اللغة',
                            value: 'العربية',
                            icon: Icons.language_rounded,
                          ),
                          SizedBox(height: 14),
                          _InfoRow(
                            label: 'الاتجاه',
                            value: 'من اليمين لليسار',
                            icon: Icons.format_textdirection_r_to_l_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── دعاء ختامي ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: _ClosingDua(),
                  ),
                ),

                // ─── شارة "صنع بـ ♥" ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xxxl,
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.32),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'صُنع بـ ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.goldLight
                                    : AppColors.goldDark,
                              ),
                            ),
                            const Icon(
                              Icons.favorite_rounded,
                              size: 13,
                              color: AppColors.maghrib,
                            ),
                            Text(
                              ' لخدمة المسلمين',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.goldLight
                                    : AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ═══════════════════════════════════════════════════════
// عناصر مساعدة
// ═══════════════════════════════════════════════════════

class _AppHero extends StatelessWidget {
  final AnimationController glowCtrl;
  const _AppHero({required this.glowCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowCtrl,
      builder: (_, __) {
        final t = glowCtrl.value;
        return Center(
          child: Column(
            children: [
              // الشعار مع توهج متموج
              Stack(
                alignment: Alignment.center,
                children: [
                  // توهج خارجي
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gold
                              .withValues(alpha: 0.18 + 0.10 * t),
                          AppColors.gold.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // حلقة ذهبية رفيعة دوّارة
                  Transform.rotate(
                    angle: t * 6.28,
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.0),
                            AppColors.gold.withValues(alpha: 0.5),
                            AppColors.gold.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // الشعار
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      gradient: AppColors.heroCardGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.32),
                          blurRadius: 28 + 10 * t,
                          offset: const Offset(0, 12),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color:
                              AppColors.primaryDark.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        width: 1.4,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      child: Stack(
                        children: [
                          // محاولة عرض أيقونة التطبيق إن وُجدت
                          Positioned.fill(
                            child: Image.asset(
                              'assets/icons/app_icon.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _FallbackLogo(),
                            ),
                          ),
                          // طبقة لمعان زجاجية
                          Positioned(
                            top: -10,
                            left: -10,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white
                                        .withValues(alpha: 0.18),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // اسم التطبيق
              ShaderMask(
                shaderCallback: (rect) =>
                    AppColors.goldGradient.createShader(rect),
                child: Text(
                  'صلاتي',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 6),
              // شارة الإصدار
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.32),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.gold,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'الإصدار ١٫٠٫٠',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.goldGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.mosque_rounded,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: color.withValues(alpha: 0.28),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: color.withValues(alpha: 0.7),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 1,
        color: (isDark ? AppColors.gold : AppColors.primary)
            .withValues(alpha: 0.06),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.goldLight : AppColors.goldDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClosingDua extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.surfaceDarkElevated.withValues(alpha: 0.95),
                  AppColors.surfaceDark.withValues(alpha: 0.85),
                ]
              : [
                  AppColors.gold.withValues(alpha: 0.10),
                  AppColors.gold.withValues(alpha: 0.04),
                ],
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: AppShadows.soft(isDark: isDark),
      ),
      child: Column(
        children: [
          // زخرفة علوية
          IslamicArchOrnament(
            color: AppColors.gold.withValues(alpha: 0.7),
            size: 44,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'دعاء',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'اللهم تقبّل منّا، إنّك أنت السميع العليم.\n'
            'وتُب علينا، إنّك أنت التوّاب الرحيم.\n'
            'واجعل هذا العمل خالصًا لوجهك الكريم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17,
              height: 2.0,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // زخرفة سفلية معكوسة
          Transform.rotate(
            angle: 3.14,
            child: IslamicArchOrnament(
              color: AppColors.gold.withValues(alpha: 0.7),
              size: 44,
            ),
          ),
        ],
      ),
    );
  }
}
