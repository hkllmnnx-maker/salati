import 'package:adhan/adhan.dart';
import '../models/prayer_time.dart';
import '../models/location_info.dart';

/// خدمة حساب أوقات الصلاة بناءً على الموقع وطريقة الحساب والمذهب
class PrayerService {
  /// قائمة طرق الحساب المتاحة للعرض في الإعدادات
  static const Map<String, String> calculationMethodsAr = {
    'umm_al_qura': 'أم القرى - السعودية',
    'muslim_world_league': 'رابطة العالم الإسلامي',
    'egyptian': 'الهيئة المصرية العامة',
    'karachi': 'جامعة العلوم - كراتشي',
    'dubai': 'دبي',
    'qatar': 'قطر',
    'kuwait': 'الكويت',
    'moon_sighting_committee': 'لجنة رؤية الهلال',
    'singapore': 'سنغافورة',
    'turkey': 'تركيا',
    'tehran': 'طهران',
    'north_america': 'أمريكا الشمالية (ISNA)',
  };

  static const Map<String, String> madhabsAr = {
    'shafi': 'الشافعي والمالكي والحنبلي',
    'hanafi': 'الحنفي',
  };

  static CalculationParameters _paramsFromKey(String key) {
    switch (key) {
      case 'muslim_world_league':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'karachi':
        return CalculationMethod.karachi.getParameters();
      case 'dubai':
        return CalculationMethod.dubai.getParameters();
      case 'qatar':
        return CalculationMethod.qatar.getParameters();
      case 'kuwait':
        return CalculationMethod.kuwait.getParameters();
      case 'moon_sighting_committee':
        return CalculationMethod.moon_sighting_committee.getParameters();
      case 'singapore':
        return CalculationMethod.singapore.getParameters();
      case 'turkey':
        return CalculationMethod.turkey.getParameters();
      case 'tehran':
        return CalculationMethod.tehran.getParameters();
      case 'north_america':
        return CalculationMethod.north_america.getParameters();
      case 'umm_al_qura':
      default:
        return CalculationMethod.umm_al_qura.getParameters();
    }
  }

  static Madhab _madhabFromKey(String key) {
    return key == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
  }

  /// حساب أوقات الصلاة لتاريخ محدد
  static DailyPrayerTimes calculate({
    required LocationInfo location,
    required DateTime date,
    String methodKey = 'umm_al_qura',
    String madhabKey = 'shafi',
  }) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final params = _paramsFromKey(methodKey);
    params.madhab = _madhabFromKey(madhabKey);

    final dateComp = DateComponents(date.year, date.month, date.day);
    final pt = PrayerTimes(coordinates, dateComp, params);

    return DailyPrayerTimes(
      date: date,
      fajr: pt.fajr,
      sunrise: pt.sunrise,
      dhuhr: pt.dhuhr,
      asr: pt.asr,
      maghrib: pt.maghrib,
      isha: pt.isha,
    );
  }

  /// إرجاع الصلاة القادمة. إذا انتهت صلوات اليوم تُرجع فجر الغد.
  static PrayerTime nextPrayerSmart({
    required LocationInfo location,
    String methodKey = 'umm_al_qura',
    String madhabKey = 'shafi',
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final today = calculate(
      location: location,
      date: n,
      methodKey: methodKey,
      madhabKey: madhabKey,
    );
    final next = today.nextPrayer(n);
    if (next != null) return next;
    final tomorrow = calculate(
      location: location,
      date: n.add(const Duration(days: 1)),
      methodKey: methodKey,
      madhabKey: madhabKey,
    );
    return PrayerTime(name: 'الفجر', key: 'fajr', time: tomorrow.fajr);
  }
}
