import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class Formatters {
  static const arabicMonthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const arabicWeekdaysAr = [
    'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];

  static const hijriMonthsAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static String toArabicDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var s = input;
    for (int i = 0; i < en.length; i++) {
      s = s.replaceAll(en[i], ar[i]);
    }
    return s;
  }

  static String formatTime12(DateTime dt) {
    final fmt = DateFormat('h:mm', 'ar');
    final t = fmt.format(dt);
    final period = dt.hour >= 12 ? 'م' : 'ص';
    return '${toArabicDigits(t)} $period';
  }

  static String formatTime24(DateTime dt) {
    final fmt = DateFormat('HH:mm', 'ar');
    return toArabicDigits(fmt.format(dt));
  }

  static String formatDateGregorianAr(DateTime dt) {
    final w = arabicWeekdaysAr[(dt.weekday - 1) % 7];
    final m = arabicMonthsAr[dt.month - 1];
    return '$w ${toArabicDigits(dt.day.toString())} $m ${toArabicDigits(dt.year.toString())}';
  }

  static String formatHijriAr(DateTime dt) {
    final h = HijriCalendar.fromDate(dt);
    final m = (h.hMonth >= 1 && h.hMonth <= 12) ? hijriMonthsAr[h.hMonth - 1] : '';
    return '${toArabicDigits(h.hDay.toString())} $m ${toArabicDigits(h.hYear.toString())} هـ';
  }

  static String formatCountdown(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return toArabicDigits('$h:$m:$s');
  }
}
