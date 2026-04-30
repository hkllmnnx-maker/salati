import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:permission_handler/permission_handler.dart';

import '../models/prayer_time.dart';

/// خدمة الإشعارات: جدولة إشعارات الصلوات وتنبيه ما قبل الصلاة
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Notification init failed: $e');
      }
    }
  }

  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// جدولة إشعارات الصلوات لليوم بناءً على إعدادات المستخدم
  Future<void> schedulePrayers({
    required DailyPrayerTimes prayers,
    required Map<String, bool> enabledMap,
    bool prePrayerReminder = true,
    int reminderMinutes = 15,
  }) async {
    if (!_initialized) await init();

    await cancelAll();

    final list = prayers.toList().where((p) => p.key != 'sunrise').toList();
    int id = 100;

    for (final p in list) {
      final enabled = enabledMap[p.key] ?? true;
      if (!enabled) continue;
      if (p.time.isBefore(DateTime.now())) continue;

      // إشعار وقت الصلاة
      await _scheduleSingle(
        id: id++,
        title: 'حان وقت صلاة ${p.name}',
        body: 'تقبّل الله منا ومنكم — الصلاة خير من النوم',
        dt: p.time,
      );

      // إشعار قبل الصلاة
      if (prePrayerReminder) {
        final pre = p.time.subtract(Duration(minutes: reminderMinutes));
        if (pre.isAfter(DateTime.now())) {
          await _scheduleSingle(
            id: id++,
            title: 'تذكير: ${p.name} بعد $reminderMinutes دقيقة',
            body: 'استعدّ لأداء صلاة ${p.name}',
            dt: pre,
          );
        }
      }
    }
  }

  Future<void> _scheduleSingle({
    required int id,
    required String title,
    required String body,
    required DateTime dt,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(dt, tz.local);
      const androidDetails = AndroidNotificationDetails(
        'salati_prayers',
        'مواعيد الصلاة',
        channelDescription: 'إشعارات أوقات الصلاة من تطبيق صلاتي',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Schedule failed: $e');
    }
  }
}
