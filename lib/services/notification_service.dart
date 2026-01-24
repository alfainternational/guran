import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/motivational_messages.dart';

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

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    // يمكن فتح صفحة معينة أو تنفيذ إجراء معين
  }

  /// طلب أذونات الإشعارات
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? false;
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
  Future<void> showMotivationalNotification(MotivationalMessage message) async {
    await showNotification(
      id: message.id.hashCode,
      title: '✨ رسالة تحفيزية',
      body: message.arabicText,
    );
  }

  /// إشعار تذكير بالقراءة
  Future<void> showReadingReminder({
    required String portion,
    required int estimatedMinutes,
  }) async {
    await showNotification(
      id: 1,
      title: '📖 حان وقت القراءة',
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
      title: '🌙 تذكير بالأذكار',
      body: 'حان وقت $dhikrType ($time)',
    );
  }

  /// جدولة إشعار في وقت محدد
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'guran_scheduled',
      'Scheduled Notifications',
      channelDescription: 'الإشعارات المجدولة',
      importance: Importance.high,
      priority: Priority.high,
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

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// جدولة إشعار يومي
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // إذا كان الوقت قد مضى اليوم، جدول للغد
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledDate,
    );
  }

  /// جدولة تذكيرات الأذكار اليومية
  Future<void> scheduleDailyDhikrReminders() async {
    // أذكار الصباح (بعد الفجر - 6 صباحاً)
    await scheduleDailyNotification(
      id: 100,
      title: '🌅 أذكار الصباح',
      body: 'صباح الخير! حان وقت أذكار الصباح',
      hour: 6,
      minute: 0,
    );

    // أذكار المساء (بعد العصر - 4 عصراً)
    await scheduleDailyNotification(
      id: 101,
      title: '🌙 أذكار المساء',
      body: 'مساء الخير! حان وقت أذكار المساء',
      hour: 16,
      minute: 0,
    );

    // تذكير بالاستغفار (منتصف النهار)
    await scheduleDailyNotification(
      id: 102,
      title: '🤲 وقت الاستغفار',
      body: 'استغفر الله وتب إليه',
      hour: 12,
      minute: 0,
    );
  }

  /// جدولة تذكيرات القراءة حسب الخطة
  Future<void> scheduleReadingReminders({
    required List<int> hours, // ساعات التذكير
  }) async {
    int notificationId = 200;

    for (final hour in hours) {
      await scheduleDailyNotification(
        id: notificationId++,
        title: '📖 وقت القراءة',
        body: MotivationalMessages.getRandomMessage(MessageTrigger.reminderTime)
            .arabicText,
        hour: hour,
        minute: 0,
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

  /// الحصول على الإشعارات المعلقة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
