import 'package:flutter/foundation.dart';
import '../models/reading_plan.dart';
import '../models/quran_data.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/motivational_messages.dart';

/// موفر حالة القراءة
class ReadingProvider with ChangeNotifier {
  final _db = DatabaseService();
  final _notificationService = NotificationService();

  ReadingPlan? _activePlan;
  UserProgress? _userProgress;
  ReadingSession? _currentSession;
  bool _isReading = false;

  ReadingPlan? get activePlan => _activePlan;
  UserProgress? get userProgress => _userProgress;
  bool get isReading => _isReading;
  ReadingSession? get currentSession => _currentSession;

  /// تحميل الخطة النشطة
  Future<void> loadActivePlan() async {
    _activePlan = await _db.getActiveReadingPlan();
    notifyListeners();
  }

  /// تحميل تقدم المستخدم
  Future<void> loadUserProgress(String userId) async {
    _userProgress = await _db.getUserProgress(userId);
    if (_userProgress == null) {
      _userProgress = UserProgress(userId: userId);
      await _db.saveUserProgress(_userProgress!);
    }
    notifyListeners();
  }

  /// إنشاء خطة جديدة
  Future<void> createPlan({
    required int numberOfDays,
    required PlanType planType,
  }) async {
    // إلغاء تنشيط الخطة الحالية
    if (_activePlan != null) {
      _activePlan!.isActive = false;
      await _db.updateReadingPlan(_activePlan!);
    }

    // إنشاء خطة جديدة
    _activePlan = ReadingPlan.create(
      startDate: DateTime.now(),
      numberOfDays: numberOfDays,
      planType: planType,
    );

    await _db.insertReadingPlan(_activePlan!);

    // تحديث تقدم المستخدم
    if (_userProgress != null) {
      _userProgress = UserProgress(
        userId: _userProgress!.userId,
        activePlanId: _activePlan!.id,
      );
      await _db.saveUserProgress(_userProgress!);
    }

    notifyListeners();

    // جدولة التذكيرات
    await _scheduleReadingReminders();
  }

  /// جدولة تذكيرات القراءة
  Future<void> _scheduleReadingReminders() async {
    // تذكيرات في أوقات مختلفة من اليوم
    await _notificationService.scheduleReadingReminders(
      hours: [9, 14, 20], // 9 صباحاً، 2 ظهراً، 8 مساءً
    );
  }

  /// بدء جلسة قراءة
  void startReadingSession() {
    _currentSession = ReadingSession(
      startTime: DateTime.now(),
      endTime: DateTime.now(), // سيتم تحديثه عند الإنهاء
      ayahsRead: 0,
      surahsRead: [],
    );
    _isReading = true;
    notifyListeners();
  }

  /// إنهاء جلسة القراءة
  Future<void> endReadingSession({
    required int ayahsRead,
    required List<int> surahsRead,
  }) async {
    if (_currentSession == null || !_isReading) return;

    _currentSession = ReadingSession(
      id: _currentSession!.id,
      startTime: _currentSession!.startTime,
      endTime: DateTime.now(),
      ayahsRead: ayahsRead,
      surahsRead: surahsRead,
    );

    // حفظ الجلسة
    if (_userProgress != null) {
      await _db.insertReadingSession(_currentSession!, _userProgress!.userId);

      // تحديث التقدم
      await _updateProgress(ayahsRead, surahsRead, _currentSession!.durationMinutes);
    }

    _isReading = false;
    notifyListeners();

    // إرسال رسالة تحفيزية
    final message = MotivationalMessages.getRandomMessage(
      MessageTrigger.afterReading,
    );
    await _notificationService.showMotivationalNotification(message);
  }

  /// تحديث التقدم
  Future<void> _updateProgress(
    int ayahsRead,
    List<int> surahsRead,
    int minutes,
  ) async {
    if (_userProgress == null) return;

    final newProgress = UserProgress(
      userId: _userProgress!.userId,
      activePlanId: _userProgress!.activePlanId,
      totalAyahsRead: _userProgress!.totalAyahsRead + ayahsRead,
      totalMinutesSpent: _userProgress!.totalMinutesSpent + minutes,
      currentStreak: _calculateStreak(),
      longestStreak: _userProgress!.longestStreak,
      lastReadDate: DateTime.now(),
      recentSessions: [
        _currentSession!,
        ..._userProgress!.recentSessions.take(9),
      ],
      completedJuzs: _userProgress!.completedJuzs,
      completedSurahs: _userProgress!.completedSurahs,
    );

    _userProgress = newProgress;
    await _db.saveUserProgress(_userProgress!);

    // التحقق من الإنجازات
    await _checkAchievements();

    notifyListeners();
  }

  /// حساب السلسلة المتتالية
  int _calculateStreak() {
    if (_userProgress == null) return 1;

    final now = DateTime.now();
    final lastRead = _userProgress!.lastReadDate;

    final difference = now.difference(lastRead).inDays;

    if (difference == 0) {
      // نفس اليوم
      return _userProgress!.currentStreak;
    } else if (difference == 1) {
      // اليوم التالي
      return _userProgress!.currentStreak + 1;
    } else {
      // انقطعت السلسلة
      return 1;
    }
  }

  /// التحقق من الإنجازات
  Future<void> _checkAchievements() async {
    if (_userProgress == null) return;

    // تحقق من السلسلة المتتالية
    if (_userProgress!.currentStreak % 7 == 0) {
      final message = MotivationalMessages.getRandomMessage(
        MessageTrigger.dailyStreak,
      );
      await _notificationService.showMotivationalNotification(message);
    }

    // تحقق من إكمال جزء
    final completedJuzCount = _userProgress!.completedJuzs.length;
    if (completedJuzCount > 0 && completedJuzCount % 5 == 0) {
      final message = MotivationalMessages.getRandomMessage(
        MessageTrigger.milestone,
      );
      await _notificationService.showMotivationalNotification(message);
    }
  }

  /// إتمام جزء
  Future<void> completeJuz(int juzNumber) async {
    if (_userProgress == null) return;

    _userProgress!.completedJuzs[juzNumber] = true;
    await _db.saveUserProgress(_userProgress!);

    notifyListeners();

    // رسالة تحفيزية
    final message = MotivationalMessages.getRandomMessage(
      MessageTrigger.completedPortion,
    );
    await _notificationService.showMotivationalNotification(message);
  }

  /// إتمام سورة
  Future<void> completeSurah(int surahNumber) async {
    if (_userProgress == null) return;

    _userProgress!.completedSurahs[surahNumber] = true;
    await _db.saveUserProgress(_userProgress!);

    notifyListeners();
  }

  /// الحصول على الجزء اليومي الحالي
  DailyPortion? getTodayPortion() {
    if (_activePlan == null) return null;

    final daysSinceStart =
        DateTime.now().difference(_activePlan!.startDate).inDays;

    if (daysSinceStart < 0 || daysSinceStart >= _activePlan!.dailyPortions.length) {
      return null;
    }

    return _activePlan!.dailyPortions[daysSinceStart];
  }

  /// التحقق من إكمال اليوم
  bool isTodayCompleted() {
    final todayPortion = getTodayPortion();
    return todayPortion?.isCompleted ?? false;
  }
}
