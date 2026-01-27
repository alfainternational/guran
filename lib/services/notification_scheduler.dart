import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'prayer_times_service.dart';
import 'sun_calculation_service.dart';

/// المنسق الرئيسي للتنبيهات
/// يربط بين مواقيت الصلاة، حساب الشمس، وإعدادات المستخدم
/// لجدولة جميع التنبيهات الفعلية بأوقاتها الصحيحة
class NotificationScheduler {
  static final NotificationScheduler _instance =
      NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  final NotificationService _notificationService = NotificationService();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final SunCalculationService _sunService = SunCalculationService();

  /// جدولة جميع تنبيهات اليوم بناءً على الموقع والإعدادات
  /// يُستدعى عند:
  /// 1. فتح التطبيق
  /// 2. تغيير إعدادات التنبيهات
  /// 3. منتصف الليل (إعادة الجدولة اليومية)
  Future<void> scheduleAllNotifications() async {
    debugPrint('=== بدء جدولة جميع التنبيهات ===');

    final prefs = await SharedPreferences.getInstance();

    // حساب أوقات اليوم بناءً على الموقع
    final dayTimes = await _sunService.calculateDayTimes();
    if (dayTimes == null) {
      debugPrint('فشل في حساب أوقات اليوم - استخدام أوقات ثابتة');
      await _scheduleFallbackNotifications(prefs);
      return;
    }

    debugPrint('أوقات اليوم:');
    debugPrint('  الفجر: ${dayTimes.formatTime(dayTimes.fajr)}');
    debugPrint('  الشروق: ${dayTimes.formatTime(dayTimes.sunrise)}');
    debugPrint('  الظهر: ${dayTimes.formatTime(dayTimes.dhuhr)}');
    debugPrint('  العصر: ${dayTimes.formatTime(dayTimes.asr)}');
    debugPrint('  المغرب: ${dayTimes.formatTime(dayTimes.maghrib)}');
    debugPrint('  العشاء: ${dayTimes.formatTime(dayTimes.isha)}');
    debugPrint('  الثلث الأخير: ${dayTimes.formatTime(dayTimes.lastThirdStart)}');

    // إلغاء جميع التنبيهات السابقة لإعادة الجدولة
    await _notificationService.cancelAllAdhkarNotifications();
    await _notificationService.cancelAllPrayerNotifications();

    // 1. جدولة تنبيهات الصلوات
    await _schedulePrayerNotifications(prefs, dayTimes);

    // 2. جدولة تنبيهات الأذكار
    await _scheduleAdhkarNotifications(prefs, dayTimes);

    // 3. جدولة تنبيه الثلث الأخير من الليل
    await _scheduleNightNotifications(prefs, dayTimes);

    // 4. جدولة إعادة الجدولة اليومية
    await _scheduleDailyReschedule(dayTimes);

    // طباعة التنبيهات المجدولة للتصحيح
    await _notificationService.debugPrintPendingNotifications();

    // حفظ آخر وقت جدولة
    await prefs.setString(
      'last_schedule_date',
      DateTime.now().toIso8601String(),
    );

    debugPrint('=== انتهت جدولة التنبيهات ===');
  }

  /// جدولة تنبيهات الصلوات الخمس
  Future<void> _schedulePrayerNotifications(
    SharedPreferences prefs,
    DayTimeInfo dayTimes,
  ) async {
    final isEnabled =
        prefs.getBool('prayer_notifications_enabled') ?? true;
    if (!isEnabled) {
      debugPrint('تنبيهات الصلاة معطّلة');
      return;
    }

    final minutesBefore = prefs.getInt('prayer_reminder_minutes') ?? 15;

    final prayers = {
      'fajr': {'name': 'الفجر', 'time': dayTimes.fajr},
      'dhuhr': {'name': 'الظهر', 'time': dayTimes.dhuhr},
      'asr': {'name': 'العصر', 'time': dayTimes.asr},
      'maghrib': {'name': 'المغرب', 'time': dayTimes.maghrib},
      'isha': {'name': 'العشاء', 'time': dayTimes.isha},
    };

    for (var entry in prayers.entries) {
      final isPrayerEnabled =
          prefs.getBool('prayer_${entry.key}_enabled') ?? true;
      if (!isPrayerEnabled) continue;

      final prayerTime = entry.value['time'] as DateTime;
      final prayerName = entry.value['name'] as String;

      await _notificationService.schedulePrayerNotification(
        prayerName: prayerName,
        prayerTime: prayerTime,
        minutesBefore: minutesBefore,
      );
    }
  }

  /// جدولة تنبيهات الأذكار بناءً على أوقات الصلاة الفعلية
  Future<void> _scheduleAdhkarNotifications(
    SharedPreferences prefs,
    DayTimeInfo dayTimes,
  ) async {
    // أذكار الصباح - بعد الفجر الفعلي
    final morningEnabled =
        prefs.getBool('morning_adhkar_enabled') ?? true;
    if (morningEnabled) {
      await _notificationService.scheduleMorningAdhkar(
        fajrTime: dayTimes.fajr,
      );
      debugPrint(
        'تمت جدولة أذكار الصباح: ${dayTimes.formatTime(dayTimes.fajr.add(const Duration(minutes: 5)))}',
      );
    }

    // أذكار المساء - بعد العصر الفعلي
    final eveningEnabled =
        prefs.getBool('evening_adhkar_enabled') ?? true;
    if (eveningEnabled) {
      await _notificationService.scheduleEveningAdhkar(
        asrTime: dayTimes.asr,
      );
      debugPrint(
        'تمت جدولة أذكار المساء: ${dayTimes.formatTime(dayTimes.asr.add(const Duration(minutes: 5)))}',
      );
    }

    // تنبيه الاستغفار - منتصف النهار
    final istighfarEnabled =
        prefs.getBool('istighfar_reminder_enabled') ?? true;
    if (istighfarEnabled) {
      await _notificationService.scheduleIstighfarReminder(
        time: dayTimes.dhuhr.subtract(const Duration(minutes: 30)),
      );
    }

    // تنبيه صلاة الضحى
    final duhaEnabled = prefs.getBool('duha_reminder_enabled') ?? false;
    if (duhaEnabled) {
      await _notificationService.scheduleDuhaReminder(
        sunriseTime: dayTimes.sunrise,
      );
    }

    // أذكار النوم - بعد العشاء
    final sleepEnabled =
        prefs.getBool('sleep_adhkar_enabled') ?? false;
    if (sleepEnabled) {
      await _notificationService.scheduleSleepAdhkar(
        ishaTime: dayTimes.isha,
      );
    }
  }

  /// جدولة تنبيهات الليل (الثلث الأخير)
  Future<void> _scheduleNightNotifications(
    SharedPreferences prefs,
    DayTimeInfo dayTimes,
  ) async {
    final lastThirdEnabled =
        prefs.getBool('last_third_night_enabled') ?? false;
    if (!lastThirdEnabled) return;

    await _notificationService.scheduleLastThirdOfNight(
      lastThirdStart: dayTimes.lastThirdStart,
    );
    debugPrint(
      'تمت جدولة الثلث الأخير: ${dayTimes.formatTime(dayTimes.lastThirdStart)}',
    );
  }

  /// جدولة إعادة الجدولة اليومية عند منتصف الليل
  /// لضمان تحديث التنبيهات كل يوم بالأوقات الصحيحة
  Future<void> _scheduleDailyReschedule(DayTimeInfo dayTimes) async {
    final now = DateTime.now();
    // إعادة الجدولة بعد منتصف الليل بدقيقة واحدة
    var rescheduleTime = DateTime(
      now.year,
      now.month,
      now.day + 1,
      0,
      1,
    );

    await _notificationService.scheduleNotification(
      id: NotificationIds.dailyReschedule,
      title: 'تحديث التنبيهات',
      body: 'يتم تحديث تنبيهات اليوم...',
      scheduledTime: rescheduleTime,
      payload: 'system:reschedule',
    );
  }

  /// جدولة بديلة بأوقات ثابتة (في حالة عدم توفر الموقع)
  Future<void> _scheduleFallbackNotifications(
    SharedPreferences prefs,
  ) async {
    final now = DateTime.now();

    // أوقات ثابتة تقريبية
    final morningEnabled =
        prefs.getBool('morning_adhkar_enabled') ?? true;
    if (morningEnabled) {
      final fajrFallback = DateTime(now.year, now.month, now.day, 5, 0);
      await _notificationService.scheduleMorningAdhkar(
        fajrTime: fajrFallback,
      );
    }

    final eveningEnabled =
        prefs.getBool('evening_adhkar_enabled') ?? true;
    if (eveningEnabled) {
      final asrFallback = DateTime(now.year, now.month, now.day, 15, 30);
      await _notificationService.scheduleEveningAdhkar(
        asrTime: asrFallback,
      );
    }

    final istighfarEnabled =
        prefs.getBool('istighfar_reminder_enabled') ?? true;
    if (istighfarEnabled) {
      final istighfarTime =
          DateTime(now.year, now.month, now.day, 12, 0);
      await _notificationService.scheduleIstighfarReminder(
        time: istighfarTime,
      );
    }

    final lastThirdEnabled =
        prefs.getBool('last_third_night_enabled') ?? false;
    if (lastThirdEnabled) {
      final lastThirdFallback =
          DateTime(now.year, now.month, now.day + 1, 2, 0);
      await _notificationService.scheduleLastThirdOfNight(
        lastThirdStart: lastThirdFallback,
      );
    }

    // تنبيهات الصلوات بأوقات ثابتة
    final prayerEnabled =
        prefs.getBool('prayer_notifications_enabled') ?? true;
    if (prayerEnabled) {
      await _prayerTimesService.scheduleAllPrayerNotifications();
    }
  }

  /// إعادة جدولة التنبيهات عند تغيير الإعدادات
  Future<void> rescheduleOnSettingsChange() async {
    await scheduleAllNotifications();
  }

  /// التحقق مما إذا كانت التنبيهات بحاجة لإعادة جدولة
  /// (مثلاً إذا مر يوم جديد منذ آخر جدولة)
  Future<bool> needsReschedule() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScheduleStr = prefs.getString('last_schedule_date');

    if (lastScheduleStr == null) return true;

    final lastSchedule = DateTime.tryParse(lastScheduleStr);
    if (lastSchedule == null) return true;

    final now = DateTime.now();
    // إعادة الجدولة إذا كان يوم جديد
    return lastSchedule.day != now.day ||
        lastSchedule.month != now.month ||
        lastSchedule.year != now.year;
  }
}
