import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_info.dart';

/// خدمة التخزين المحلية للإعدادات والموقع وتقدم الأذكار
class StorageService {
  static const _kLocation = 'location_v1';
  static const _kMethod = 'method_v1';
  static const _kMadhab = 'madhab_v1';
  static const _kThemeMode = 'theme_mode_v1';
  static const _kFontScale = 'font_scale_v1';
  static const _kNotifEnabled = 'notif_enabled_v1';
  static const _kNotifMap = 'notif_map_v1';
  static const _kAthkarProgressPrefix = 'athkar_progress_';
  static const _kTasbeehCount = 'tasbeeh_count_v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // === الموقع ===
  Future<void> saveLocation(LocationInfo info) async {
    final p = await prefs;
    await p.setString(_kLocation, jsonEncode(info.toJson()));
  }

  Future<LocationInfo?> loadLocation() async {
    final p = await prefs;
    final s = p.getString(_kLocation);
    if (s == null) return null;
    try {
      return LocationInfo.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // === طريقة الحساب ===
  Future<void> saveMethod(String key) async => (await prefs).setString(_kMethod, key);
  Future<String> loadMethod() async => (await prefs).getString(_kMethod) ?? 'umm_al_qura';

  // === المذهب ===
  Future<void> saveMadhab(String key) async => (await prefs).setString(_kMadhab, key);
  Future<String> loadMadhab() async => (await prefs).getString(_kMadhab) ?? 'shafi';

  // === الوضع (فاتح/داكن/نظام) ===
  Future<void> saveThemeMode(String mode) async => (await prefs).setString(_kThemeMode, mode);
  Future<String> loadThemeMode() async => (await prefs).getString(_kThemeMode) ?? 'system';

  // === حجم الخط ===
  Future<void> saveFontScale(double scale) async => (await prefs).setDouble(_kFontScale, scale);
  Future<double> loadFontScale() async => (await prefs).getDouble(_kFontScale) ?? 1.0;

  // === الإشعارات ===
  Future<void> saveNotificationsEnabled(bool v) async => (await prefs).setBool(_kNotifEnabled, v);
  Future<bool> loadNotificationsEnabled() async => (await prefs).getBool(_kNotifEnabled) ?? true;

  Future<void> savePrayerNotifMap(Map<String, bool> map) async =>
      (await prefs).setString(_kNotifMap, jsonEncode(map));
  Future<Map<String, bool>> loadPrayerNotifMap() async {
    final s = (await prefs).getString(_kNotifMap);
    if (s == null) {
      return {
        'fajr': true,
        'dhuhr': true,
        'asr': true,
        'maghrib': true,
        'isha': true,
      };
    }
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {'fajr': true, 'dhuhr': true, 'asr': true, 'maghrib': true, 'isha': true};
    }
  }

  // === تقدم الأذكار ===
  Future<void> saveAthkarProgress(String categoryId, Map<int, int> progress) async {
    final p = await prefs;
    final m = progress.map((k, v) => MapEntry(k.toString(), v));
    await p.setString('$_kAthkarProgressPrefix$categoryId', jsonEncode(m));
  }

  Future<Map<int, int>> loadAthkarProgress(String categoryId) async {
    final p = await prefs;
    final s = p.getString('$_kAthkarProgressPrefix$categoryId');
    if (s == null) return {};
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(int.parse(k), (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> clearAthkarProgress(String categoryId) async {
    final p = await prefs;
    await p.remove('$_kAthkarProgressPrefix$categoryId');
  }

  // === عداد التسبيح ===
  Future<void> saveTasbeehCount(int count) async => (await prefs).setInt(_kTasbeehCount, count);
  Future<int> loadTasbeehCount() async => (await prefs).getInt(_kTasbeehCount) ?? 0;
}
