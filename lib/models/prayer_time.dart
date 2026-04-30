/// نموذج بيانات وقت الصلاة الواحدة
class PrayerTime {
  final String name; // arabic name
  final String key; // fajr, sunrise, dhuhr, asr, maghrib, isha
  final DateTime time;
  final String iconAsset;

  PrayerTime({
    required this.name,
    required this.key,
    required this.time,
    this.iconAsset = '',
  });
}

/// نموذج بيانات أوقات الصلاة لليوم
class DailyPrayerTimes {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  DailyPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<PrayerTime> toList() => [
        PrayerTime(name: 'الفجر', key: 'fajr', time: fajr),
        PrayerTime(name: 'الشروق', key: 'sunrise', time: sunrise),
        PrayerTime(name: 'الظهر', key: 'dhuhr', time: dhuhr),
        PrayerTime(name: 'العصر', key: 'asr', time: asr),
        PrayerTime(name: 'المغرب', key: 'maghrib', time: maghrib),
        PrayerTime(name: 'العشاء', key: 'isha', time: isha),
      ];

  /// إرجاع الصلاة القادمة الأقرب من الوقت الحالي
  PrayerTime? nextPrayer([DateTime? now]) {
    final n = now ?? DateTime.now();
    for (final p in toList()) {
      if (p.time.isAfter(n)) return p;
    }
    return null;
  }

  /// إرجاع الصلاة الحالية (آخر صلاة مرّت)
  PrayerTime? currentPrayer([DateTime? now]) {
    final n = now ?? DateTime.now();
    PrayerTime? last;
    for (final p in toList()) {
      if (p.time.isBefore(n) || p.time.isAtSameMomentAs(n)) {
        last = p;
      } else {
        break;
      }
    }
    return last;
  }
}
