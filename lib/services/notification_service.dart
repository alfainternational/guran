import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/motivational_messages.dart';

/// معرّفات ثابتة للتنبيهات - لضمان عدم التكرار وإمكانية الإلغاء
class NotificationIds {
  // أذكار الصباح والمساء
  static const int morningAdhkar = 100;
  static const int eveningAdhkar = 101;
  static const int istighfar = 102;

  // الثلث الأخير من الليل
  static const int lastThirdOfNight = 110;

  // صلاة الضحى
  static const int duha = 115;

  // أذكار النوم
  static const int sleepAdhkar = 120;

  // الصلوات (200-204)
  static const int fajr = 200;
  static const int dhuhr = 201;
  static const int asr = 202;
  static const int maghrib = 203;
  static const int isha = 204;

  // تذكيرات القراءة (300-309)
  static const int readingBase = 300;

  // الورد اليومي (400-409)
  static const int wirdBase = 400;

  // أذكار مخصصة (500+)
  static const int customBase = 500;

  // إعادة الجدولة اليومية
  static const int dailyReschedule = 999;
}

/// خدمة الإشعارات
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // معالجة النقر على الإشعار
    debugPrint('تم النقر على الإشعار: ${response.payload}');
  }

  /// طلب أذونات الإشعارات
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // طلب إذن الإشعارات لأندرويد 13+
      await androidPlugin?.requestNotificationsPermission();

      // التحقق وطلب إذن التنبيهات الدقيقة لأندرويد 12+
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }

      return await Permission.notification.isGranted;
    }
    return true;
  }

  /// إرسال إشعار فوري
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'guran_channel',
      'Guran Notifications',
      channelDescription: 'إشعارات تطبيق قرآن',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// إشعار تحفيزي
  Future<void> showMotivationalNotification(
      MotivationalMessage message) async {
    await showNotification(
      id: message.id.hashCode,
      title: 'رسالة تحفيزية',
      body: message.arabicText,
    );
  }

  /// إشعار إنجاز
  Future<void> showAchievementNotification(String message) async {
    await showNotification(
      id: message.hashCode,
      title: 'إنجاز جديد',
      body: message,
    );
  }

  /// إشعار تذكير بالقراءة
  Future<void> showReadingReminder({
    required String portion,
    required int estimatedMinutes,
  }) async {
    await showNotification(
      id: 1,
      title: 'حان وقت القراءة',
      body: 'لا تنس قراءة $portion اليوم (حوالي $estimatedMinutes دقيقة)',
    );
  }

  /// إشعار تذكير بالأذكار
  Future<void> showDhikrReminder({
    required String dhikrType,
    required String time,
  }) async {
    await showNotification(
      id: 2,
      title: 'تذكير بالأذكار',
      body: 'حان وقت $dhikrType ($time)',
    );
  }

  /// جدولة إشعار في وقت محدد بدقة
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // لا تجدول إشعاراً في الماضي
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('تم تجاهل إشعار ($id): الوقت في الماضي');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        'guran_scheduled',
        'الإشعارات المجدولة',
        channelDescription: 'تنبيهات الصلاة والأذكار',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: await _getScheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint(
        'تمت جدولة إشعار ($id): "$title" في ${scheduledTime.toString()}',
      );
    } catch (e) {
      debugPrint('خطأ في جدولة الإشعار ($id): $e');
    }
  }

  Future<AndroidScheduleMode> _getScheduleMode() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (await Permission.scheduleExactAlarm.isGranted) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// تنبيه مواقيت الصلاة
  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    int minutesBefore = 15,
  }) async {
    final notificationTime =
        prayerTime.subtract(Duration(minutes: minutesBefore));

    if (notificationTime.isBefore(DateTime.now())) return;

    await scheduleNotification(
      id: _getPrayerNotificationId(prayerName),
      title: 'حان وقت صلاة $prayerName',
      body: minutesBefore > 0
          ? 'بقي $minutesBefore دقيقة على صلاة $prayerName'
          : 'حان الآن وقت صلاة $prayerName',
      scheduledTime: notificationTime,
      payload: 'prayer:$prayerName',
    );
  }

  int _getPrayerNotificationId(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return NotificationIds.fajr;
      case 'الظهر':
        return NotificationIds.dhuhr;
      case 'العصر':
        return NotificationIds.asr;
      case 'المغرب':
        return NotificationIds.maghrib;
      case 'العشاء':
        return NotificationIds.isha;
      default:
        return prayerName.hashCode;
    }
  }

  /// جدولة تنبيه أذكار الصباح بناءً على وقت الفجر الفعلي
  Future<void> scheduleMorningAdhkar({
    required DateTime fajrTime,
  }) async {
    // أذكار الصباح بعد الفجر بـ 5 دقائق
    final adhkarTime = fajrTime.add(const Duration(minutes: 5));

    await scheduleNotification(
      id: NotificationIds.morningAdhkar,
      title: 'أذكار الصباح',
      body:
          'أصبحنا وأصبح الملك لله - حان وقت أذكار الصباح',
      scheduledTime: adhkarTime,
      payload: 'adhkar:morning',
    );
  }

  /// جدولة تنبيه أذكار المساء بناءً على وقت العصر الفعلي
  Future<void> scheduleEveningAdhkar({
    required DateTime asrTime,
  }) async {
    // أذكار المساء بعد العصر بـ 5 دقائق
    final adhkarTime = asrTime.add(const Duration(minutes: 5));

    await scheduleNotification(
      id: NotificationIds.eveningAdhkar,
      title: 'أذكار المساء',
      body:
          'أمسينا وأمسى الملك لله - حان وقت أذكار المساء',
      scheduledTime: adhkarTime,
      payload: 'adhkar:evening',
    );
  }

  /// جدولة تنبيه الثلث الأخير من الليل
  Future<void> scheduleLastThirdOfNight({
    required DateTime lastThirdStart,
  }) async {
    await scheduleNotification(
      id: NotificationIds.lastThirdOfNight,
      title: 'الثلث الأخير من الليل',
      body:
          'ينزل ربنا تبارك وتعالى كل ليلة إلى السماء الدنيا - هل من داعٍ فأستجيب له؟',
      scheduledTime: lastThirdStart,
      payload: 'night:last_third',
    );
  }

  /// جدولة تنبيه صلاة الضحى
  Future<void> scheduleDuhaReminder({
    required DateTime sunriseTime,
  }) async {
    // صلاة الضحى بعد الشروق بـ 20 دقيقة
    final duhaTime = sunriseTime.add(const Duration(minutes: 20));

    await scheduleNotification(
      id: NotificationIds.duha,
      title: 'وقت صلاة الضحى',
      body: 'لا تنس صلاة الضحى - وقتها من ارتفاع الشمس إلى قبل الزوال',
      scheduledTime: duhaTime,
      payload: 'prayer:duha',
    );
  }

  /// جدولة تنبيه أذكار النوم
  Future<void> scheduleSleepAdhkar({
    required DateTime ishaTime,
  }) async {
    // أذكار النوم بعد العشاء بساعتين
    final sleepTime = ishaTime.add(const Duration(hours: 2));

    await scheduleNotification(
      id: NotificationIds.sleepAdhkar,
      title: 'أذكار النوم',
      body: 'باسمك اللهم أموت وأحيا - لا تنس أذكار النوم',
      scheduledTime: sleepTime,
      payload: 'adhkar:sleep',
    );
  }

  /// جدولة تنبيه الاستغفار
  Future<void> scheduleIstighfarReminder({
    required DateTime time,
  }) async {
    await scheduleNotification(
      id: NotificationIds.istighfar,
      title: 'وقت الاستغفار',
      body: 'استغفر الله العظيم وأتوب إليه',
      scheduledTime: time,
      payload: 'adhkar:istighfar',
    );
  }

  /// جدولة تذكيرات القراءة حسب الخطة
  Future<void> scheduleReadingReminders({
    required List<int> hours,
  }) async {
    int notificationId = NotificationIds.readingBase;

    final now = DateTime.now();
    for (final hour in hours) {
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        0,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await scheduleNotification(
        id: notificationId++,
        title: 'وقت القراءة',
        body: MotivationalMessages.getRandomMessage(
                MessageTrigger.reminderTime)
            .arabicText,
        scheduledTime: scheduledDate,
        payload: 'reading:reminder',
      );
    }
  }

  /// تنبيه تتبع الذكر المخصص
  Future<void> scheduleDhikrTrackerReminder({
    required String dhikrId,
    required String dhikrName,
    required int currentCount,
    required int targetCount,
    required Duration interval,
  }) async {
    if (currentCount >= targetCount) {
      await cancelNotification(dhikrId.hashCode);
      return;
    }

    final nextReminder = DateTime.now().add(interval);
    await scheduleNotification(
      id: dhikrId.hashCode,
      title: 'تذكير: $dhikrName',
      body:
          'تقدمك: $currentCount/$targetCount - المتبقي: ${targetCount - currentCount}',
      scheduledTime: nextReminder,
      payload: 'dhikr_tracker:$dhikrId',
    );
  }

  /// تنبيه الورد اليومي من القرآن
  Future<void> scheduleQuranWirdReminder({
    required int dailyPortion,
    required int completedToday,
    List<int>? reminderHours,
  }) async {
    if (completedToday >= dailyPortion) {
      // أكمل الورد - لا حاجة للتذكير
      for (var i = 0; i < 3; i++) {
        await cancelNotification(NotificationIds.wirdBase + i);
      }
      return;
    }

    final hours = reminderHours ?? [9, 15, 20];
    final now = DateTime.now();
    int baseId = NotificationIds.wirdBase;

    for (var hour in hours) {
      var reminderTime = DateTime(now.year, now.month, now.day, hour, 0);

      if (reminderTime.isBefore(now)) continue;

      await scheduleNotification(
        id: baseId++,
        title: 'تذكير بالورد اليومي',
        body: 'لم تكمل وردك اليوم بعد ($completedToday/$dailyPortion)',
        scheduledTime: reminderTime,
        payload: 'reading:wird',
      );
    }
  }

  /// إلغاء إشعار محدد
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// إلغاء جميع تنبيهات الأذكار
  Future<void> cancelAllAdhkarNotifications() async {
    await cancelNotification(NotificationIds.morningAdhkar);
    await cancelNotification(NotificationIds.eveningAdhkar);
    await cancelNotification(NotificationIds.istighfar);
    await cancelNotification(NotificationIds.lastThirdOfNight);
    await cancelNotification(NotificationIds.duha);
    await cancelNotification(NotificationIds.sleepAdhkar);
  }

  /// إلغاء جميع تنبيهات الصلوات
  Future<void> cancelAllPrayerNotifications() async {
    await cancelNotification(NotificationIds.fajr);
    await cancelNotification(NotificationIds.dhuhr);
    await cancelNotification(NotificationIds.asr);
    await cancelNotification(NotificationIds.maghrib);
    await cancelNotification(NotificationIds.isha);
  }

  /// الحصول على الإشعارات المعلقة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// طباعة جميع الإشعارات المعلقة (للتصحيح)
  Future<void> debugPrintPendingNotifications() async {
    final pending = await getPendingNotifications();
    debugPrint('=== الإشعارات المعلقة (${pending.length}) ===');
    for (var n in pending) {
      debugPrint('  [${n.id}] ${n.title}: ${n.body}');
    }
    debugPrint('=============================');
  }
}
