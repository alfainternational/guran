import 'package:flutter/foundation.dart';
import '../models/reading_plan.dart';
import '../models/user_profile.dart'; // Ensure this exists
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
  final Set<String> _validatedAyahReads = {};
  int? _temporaryStopSurah;
  int? _temporaryStopAyah;
  final Set<String> _manualStopMarkers = {};
  final Set<String> _completedDailySessions = {};

  ReadingPlan? get activePlan => _activePlan;
  UserProgress? get userProgress => _userProgress;
  bool get isReading => _isReading;
  ReadingSession? get currentSession => _currentSession;
  int get validatedAyahReadsCount => _validatedAyahReads.length;
  int? get temporaryStopSurah => _temporaryStopSurah;
  int? get temporaryStopAyah => _temporaryStopAyah;

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
    DateTime? startDate,
    int? targetDailyMinutes,
    int sessionsPerDay = 1,
  }) async {
    // إلغاء تنشيط الخطة الحالية
    if (_activePlan != null) {
      _activePlan!.isActive = false;
      await _db.updateReadingPlan(_activePlan!);
    }

    // إنشاء خطة جديدة
    _activePlan = ReadingPlan.create(
      startDate: startDate ?? DateTime.now(),
      numberOfDays: numberOfDays,
      planType: planType,
      targetDailyMinutes: targetDailyMinutes,
      sessionsPerDay: sessionsPerDay,
    );

    await _db.saveReadingPlan(_activePlan!);

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
    _validatedAyahReads.clear();
    notifyListeners();
  }

  /// إنهاء جلسة القراءة
  Future<void> endReadingSession({
    required int ayahsRead,
    required List<int> surahsRead,
    bool enforceQualityCheck = true,
  }) async {
    if (_currentSession == null || !_isReading) return;

    if (enforceQualityCheck) {
      final issue = validateSessionQuality(ayahsRead: ayahsRead);
      if (issue != null) {
        throw StateError(issue);
      }
    }

    _currentSession = ReadingSession(
      id: _currentSession!.id,
      startTime: _currentSession!.startTime,
      endTime: DateTime.now(),
      ayahsRead: ayahsRead,
      surahsRead: surahsRead,
    );

    // حفظ الجلسة
    if (_userProgress != null) {
      // I need to check if saveReadingSession exists or was renamed
      await _db.insertReadingSession(_currentSession!, _userProgress!.userId);

      // تحديث التقدم
      await _updateProgress(
          ayahsRead, surahsRead, _currentSession!.durationMinutes);
    }

    _isReading = false;
    _validatedAyahReads.clear();
    notifyListeners();

    // إرسال رسالة تحفيزية
    final message = MotivationalMessages.getRandomMessage(
      MessageTrigger.afterReading,
    );
    await _notificationService.showMotivationalNotification(message);
  }

  /// تسجيل آية مقروءة بزمن منطقي داخل الجلسة النشطة.
  void recordValidatedAyahRead({
    required int surahNumber,
    required int ayahNumber,
    required int dwellSeconds,
  }) {
    if (!_isReading) return;
    if (dwellSeconds < 4) return;

    final key = '$surahNumber:$ayahNumber';
    if (_validatedAyahReads.add(key)) {
      notifyListeners();
    }
  }

  /// حفظ علامة توقف مؤقتة (آخر موضع قراءة موثّق).
  void setTemporaryStopMarker({
    required int surahNumber,
    required int ayahNumber,
  }) {
    _temporaryStopSurah = surahNumber;
    _temporaryStopAyah = ayahNumber;
    notifyListeners();
  }

  /// إضافة/إزالة علامة توقف يدوية على آية.
  void toggleManualStopMarker({
    required int surahNumber,
    required int ayahNumber,
  }) {
    final key = '$surahNumber:$ayahNumber';
    if (_manualStopMarkers.contains(key)) {
      _manualStopMarkers.remove(key);
    } else {
      _manualStopMarkers.add(key);
    }
    notifyListeners();
  }

  bool isManualStopMarker({
    required int surahNumber,
    required int ayahNumber,
  }) {
    return _manualStopMarkers.contains('$surahNumber:$ayahNumber');
  }

  /// جلسات الورد اليومية (بعد التقسيم).
  List<int> getTodaySessionMinutes() {
    final portion = getTodayPortion();
    if (portion == null) return const [];
    return portion.sessionMinutes;
  }

  bool isDailySessionCompleted(int dayNumber, int sessionIndex) {
    if (_activePlan == null) return false;
    final key = '${_activePlan!.id}:$dayNumber:$sessionIndex';
    return _completedDailySessions.contains(key);
  }

  void toggleDailySessionCompletion(int dayNumber, int sessionIndex) {
    if (_activePlan == null) return;
    final key = '${_activePlan!.id}:$dayNumber:$sessionIndex';
    if (_completedDailySessions.contains(key)) {
      _completedDailySessions.remove(key);
    } else {
      _completedDailySessions.add(key);
    }
    notifyListeners();
  }

  /// التحقق من جودة الجلسة حتى لا تُحسب القراءة السريعة جدًا كإنجاز مكتمل
  String? validateSessionQuality({required int ayahsRead}) {
    if (_currentSession == null) return 'لا توجد جلسة قراءة نشطة';
    if (ayahsRead <= 0) return 'أدخل عدد آيات صحيح';

    final elapsedSeconds =
        DateTime.now().difference(_currentSession!.startTime).inSeconds;
    final minRequiredSeconds = (ayahsRead * 5).clamp(60, 3600);

    if (elapsedSeconds < minRequiredSeconds) {
      return 'مدة الجلسة قصيرة جدًا مقارنة بعدد الآيات. '
          'الحد الأدنى المقترح: ${minRequiredSeconds ~/ 60} دقيقة.';
    }
    return null;
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

    final profile = await _db.getUserProfile();
    if (profile == null) return;

    final currentMedals = List<String>.from(profile.unlockedMedalIds);
    bool hasUpdates = false;

    // دالة مساعدة لإضافة الوسام
    void unlock(String id) {
      if (!currentMedals.contains(id)) {
        currentMedals.add(id);
        hasUpdates = true;
        _notificationService
            .showAchievementNotification('مبروك! لقد حصلت على وسام جديد!');
      }
    }

    // 1. السلسلة المتتالية
    if (_userProgress!.currentStreak >= 3) unlock('streak_3');
    if (_userProgress!.currentStreak >= 7) unlock('streak_7');

    // 2. إكمال أجزاء
    final completedCount = _userProgress!.completedJuzs.length;
    if (completedCount >= 1) unlock('first_juz');
    if (completedCount >= 15) unlock('half_quran');
    if (completedCount >= 30) unlock('complete_quran');

    if (hasUpdates) {
      final newProfile = UserProfile(
        name: profile.name,
        age: profile.age,
        gender: profile.gender,
        joinedDate: profile.joinedDate,
        lastOpenDate: profile.lastOpenDate,
        consecutiveDays: profile.consecutiveDays,
        unlockedMedalIds: currentMedals,
      );
      await _db.saveUserProfile(newProfile);
      notifyListeners();
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

    if (daysSinceStart < 0 ||
        daysSinceStart >= _activePlan!.dailyPortions.length) {
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
