import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/glass_card.dart';
import '../widgets/islamic_pattern_bg.dart';
import '../widgets/section_header.dart';
import 'home/home_screen.dart';
import 'athkar/athkar_list_screen.dart';
import 'athkar/tasbeeh_screen.dart';
import 'quran/quran_screen.dart';
import 'qibla/qibla_screen.dart';
import 'calendar/calendar_screen.dart';
import 'settings/settings_screen.dart';
import 'settings/about_screen.dart';

/// الواجهة الرئيسية: شريط تنقل سفلي فاخر + شاشة "المزيد" راقية.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AthkarListScreen(),
    QiblaScreen(),
    CalendarScreen(),
    _MoreScreen(),
  ];

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'الأذكار',
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'القبلة',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'التقويم',
    ),
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'المزيد',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _LuxuriousNavBar(
        items: _items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// شريط التنقل السفلي الفاخر
// ═══════════════════════════════════════════════════════

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _LuxuriousNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _LuxuriousNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          0,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceDarkElevated.withValues(alpha: 0.96),
                      AppColors.surfaceDark.withValues(alpha: 0.92),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.98),
                      Colors.white.withValues(alpha: 0.92),
                    ],
                  ),
            border: Border.all(
              color: AppColors.gold
                  .withValues(alpha: isDark ? 0.18 : 0.14),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: _NavBarTab(
                  item: items[i],
                  selected: selected,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: AppColors.gold.withValues(alpha: 0.10),
        highlightColor: AppColors.gold.withValues(alpha: 0.04),
        child: AnimatedPadding(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة الفعلية مع خلفية ذهبية للعنصر النشط
              AnimatedContainer(
                duration: AppDurations.normal,
                curve: AppCurves.emphasized,
                width: selected ? 46 : 36,
                height: 32,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.goldGradient : null,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                            spreadRadius: -1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 21,
                  color: selected ? Colors.white : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              // التسمية
              AnimatedDefaultTextStyle(
                duration: AppDurations.fast,
                curve: AppCurves.standard,
                style: TextStyle(
                  fontSize: selected ? 11 : 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? (isDark ? AppColors.goldLight : AppColors.goldDark)
                      : inactiveColor,
                  letterSpacing: 0.1,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// شاشة "المزيد" الفاخرة
// ═══════════════════════════════════════════════════════

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    final items = <_MoreItem>[
      _MoreItem(
        title: 'القرآن الكريم',
        subtitle: '114 سورة بترتيب المصحف',
        icon: Icons.menu_book_rounded,
        color: AppColors.gold,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QuranScreen()),
        ),
      ),
      _MoreItem(
        title: 'السبحة الإلكترونية',
        subtitle: 'عدّاد تسبيح أنيق',
        icon: Icons.fingerprint_rounded,
        color: AppColors.sage,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TasbeehScreen()),
        ),
      ),
      _MoreItem(
        title: 'الإعدادات',
        subtitle: 'الموقع، الحساب، المظهر',
        icon: Icons.tune_rounded,
        color: AppColors.info,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
      ),
      _MoreItem(
        title: 'عن التطبيق',
        subtitle: 'الإصدار والمعلومات',
        icon: Icons.info_outline_rounded,
        color: AppColors.maghrib,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AboutScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: IslamicPatternBackground()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: AppPageHeader(
                    title: 'المزيد',
                    subtitle: 'اكتشف باقي مزايا التطبيق',
                    leadingIcon: Icons.grid_view_rounded,
                  ),
                ),
                // ─── شبكة العناصر الكبيرة (2x2) ───
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.sm + 2,
                      crossAxisSpacing: AppSpacing.sm + 2,
                      childAspectRatio: 0.95,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _MoreCard(item: items[i]),
                      childCount: items.length,
                    ),
                  ),
                ),

                // ─── دعاء ختامي خفيف ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.huge + AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        const GoldDivider(height: 28),
                        Text(
                          '«وَأَنَّ هَٰذَا صِرَاطِي مُسْتَقِيمًا فَاتَّبِعُوهُ»',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.9,
                            color: AppColors.gold.withValues(alpha: 0.85),
                          ),
                        ),
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
}

class _MoreItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _MoreCard extends StatelessWidget {
  final _MoreItem item;
  const _MoreCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      onTap: item.onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.xl,
      child: Stack(
        children: [
          // توهج خلفي ناعم
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    item.color.withValues(alpha: 0.18),
                    item.color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة الكبيرة
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color.withValues(alpha: 0.85),
                      item.color.withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // لمعان زجاجي علوي
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.md),
                            topRight: Radius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // العنوان
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // سهم لطيف للإشارة إلى التنقل
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 14,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
