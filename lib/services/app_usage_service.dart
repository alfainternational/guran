import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/motivational_messages.dart';
import 'notification_service.dart';

/// معلومات استخدام التطبيق
class AppUsageInfo {
  final String packageName;
  final String appName;
  final int usageTimeMinutes;
  final int openCount;
  final DateTime date;

  AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.usageTimeMinutes,
    required this.openCount,
    required this.date,
  });
}

/// خدمة مراقبة استخدام التطبيقات
class AppUsageService {
  static final AppUsageService _instance = AppUsageService._internal();
  factory AppUsageService() => _instance;
  AppUsageService._internal();

  final _notificationService = NotificationService();

  // قائمة تطبيقات التواصل الاجتماعي الشائعة
  static const socialMediaApps = [
    'com.facebook.katana', // Facebook
    'com.instagram.android', // Instagram
    'com.twitter.android', // Twitter (X)
    'com.snapchat.android', // Snapchat
    'com.zhiliaoapp.musically', // TikTok
    'com.whatsapp', // WhatsApp
    'com.google.android.youtube', // YouTube
    'com.linkedin.android', // LinkedIn
    'com.reddit.frontpage', // Reddit
    'com.pinterest', // Pinterest
  ];

  Timer? _monitoringTimer;
  int _socialMediaUsageMinutes = 0;
  bool _isMonitoring = false;

  /// طلب أذونات الوصول لبيانات الاستخدام
  Future<bool> requestUsagePermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false; // متوفر فقط على Android
    }

    // فتح إعدادات الوصول للاستخدام
    final status = await Permission.appTrackingTransparency.request();
    return status.isGranted;
  }

  /// التحقق من حالة الأذونات
  Future<bool> hasUsagePermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    final status = await Permission.appTrackingTransparency.status;
    return status.isGranted;
  }

  /// بدء مراقبة استخدام التطبيقات
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    final hasPermission = await hasUsagePermission();
    if (!hasPermission) {
      print('لا يوجد إذن للوصول لبيانات الاستخدام');
      return;
    }

    _isMonitoring = true;

    // مراقبة كل 5 دقائق
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkSocialMediaUsage(),
    );
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
  }

  /// فحص استخدام وسائل التواصل الاجتماعي
  Future<void> _checkSocialMediaUsage() async {
    try {
      final usageToday = await getTodayUsage();

      int totalSocialMediaMinutes = 0;
      for (final usage in usageToday) {
        if (socialMediaApps.contains(usage.packageName)) {
          totalSocialMediaMinutes += usage.usageTimeMinutes;
        }
      }

      // إذا زاد الاستخدام عن العتبة (مثلاً 30 دقيقة)
      if (totalSocialMediaMinutes > _socialMediaUsageMinutes + 30) {
        _socialMediaUsageMinutes = totalSocialMediaMinutes;
        await _sendGentleReminder();
      }
    } catch (e) {
      print('خطأ في فحص الاستخدام: $e');
    }
  }

  /// إرسال تذكير لطيف
  Future<void> _sendGentleReminder() async {
    final message = MotivationalMessages.getRandomMessage(
      MessageTrigger.socialMediaDetected,
    );

    await _notificationService.showMotivationalNotification(message);
  }

  /// الحصول على استخدام اليوم
  Future<List<AppUsageInfo>> getTodayUsage() async {
    // ملاحظة: هذه دالة نموذجية
    // في التطبيق الحقيقي، ستستخدم مكتبة app_usage أو usage_stats
    // لجلب البيانات الفعلية

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    // هنا يجب استخدام مكتبة app_usage للحصول على البيانات الفعلية
    // مثال:
    /*
    AppUsage appUsage = AppUsage();
    List<AppUsageInfo> infos = await appUsage.getAppUsage(startOfDay, now);
    return infos;
    */

    // للتوضيح، نعيد قائمة فارغة
    return [];
  }

  /// حساب إجمالي وقت الشاشة اليوم
  Future<int> getTotalScreenTimeToday() async {
    final usageToday = await getTodayUsage();
    return usageToday.fold(0, (sum, usage) => sum + usage.usageTimeMinutes);
  }

  /// حساب وقت استخدام وسائل التواصل الاجتماعي
  Future<int> getSocialMediaTimeToday() async {
    final usageToday = await getTodayUsage();
    return usageToday
        .where((usage) => socialMediaApps.contains(usage.packageName))
        .fold(0, (sum, usage) => sum + usage.usageTimeMinutes);
  }

  /// اقتراح وقت مخصص للقراءة بناءً على الاستخدام
  Future<int> getSuggestedReadingTime() async {
    final socialMediaTime = await getSocialMediaTimeToday();

    // اقتراح 20% من وقت وسائل التواصل للقراءة
    final suggestedMinutes = (socialMediaTime * 0.2).round();

    // على الأقل 10 دقائق، وحد أقصى 60 دقيقة
    return suggestedMinutes.clamp(10, 60);
  }

  /// الحصول على إحصائيات الاستخدام الأسبوعية
  Future<Map<String, int>> getWeeklyStats() async {
    final Map<String, int> stats = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dayKey = '${day.year}-${day.month}-${day.day}';

      // في التطبيق الحقيقي، احصل على البيانات من قاعدة البيانات
      stats[dayKey] = 0;
    }

    return stats;
  }

  /// إعدادات الحد الأقصى للاستخدام
  int? maxDailySocialMediaMinutes;

  /// تعيين حد أقصى للاستخدام اليومي
  void setDailyLimit(int minutes) {
    maxDailySocialMediaMinutes = minutes;
  }

  /// التحقق من تجاوز الحد الأقصى
  Future<bool> isLimitExceeded() async {
    if (maxDailySocialMediaMinutes == null) return false;

    final socialMediaTime = await getSocialMediaTimeToday();
    return socialMediaTime >= maxDailySocialMediaMinutes!;
  }

  /// الحصول على الوقت المتبقي قبل تجاوز الحد
  Future<int> getRemainingTime() async {
    if (maxDailySocialMediaMinutes == null) return -1;

    final socialMediaTime = await getSocialMediaTimeToday();
    final remaining = maxDailySocialMediaMinutes! - socialMediaTime;

    return remaining > 0 ? remaining : 0;
  }
}

/// مراقب الاستخدام في الوقت الفعلي
class UsageMonitor {
  static final UsageMonitor _instance = UsageMonitor._internal();
  factory UsageMonitor() => _instance;
  UsageMonitor._internal();

  final StreamController<int> _screenTimeController =
      StreamController<int>.broadcast();

  Stream<int> get screenTimeStream => _screenTimeController.stream;

  void updateScreenTime(int minutes) {
    _screenTimeController.add(minutes);
  }

  void dispose() {
    _screenTimeController.close();
  }
}
