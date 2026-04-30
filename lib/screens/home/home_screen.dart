import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/prayer_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/islamic_pattern_bg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
    _updateCountdown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final app = context.read<AppProvider>();
    final next = app.nextPrayer;
    if (next == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final diff = next.time.difference(DateTime.now());
    setState(() => _remaining = diff);
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
              onRefresh: () async {
                try {
                  await app.refreshLocation();
                } catch (_) {}
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, app, isDark),
                    const SizedBox(height: 16),
                    if (app.locationDenied)
                      _buildLocationDeniedBanner(context, app),
                    const SizedBox(height: 8),
                    _buildHeroCard(context, app, next),
                    const SizedBox(height: 18),
                    _buildDateRow(context),
                    const SizedBox(height: 18),
                    if (today != null) _buildPrayersList(context, app, today),
                    const SizedBox(height: 18),
                    _buildShareButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider app, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/icons/app_icon.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('صلاتي',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.gold : AppColors.primary,
                        )),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14,
                        color: isDark ? AppColors.gold : AppColors.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${app.location?.city ?? '...'}'
                        '${app.location?.country.isNotEmpty == true ? ' · ${app.location!.country}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تحديث الموقع',
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () async {
              try {
                await app.refreshLocation();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث الموقع')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر تحديث الموقع: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDeniedBanner(BuildContext context, AppProvider app) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'الموقع غير مفعّل. الأوقات محسوبة لمكة المكرمة افتراضياً.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await app.refreshLocation();
              } catch (_) {}
            },
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AppProvider app, dynamic next) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.cardGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Opacity(
                opacity: 0.07,
                child: const IslamicPatternBackground(showGradient: false),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'الصلاة القادمة',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  next?.name ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    next != null ? Formatters.formatTime12(next.time) : '—',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'الوقت المتبقي',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.formatCountdown(_remaining),
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'حتى أذان ${next?.name ?? ''}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // shine
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.4),
                    AppColors.gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    final now = DateTime.now();
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 22),
                const SizedBox(height: 6),
                Text('التاريخ الميلادي',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatDateGregorianAr(now),
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                const Icon(Icons.brightness_2_rounded, size: 22),
                const SizedBox(height: 6),
                Text('التاريخ الهجري',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatHijriAr(now),
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayersList(BuildContext context, AppProvider app, dynamic today) {
    final list = today.toList();
    final current = app.currentPrayer;
    final next = app.nextPrayer;
    return GlassCard(
      padding: const EdgeInsets.all(8),
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
                indent: 12,
                endIndent: 12,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.share_rounded),
        label: const Text('مشاركة أوقات الصلاة'),
        onPressed: _sharePrayers,
      ),
    );
  }
}
