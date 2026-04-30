import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_info.dart';
import '../../providers/app_provider.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/islamic_pattern_bg.dart';
import '../../widgets/section_header.dart';
import 'about_screen.dart';

/// شاشة الإعدادات بأسلوب فني فاخر:
/// - رأس أنيق مع أيقونة ذهبية
/// - أقسام منظمة ببطاقات زجاجية وعناوين ذهبية
/// - عناصر تفاعلية بلمسات ذهبية ناعمة
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ───────────────────────────────────────────────
  // Pickers
  // ───────────────────────────────────────────────
  Future<void> _pickCity(BuildContext context) async {
    final app = context.read<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cities = Cities.list;
    final selected = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? AppColors.surfaceDarkElevated
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(builder: (ctx, setSt) {
          final filtered = cities.where((c) {
            if (query.isEmpty) return true;
            return c.name.contains(query) || c.country.contains(query);
          }).toList();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder: (_, controller) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    // مقبض السحب
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.3),
                            AppColors.gold,
                            AppColors.gold.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.location_city_rounded,
                            color: AppColors.gold, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'اختر مدينتك',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      onChanged: (v) => setSt(() => query = v),
                      decoration: InputDecoration(
                        hintText: 'بحث عن مدينة أو دولة...',
                        prefixIcon: Icon(Icons.search_rounded,
                            color: AppColors.gold),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLightAlt,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          borderSide:
                              const BorderSide(color: AppColors.gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: EmptyState(
                                icon: Icons.search_off_rounded,
                                title: 'لا توجد نتائج',
                                subtitle: 'جرّب كلمة بحث أخرى',
                              ),
                            )
                          : ListView.separated(
                              controller: controller,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: AppColors.gold
                                    .withValues(alpha: 0.06),
                              ),
                              itemBuilder: (_, i) {
                                final c = filtered[i];
                                final isCurrent =
                                    c.name == app.location?.city;
                                return ListTile(
                                  leading: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      gradient: isCurrent
                                          ? AppColors.goldGradient
                                          : null,
                                      color: isCurrent
                                          ? null
                                          : AppColors.gold
                                              .withValues(alpha: 0.10),
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppRadius.sm),
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: isCurrent
                                          ? Colors.white
                                          : AppColors.gold,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(c.country),
                                  trailing: isCurrent
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.gold,
                                        )
                                      : null,
                                  onTap: () => Navigator.pop(ctx, c),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
    if (selected != null) {
      await app.setManualLocation(LocationInfo(
        latitude: selected.latitude,
        longitude: selected.longitude,
        country: selected.country,
        city: selected.name,
        isManual: true,
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('تم اختيار: ${selected.name}')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    }
  }

  // ───────────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
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
                // ─── العنوان الرئيسي ───
                SliverToBoxAdapter(
                  child: AppPageHeader(
                    title: 'الإعدادات',
                    subtitle: 'خصّص تجربتك بإتقان',
                    leadingIcon: Icons.tune_rounded,
                  ),
                ),

                // ─── قسم الموقع ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: const SectionHeader(
                      title: 'الموقع',
                      subtitle: 'تحديد مدينتك لحساب أوقات الصلاة',
                      icon: Icons.location_on_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingTile(
                            leading: _IconBox(
                              icon: Icons.location_on_rounded,
                              gradient: AppColors.goldGradient,
                            ),
                            title: 'المدينة الحالية',
                            subtitle:
                                '${app.location?.city ?? '-'}'
                                '${app.location?.country.isNotEmpty == true ? ' · ${app.location!.country}' : ''}',
                            trailing: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.gold,
                            ),
                            onTap: () => _pickCity(context),
                          ),
                          _Divider(),
                          _SettingTile(
                            leading: _IconBox(
                              icon: Icons.gps_fixed_rounded,
                              color: AppColors.sage,
                            ),
                            title: 'استخدام موقعي الحالي',
                            subtitle: 'تحديد بواسطة GPS',
                            trailing: Icon(
                              Icons.refresh_rounded,
                              color: isDark
                                  ? AppColors.goldLight
                                  : AppColors.primary,
                            ),
                            onTap: () async {
                              try {
                                await app.refreshLocation();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: const Text('تم تحديث الموقع'),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.md),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text('تعذر التحديث: $e'),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.md),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── قسم حساب الصلاة ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: const SectionHeader(
                      title: 'حساب الصلاة',
                      subtitle: 'اختر الطريقة والمذهب الفقهي',
                      icon: Icons.functions_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingTile(
                            leading: _IconBox(
                              icon: Icons.functions_rounded,
                              color: AppColors.info,
                            ),
                            title: 'طريقة الحساب',
                            subtitle:
                                PrayerService.calculationMethodsAr[app.method] ?? '',
                            trailing: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.gold,
                            ),
                            onTap: () => _showRadioSheet(
                              context,
                              title: 'طريقة الحساب',
                              icon: Icons.functions_rounded,
                              options: PrayerService.calculationMethodsAr,
                              current: app.method,
                              onSelected: (v) => app.setMethod(v),
                            ),
                          ),
                          _Divider(),
                          _SettingTile(
                            leading: _IconBox(
                              icon: Icons.school_rounded,
                              color: AppColors.sage,
                            ),
                            title: 'المذهب الفقهي',
                            subtitle:
                                PrayerService.madhabsAr[app.madhab] ?? '',
                            trailing: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.gold,
                            ),
                            onTap: () => _showRadioSheet(
                              context,
                              title: 'المذهب الفقهي',
                              icon: Icons.school_rounded,
                              options: PrayerService.madhabsAr,
                              current: app.madhab,
                              onSelected: (v) => app.setMadhab(v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── قسم المظهر ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: const SectionHeader(
                      title: 'المظهر',
                      subtitle: 'وضع العرض وحجم الخط',
                      icon: Icons.palette_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingTile(
                            leading: _IconBox(
                              icon: app.themeMode == ThemeMode.dark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              gradient: AppColors.goldGradient,
                            ),
                            title: 'وضع العرض',
                            subtitle: _themeLabel(app.themeMode),
                            trailing: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.gold,
                            ),
                            onTap: () => _showRadioSheet(
                              context,
                              title: 'وضع العرض',
                              icon: Icons.palette_rounded,
                              options: const {
                                'system': 'حسب الجهاز',
                                'light': 'فاتح',
                                'dark': 'داكن',
                              },
                              current: _themeKey(app.themeMode),
                              onSelected: (v) =>
                                  app.setThemeMode(_themeFromKey(v)),
                            ),
                          ),
                          _Divider(),
                          // حجم الخط مع شريط أنيق
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.md,
                              AppSpacing.md,
                              AppSpacing.sm,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _IconBox(
                                      icon: Icons.text_fields_rounded,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'حجم الخط',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14.5,
                                              color: isDark
                                                  ? AppColors
                                                      .textPrimaryDark
                                                  : AppColors
                                                      .textPrimaryLight,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              'تكبير أو تصغير النصوص',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: isDark
                                                    ? AppColors
                                                        .textTertiaryDark
                                                    : AppColors
                                                        .textTertiaryLight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppBadge(
                                      text:
                                          '${(app.fontScale * 100).round()}%',
                                      color: AppColors.gold,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppColors.gold,
                                    inactiveTrackColor: AppColors.gold
                                        .withValues(alpha: 0.18),
                                    thumbColor: AppColors.gold,
                                    overlayColor: AppColors.gold
                                        .withValues(alpha: 0.16),
                                    valueIndicatorColor:
                                        AppColors.primaryDark,
                                    trackHeight: 3,
                                  ),
                                  child: Slider(
                                    value: app.fontScale,
                                    min: 0.85,
                                    max: 1.4,
                                    divisions: 11,
                                    label:
                                        '${(app.fontScale * 100).round()}%',
                                    onChanged: (v) => app.setFontScale(v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── قسم الإشعارات ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: const SectionHeader(
                      title: 'الإشعارات',
                      subtitle: 'تنبيهات أوقات الصلاة',
                      icon: Icons.notifications_active_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SwitchTile(
                            leading: _IconBox(
                              icon: Icons.notifications_rounded,
                              gradient: AppColors.goldGradient,
                            ),
                            title: 'تفعيل الإشعارات',
                            subtitle: 'تلقي تنبيهات قبل الصلاة',
                            value: app.notificationsEnabled,
                            onChanged: app.setNotificationsEnabled,
                          ),
                          if (app.notificationsEnabled) ...[
                            _Divider(),
                            ..._buildPrayerNotifTiles(context, app),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── قسم حول التطبيق ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: const SectionHeader(
                      title: 'حول',
                      subtitle: 'معلومات عن التطبيق',
                      icon: Icons.info_outline_rounded,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: _SettingTile(
                        leading: _IconBox(
                          icon: Icons.info_rounded,
                          gradient: AppColors.goldGradient,
                        ),
                        title: 'عن التطبيق',
                        subtitle: 'الإصدار والمطور والمعلومات',
                        trailing: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.gold,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AboutScreen()),
                        ),
                      ),
                    ),
                  ),
                ),

                // ─── ختام فني ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
                    child: Column(
                      children: [
                        const GoldDivider(height: 32),
                        Text(
                          'بُني بإتقان لخدمة المسلمين',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold.withValues(alpha: 0.8),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
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

  // ───────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────
  List<Widget> _buildPrayerNotifTiles(BuildContext context, AppProvider app) {
    const prayers = [
      {'key': 'fajr', 'label': 'الفجر', 'icon': Icons.nightlight_round, 'color': AppColors.fajr},
      {'key': 'dhuhr', 'label': 'الظهر', 'icon': Icons.wb_sunny_rounded, 'color': AppColors.dhuhr},
      {'key': 'asr', 'label': 'العصر', 'icon': Icons.wb_twilight_rounded, 'color': AppColors.asr},
      {'key': 'maghrib', 'label': 'المغرب', 'icon': Icons.brightness_4_rounded, 'color': AppColors.maghrib},
      {'key': 'isha', 'label': 'العشاء', 'icon': Icons.bedtime_rounded, 'color': AppColors.isha},
    ];
    final tiles = <Widget>[];
    for (var i = 0; i < prayers.length; i++) {
      final p = prayers[i];
      final key = p['key'] as String;
      final label = p['label'] as String;
      final icon = p['icon'] as IconData;
      final color = p['color'] as Color;
      tiles.add(
        _SwitchTile(
          leading: _IconBox(icon: icon, color: color),
          title: 'تنبيه $label',
          value: app.prayerNotifMap[key] ?? true,
          onChanged: (v) => app.setPrayerNotif(key, v),
        ),
      );
      if (i < prayers.length - 1) tiles.add(_Divider());
    }
    return tiles;
  }

  void _showRadioSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Map<String, String> options,
    required String current,
    required void Function(String) onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? AppColors.surfaceDarkElevated
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.3),
                        AppColors.gold,
                        AppColors.gold.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(icon, color: AppColors.gold, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final entry = options.entries.elementAt(i);
                      final selected = entry.key == current;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          onTap: () {
                            onSelected(entry.key);
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: AppDurations.fast,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm + 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.gold.withValues(alpha: 0.10)
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: selected
                                    ? AppColors.gold
                                        .withValues(alpha: 0.4)
                                    : (isDark
                                            ? AppColors.gold
                                            : AppColors.primary)
                                        .withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: AppDurations.fast,
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected
                                        ? AppColors.gold
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.gold
                                          : AppColors.gold
                                              .withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: selected
                                          ? AppColors.gold
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      default:
        return 'حسب الجهاز';
    }
  }

  String _themeKey(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  ThemeMode _themeFromKey(String k) {
    switch (k) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

// ═══════════════════════════════════════════════════════
// عناصر مساعدة فنية
// ═══════════════════════════════════════════════════════

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  const _IconBox({required this.icon, this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (color ?? AppColors.gold).withValues(alpha: 0.14)
            : null,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: gradient != null
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: gradient != null ? Colors.white : (color ?? AppColors.gold),
        size: 19,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.gold.withValues(alpha: 0.06),
        highlightColor: AppColors.gold.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          child: Row(
            children: [
              leading,
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
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SwitchTile({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
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
          leading,
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
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
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
