import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'athkar/athkar_list_screen.dart';
import 'athkar/tasbeeh_screen.dart';
import 'quran/quran_screen.dart';
import 'qibla/qibla_screen.dart';
import 'calendar/calendar_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    AthkarListScreen(),
    QiblaScreen(),
    CalendarScreen(),
    _MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).cardColor,
        indicatorColor: AppColors.gold.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'القبلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'التقويم',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem('القرآن الكريم', Icons.menu_book_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranScreen()));
      }),
      _MoreItem('السبحة الإلكترونية', Icons.fingerprint_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasbeehScreen()));
      }),
      _MoreItem('الإعدادات', Icons.settings_rounded, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      }),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final it = items[i];
          return Material(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: it.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(it.icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(it.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _MoreItem(this.title, this.icon, this.onTap);
}
