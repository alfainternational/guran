import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'prayer_times_service.dart';

/// خدمة حساب أوقات الشمس والليل والنهار
/// تعتمد على موقع المستخدم لحساب:
/// - وقت الشروق والغروب
/// - بداية الليل ونهايته
/// - أثلاث الليل (الأول والأوسط والأخير)
/// - وقت أذكار الصباح (بعد الفجر) وأذكار المساء (بعد العصر)
class SunCalculationService {
  static final SunCalculationService _instance =
      SunCalculationService._internal();
  factory SunCalculationService() => _instance;
  SunCalculationService._internal();

  final PrayerTimesService _prayerTimesService = PrayerTimesService();

  /// حساب أوقات اليوم الكاملة بناءً على الموقع
  Future<DayTimeInfo?> calculateDayTimes({DateTime? date}) async {
    final prayerTimes = await _prayerTimesService.calculatePrayerTimes(
      date: date,
    );
    if (prayerTimes == null) return null;

    // حساب أوقات الليل والنهار
    final maghrib = prayerTimes.maghrib; // بداية الليل
    final fajr = prayerTimes.fajr; // نهاية الليل (تقريباً)
    final sunrise = prayerTimes.sunrise; // الشروق
    final asr = prayerTimes.asr; // العصر (وقت أذكار المساء)

    // حساب أثلاث الليل
    // الليل يبدأ من المغرب إلى الفجر
    // نحسب الفجر لليوم التالي لأن الليل يمتد لليوم التالي
    final tomorrowDate = (date ?? DateTime.now()).add(const Duration(days: 1));
    final tomorrowPrayerTimes = await _prayerTimesService.calculatePrayerTimes(
      date: tomorrowDate,
    );

    DateTime nightEnd;
    if (tomorrowPrayerTimes != null) {
      nightEnd = tomorrowPrayerTimes.fajr;
    } else {
      // حساب تقريبي: الفجر في اليوم التالي
      nightEnd = DateTime(
        tomorrowDate.year,
        tomorrowDate.month,
        tomorrowDate.day,
        fajr.hour,
        fajr.minute,
      );
    }

    final nightDuration = nightEnd.difference(maghrib);
    final thirdDuration = Duration(
      milliseconds: nightDuration.inMilliseconds ~/ 3,
    );

    final firstThirdEnd = maghrib.add(thirdDuration);
    final secondThirdEnd = maghrib.add(thirdDuration * 2);
    final lastThirdStart = secondThirdEnd;

    return DayTimeInfo(
      date: date ?? DateTime.now(),
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: prayerTimes.isha,
      nightStart: maghrib,
      nightEnd: nightEnd,
      firstThirdEnd: firstThirdEnd,
      secondThirdEnd: secondThirdEnd,
      lastThirdStart: lastThirdStart,
      nightDuration: nightDuration,
    );
  }

  /// الحصول على وقت أذكار الصباح (بعد صلاة الفجر)
  Future<DateTime?> getMorningAdhkarTime({DateTime? date}) async {
    final dayTimes = await calculateDayTimes(date: date);
    if (dayTimes == null) return null;

    // أذكار الصباح تبدأ بعد صلاة الفجر بـ 5 دقائق
    return dayTimes.fajr.add(const Duration(minutes: 5));
  }

  /// الحصول على وقت أذكار المساء (بعد صلاة العصر)
  Future<DateTime?> getEveningAdhkarTime({DateTime? date}) async {
    final dayTimes = await calculateDayTimes(date: date);
    if (dayTimes == null) return null;

    // أذكار المساء تبدأ بعد صلاة العصر بـ 5 دقائق
    return dayTimes.asr.add(const Duration(minutes: 5));
  }

  /// الحصول على وقت الثلث الأخير من الليل
  Future<DateTime?> getLastThirdOfNight({DateTime? date}) async {
    final dayTimes = await calculateDayTimes(date: date);
    if (dayTimes == null) return null;

    return dayTimes.lastThirdStart;
  }

  /// الحصول على فترة الضحى (بعد شروق الشمس بـ 15-20 دقيقة)
  Future<DateTime?> getDuhaTime({DateTime? date}) async {
    final dayTimes = await calculateDayTimes(date: date);
    if (dayTimes == null) return null;

    return dayTimes.sunrise.add(const Duration(minutes: 20));
  }

  /// هل نحن في وقت النهار؟
  Future<bool> isDaytime() async {
    final dayTimes = await calculateDayTimes();
    if (dayTimes == null) return true; // افتراضياً نهار

    final now = DateTime.now();
    return now.isAfter(dayTimes.sunrise) && now.isBefore(dayTimes.maghrib);
  }

  /// هل نحن في الثلث الأخير من الليل؟
  Future<bool> isLastThirdOfNight() async {
    final dayTimes = await calculateDayTimes();
    if (dayTimes == null) return false;

    final now = DateTime.now();
    return now.isAfter(dayTimes.lastThirdStart) &&
        now.isBefore(dayTimes.nightEnd);
  }

  /// الحصول على الفترة الحالية من اليوم
  Future<DayPeriod> getCurrentDayPeriod() async {
    final dayTimes = await calculateDayTimes();
    if (dayTimes == null) return DayPeriod.unknown;

    final now = DateTime.now();

    if (now.isBefore(dayTimes.fajr)) {
      return DayPeriod.lastThirdOfNight;
    } else if (now.isBefore(dayTimes.sunrise)) {
      return DayPeriod.afterFajr;
    } else if (now.isBefore(dayTimes.dhuhr)) {
      return DayPeriod.morning;
    } else if (now.isBefore(dayTimes.asr)) {
      return DayPeriod.afternoon;
    } else if (now.isBefore(dayTimes.maghrib)) {
      return DayPeriod.afterAsr;
    } else if (now.isBefore(dayTimes.firstThirdEnd)) {
      return DayPeriod.firstThirdOfNight;
    } else if (now.isBefore(dayTimes.secondThirdEnd)) {
      return DayPeriod.secondThirdOfNight;
    } else {
      return DayPeriod.lastThirdOfNight;
    }
  }
}

/// معلومات أوقات اليوم الكاملة
class DayTimeInfo {
  final DateTime date;

  // أوقات الصلوات
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  // أوقات الليل
  final DateTime nightStart; // المغرب
  final DateTime nightEnd; // الفجر (اليوم التالي)
  final DateTime firstThirdEnd;
  final DateTime secondThirdEnd;
  final DateTime lastThirdStart;
  final Duration nightDuration;

  const DayTimeInfo({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.nightStart,
    required this.nightEnd,
    required this.firstThirdEnd,
    required this.secondThirdEnd,
    required this.lastThirdStart,
    required this.nightDuration,
  });

  /// مدة كل ثلث من الليل
  Duration get thirdDuration => Duration(
        milliseconds: nightDuration.inMilliseconds ~/ 3,
      );

  /// تنسيق الوقت للعرض
  String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

/// فترات اليوم
enum DayPeriod {
  afterFajr, // بعد الفجر (وقت أذكار الصباح)
  morning, // الصباح (من الشروق إلى الظهر)
  afternoon, // الظهيرة (من الظهر إلى العصر)
  afterAsr, // بعد العصر (وقت أذكار المساء)
  firstThirdOfNight, // الثلث الأول من الليل
  secondThirdOfNight, // الثلث الأوسط من الليل
  lastThirdOfNight, // الثلث الأخير من الليل
  unknown,
}
