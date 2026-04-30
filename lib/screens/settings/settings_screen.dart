import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_info.dart';
import '../../providers/app_provider.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/islamic_pattern_bg.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickCity(BuildContext context) async {
    final app = context.read<AppProvider>();
    final cities = Cities.list;
    final selected = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('اختر مدينتك',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setSt(() => query = v),
                      decoration: InputDecoration(
                        hintText: 'بحث...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final c = filtered[i];
                          return ListTile(
                            leading: const Icon(Icons.location_city_rounded),
                            title: Text(c.name,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(c.country),
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
          SnackBar(content: Text('تم اختيار: ${selected.name}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Stack(
        children: [
          const IslamicPatternBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section(context, 'الموقع', [
                  ListTile(
                    leading: const Icon(Icons.location_on_rounded),
                    title: const Text('المدينة الحالية'),
                    subtitle: Text(
                      '${app.location?.city ?? '-'}'
                      '${app.location?.country.isNotEmpty == true ? ' · ${app.location!.country}' : ''}',
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => _pickCity(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.gps_fixed_rounded),
                    title: const Text('استخدام موقعي الحالي (GPS)'),
                    onTap: () async {
                      try {
                        await app.refreshLocation();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحديث الموقع')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تعذر: $e')),
                          );
                        }
                      }
                    },
                  ),
                ]),
                _section(context, 'حساب الصلاة', [
                  ListTile(
                    leading: const Icon(Icons.functions_rounded),
                    title: const Text('طريقة الحساب'),
                    subtitle: Text(PrayerService.calculationMethodsAr[app.method] ?? ''),
                    onTap: () => _showRadioDialog(
                      context,
                      title: 'طريقة الحساب',
                      options: PrayerService.calculationMethodsAr,
                      current: app.method,
                      onSelected: (v) => app.setMethod(v),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.school_rounded),
                    title: const Text('المذهب (حساب العصر)'),
                    subtitle: Text(PrayerService.madhabsAr[app.madhab] ?? ''),
                    onTap: () => _showRadioDialog(
                      context,
                      title: 'المذهب',
                      options: PrayerService.madhabsAr,
                      current: app.madhab,
                      onSelected: (v) => app.setMadhab(v),
                    ),
                  ),
                ]),
                _section(context, 'العرض', [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_rounded),
                    title: const Text('وضع العرض'),
                    subtitle: Text(_themeLabel(app.themeMode)),
                    onTap: () => _showRadioDialog(
                      context,
                      title: 'وضع العرض',
                      options: const {
                        'system': 'حسب الجهاز',
                        'light': 'فاتح',
                        'dark': 'داكن',
                      },
                      current: _themeKey(app.themeMode),
                      onSelected: (v) => app.setThemeMode(_themeFromKey(v)),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.text_fields_rounded),
                    title: const Text('حجم الخط'),
                    subtitle: Slider(
                      value: app.fontScale,
                      min: 0.85,
                      max: 1.4,
                      divisions: 11,
                      label: app.fontScale.toStringAsFixed(2),
                      onChanged: (v) => app.setFontScale(v),
                    ),
                  ),
                ]),
                _section(context, 'الإشعارات', [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_rounded),
                    title: const Text('تفعيل الإشعارات'),
                    value: app.notificationsEnabled,
                    onChanged: app.setNotificationsEnabled,
                  ),
                  for (final entry in const [
                    {'key': 'fajr', 'label': 'الفجر'},
                    {'key': 'dhuhr', 'label': 'الظهر'},
                    {'key': 'asr', 'label': 'العصر'},
                    {'key': 'maghrib', 'label': 'المغرب'},
                    {'key': 'isha', 'label': 'العشاء'},
                  ])
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_outlined),
                      title: Text('تنبيه ${entry['label']}'),
                      value: app.prayerNotifMap[entry['key']] ?? true,
                      onChanged: app.notificationsEnabled
                          ? (v) => app.setPrayerNotif(entry['key']!, v)
                          : null,
                    ),
                ]),
                _section(context, 'حول', [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('عن التطبيق'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.06)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  void _showRadioDialog<T>(
    BuildContext context, {
    required String title,
    required Map<String, String> options,
    required String current,
    required void Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              for (final entry in options.entries)
                RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: current,
                  onChanged: (v) {
                    if (v != null) onSelected(v);
                    Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 8),
            ],
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
