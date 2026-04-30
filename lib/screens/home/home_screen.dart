import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/prayer_time.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/prayer_card.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCountdown());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _updateCountdown() {
    if (!mounted) return;
    final app = context.read<AppProvider>();
    final next = app.nextPrayer;
    if (next == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final diff = next.time.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  Future<void> _sharePrayers() async {
    final app = context.read<AppProvider>();
    final p = app.todayPrayers;
    if (p == null) return;
    final loc = app.location;
    final buf = StringBuffer();
    buf.writeln('🕌 أوقات الصلاة - ${loc?.city ?? ''}');
    buf.writeln(Formatters.formatDateGregorianAr(DateTime.now()));
    buf.writeln(Formatters.formatHijriAr(DateTime.now()));
    buf.writeln('');
    for (final pr in p.toList()) {
      buf.writeln('${pr.name}: ${Formatters.formatTime12(pr.time)}');
    }
    buf.writeln('\n— من تطبيق صلاتي');
    await Share.share(buf.toString(), subject: 'أوقات الصلاة - صلاتي');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final next = app.nextPrayer;
    final today = app.todayPrayers;

    return Scaffold(
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.gold,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              onRefresh: () async {
                try {
                  await app.refreshLocation();
                } catch (_) {}
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, app, isDark),
                    const SizedBox(height: AppSpacing.md),
                    if (app.locationDenied)
                      _buildLocationDeniedBanner(context, app),
                    if (app.locationDenied)
                      const SizedBox(height: AppSpacing.sm),
                    _buildHeroCard(context, app, next),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDateRow(context),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeader(
                      title: 'مواقيت اليوم',
                      subtitle: 'الصلوات الخمس وموعد الشروق',
                      icon: Icons.access_time_filled_rounded,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (today != null) _buildPrayersList(context, app, today),
                    const SizedBox(height: AppSpacing.lg),
                    _buildShareButton(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDuaCard(context, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppProvider app, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          // أيقونة التطبيق بإطار ذهبي ناعم
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: Container(
                color: isDark ? AppColors.backgroundDark : Colors.white,
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.mosque_rounded,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صلاتي',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: isDark ? AppColors.gold : AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${app.location?.city ?? '...'}'
                        '${app.location?.country.isNotEmpty == true ? ' · ${app.location!.country}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CircleIconAction(
            icon: Icons.my_location_rounded,
            tooltip: 'تحديث الموقع',
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await app.refreshLocation();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('تم تحديث الموقع')),
                );
              } catch (_) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('تعذر تحديث الموقع')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Location Banner
  // ─────────────────────────────────────────────
  Widget _buildLocationDeniedBanner(BuildContext context, AppProvider app) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.32)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'الموقع غير مفعّل. الأوقات محسوبة لمكة المكرمة افتراضياً.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              try {
                await app.refreshLocation();
              } catch (_) {}
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: AppColors.warning.withValues(alpha: 0.12),
            ),
            child: const Text('تفعيل', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Hero Card - Next Prayer Premium Display
  // ─────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context, AppProvider app, PrayerTime? next) {
    return HeroGradientCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // التسمية العلوية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.32),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldLight.withValues(
                        alpha: 0.6 + 0.4 * _pulseCtrl.value,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldLight.withValues(
                            alpha: 0.6 * _pulseCtrl.value,
                          ),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'الصلاة القادمة',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 11.5,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // اسم الصلاة - بخط Amiri الفاخر
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFEEE6CB)],
            ).createShader(rect),
            child: Text(
              next?.name ?? '—',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                fontFamily: 'Amiri',
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // الوقت - شارة فاخرة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: AppColors.goldLight,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  next != null ? Formatters.formatTime12(next.time) : '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // فاصل ذهبي رفيع
          SizedBox(
            width: 80,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0),
                    AppColors.goldLight.withValues(alpha: 0.6),
                    AppColors.gold.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // الوقت المتبقي
          Text(
            'الوقت المتبقي',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [
                AppColors.goldSoft,
                AppColors.gold,
                AppColors.goldLight,
              ],
            ).createShader(rect),
            child: Text(
              Formatters.formatCountdown(_remaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: 1.5,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next != null ? 'حتى أذان ${next.name}' : 'لا توجد صلاة قادمة',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Date Row - Hijri & Gregorian
  // ─────────────────────────────────────────────
  Widget _buildDateRow(BuildContext context) {
    final now = DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _DateChip(
            icon: Icons.calendar_month_rounded,
            label: 'التاريخ الميلادي',
            value: Formatters.formatDateGregorianAr(now),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DateChip(
            icon: Icons.brightness_2_rounded,
            label: 'التاريخ الهجري',
            value: Formatters.formatHijriAr(now),
            accent: true,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Prayers List
  // ─────────────────────────────────────────────
  Widget _buildPrayersList(BuildContext context, AppProvider app, dynamic today) {
    final list = today.toList() as List<PrayerTime>;
    final current = app.currentPrayer;
    final next = app.nextPrayer;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xs + 2),
      goldBorder: false,
      child: Column(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            PrayerCard(
              prayer: list[i],
              isCurrent: current?.key == list[i].key,
              isNext: next?.key == list[i].key,
            ),
            if (i != list.length - 1)
              Divider(
                color: Theme.of(context).dividerColor,
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Share Button
  // ─────────────────────────────────────────────
  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.share_rounded, size: 18),
        label: const Text('مشاركة أوقات الصلاة'),
        onPressed: _sharePrayers,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Inspirational Dua Card
  // ─────────────────────────────────────────────
  Widget _buildDuaCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.gold.withValues(alpha: 0.06),
                  AppColors.gold.withValues(alpha: 0.02),
                ]
              : [
                  AppColors.gold.withValues(alpha: 0.10),
                  AppColors.goldSoft.withValues(alpha: 0.12),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const IslamicArchOrnament(size: 48),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ\nوَحُسْنِ عِبَادَتِكَ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.9,
              color: isDark ? AppColors.goldLight : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'حديث شريف',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// شريحة تاريخ صغيرة فاخرة
class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  const _DateChip({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm + 2,
        AppSpacing.sm,
        AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDarkElevated.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: accent
              ? AppColors.gold.withValues(alpha: 0.32)
              : (isDark
                  ? AppColors.gold.withValues(alpha: 0.10)
                  : AppColors.primary.withValues(alpha: 0.07)),
          width: accent ? 1.2 : 1,
        ),
        boxShadow: AppShadows.soft(isDark: isDark),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent
                  ? AppColors.gold.withValues(alpha: 0.16)
                  : AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              icon,
              size: 16,
              color: accent
                  ? AppColors.gold
                  : (isDark ? AppColors.goldLight : AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent
                  ? AppColors.gold
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
