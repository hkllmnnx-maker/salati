import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/location_info.dart';
import '../models/prayer_time.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

enum AppLoadState { initial, loading, ready, error }

/// المزوّد الرئيسي للتطبيق: يحمل الموقع، الإعدادات، وأوقات الصلاة
class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notif = NotificationService();

  LocationInfo? _location;
  String _method = 'umm_al_qura';
  String _madhab = 'shafi';
  ThemeMode _themeMode = ThemeMode.system;
  double _fontScale = 1.0;
  bool _notificationsEnabled = true;
  Map<String, bool> _prayerNotifMap = {
    'fajr': true,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
  };

  AppLoadState _state = AppLoadState.initial;
  String? _error;
  bool _locationDenied = false;

  DailyPrayerTimes? _todayPrayers;

  // Getters
  LocationInfo? get location => _location;
  String get method => _method;
  String get madhab => _madhab;
  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  bool get notificationsEnabled => _notificationsEnabled;
  Map<String, bool> get prayerNotifMap => _prayerNotifMap;
  AppLoadState get state => _state;
  String? get error => _error;
  bool get locationDenied => _locationDenied;
  DailyPrayerTimes? get todayPrayers => _todayPrayers;

  Future<void> bootstrap() async {
    _state = AppLoadState.loading;
    notifyListeners();

    try {
      _location = await _storage.loadLocation();
      _method = await _storage.loadMethod();
      _madhab = await _storage.loadMadhab();
      _fontScale = await _storage.loadFontScale();
      _notificationsEnabled = await _storage.loadNotificationsEnabled();
      _prayerNotifMap = await _storage.loadPrayerNotifMap();

      final tm = await _storage.loadThemeMode();
      _themeMode = _modeFromString(tm);

      await _notif.init();

      if (_location == null) {
        // محاولة الحصول على الموقع تلقائياً، وإن فشل نضع موقع افتراضي
        try {
          final loc = await LocationService.getCurrentLocation();
          _location = loc;
          await _storage.saveLocation(loc);
        } catch (_) {
          _locationDenied = true;
          // موقع افتراضي: مكة المكرمة
          _location = const LocationInfo(
            latitude: 21.4225,
            longitude: 39.8262,
            country: 'السعودية',
            city: 'مكة المكرمة',
            isManual: true,
          );
        }
      }

      _recomputePrayers();
      _state = AppLoadState.ready;
      _error = null;
      _scheduleNotifications();
    } catch (e) {
      _error = e.toString();
      _state = AppLoadState.error;
    }
    notifyListeners();
  }

  void _recomputePrayers() {
    if (_location == null) return;
    _todayPrayers = PrayerService.calculate(
      location: _location!,
      date: DateTime.now(),
      methodKey: _method,
      madhabKey: _madhab,
    );
  }

  Future<void> refreshLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      _location = loc;
      _locationDenied = false;
      await _storage.saveLocation(loc);
      _recomputePrayers();
      _scheduleNotifications();
      notifyListeners();
    } catch (e) {
      _locationDenied = true;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setManualLocation(LocationInfo info) async {
    _location = info;
    _locationDenied = false;
    await _storage.saveLocation(info);
    _recomputePrayers();
    _scheduleNotifications();
    notifyListeners();
  }

  Future<void> setMethod(String key) async {
    _method = key;
    await _storage.saveMethod(key);
    _recomputePrayers();
    _scheduleNotifications();
    notifyListeners();
  }

  Future<void> setMadhab(String key) async {
    _madhab = key;
    await _storage.saveMadhab(key);
    _recomputePrayers();
    _scheduleNotifications();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(_modeToString(mode));
    notifyListeners();
  }

  Future<void> setFontScale(double v) async {
    _fontScale = v;
    await _storage.saveFontScale(v);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool v) async {
    _notificationsEnabled = v;
    await _storage.saveNotificationsEnabled(v);
    if (v) {
      await _notif.requestPermission();
      _scheduleNotifications();
    } else {
      await _notif.cancelAll();
    }
    notifyListeners();
  }

  Future<void> setPrayerNotif(String key, bool enabled) async {
    _prayerNotifMap[key] = enabled;
    await _storage.savePrayerNotifMap(_prayerNotifMap);
    _scheduleNotifications();
    notifyListeners();
  }

  Future<void> _scheduleNotifications() async {
    if (!_notificationsEnabled || _todayPrayers == null) return;
    try {
      await _notif.schedulePrayers(
        prayers: _todayPrayers!,
        enabledMap: _prayerNotifMap,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Schedule failed: $e');
    }
  }

  PrayerTime? get nextPrayer {
    if (_location == null) return null;
    return PrayerService.nextPrayerSmart(
      location: _location!,
      methodKey: _method,
      madhabKey: _madhab,
    );
  }

  PrayerTime? get currentPrayer => _todayPrayers?.currentPrayer();

  DailyPrayerTimes prayersForDate(DateTime date) {
    return PrayerService.calculate(
      location: _location!,
      date: date,
      methodKey: _method,
      madhabKey: _madhab,
    );
  }

  String _modeToString(ThemeMode m) =>
      m == ThemeMode.light ? 'light' : (m == ThemeMode.dark ? 'dark' : 'system');
  ThemeMode _modeFromString(String s) =>
      s == 'light' ? ThemeMode.light : (s == 'dark' ? ThemeMode.dark : ThemeMode.system);
}
