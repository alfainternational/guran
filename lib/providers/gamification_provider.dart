import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gamification.dart';

/// مزود نظام Gamification
/// يدير النقاط، المستويات، التحديات، والإنجازات
class GamificationProvider extends ChangeNotifier {
  static const String _statsKey = 'gamification_stats';
  static const String _challengesKey = 'daily_challenges';
  static const String _lastChallengeDate = 'last_challenge_date';

  GamificationStats _stats = GamificationStats();
  List<Challenge> _dailyChallenges = [];
  List<Challenge> _weeklyChallenges = [];
  bool _isLoading = true;

  // Getters
  GamificationStats get stats => _stats;
  List<Challenge> get dailyChallenges => _dailyChallenges;
  List<Challenge> get weeklyChallenges => _weeklyChallenges;
  bool get isLoading => _isLoading;

  UserLevel get currentLevel => _stats.currentLevel;
  int get totalPoints => _stats.totalPoints;
  int get currentStreak => _stats.currentStreak;
  double get progressToNextLevel => _stats.progressToNextLevel;
  int get pointsToNextLevel => _stats.pointsToNextLevel;

  GamificationProvider() {
    _initialize();
  }

  /// تهيئة البيانات
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadStats();
    await _loadOrGenerateChallenges();

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل الإحصائيات
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        _stats = GamificationStats.fromJson(jsonDecode(statsJson));

        // التحقق من إعادة تعيين النقاط اليومية
        final now = DateTime.now();
        final lastDate = _stats.lastReadingDate;
        if (lastDate != null) {
          if (!_isSameDay(now, lastDate)) {
            // يوم جديد - إعادة تعيين النقاط اليومية
            _stats = _stats.copyWith(todayPoints: 0);

            // التحقق من السلسلة
            final daysDiff = now.difference(lastDate).inDays;
            if (daysDiff > 1) {
              // انقطعت السلسلة
              _stats = _stats.copyWith(currentStreak: 0);
            }
          }

          // التحقق من الأسبوع
          if (!_isSameWeek(now, lastDate)) {
            _stats = _stats.copyWith(weekPoints: 0);
          }

          // التحقق من الشهر
          if (now.month != lastDate.month || now.year != lastDate.year) {
            _stats = _stats.copyWith(monthPoints: 0);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading gamification stats: $e');
    }
  }

  /// حفظ الإحصائيات
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, jsonEncode(_stats.toJson()));
    } catch (e) {
      debugPrint('Error saving gamification stats: $e');
    }
  }

  /// تحميل أو توليد التحديات
  Future<void> _loadOrGenerateChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString(_lastChallengeDate);
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      if (lastDate != todayStr) {
        // يوم جديد - توليد تحديات جديدة
        _dailyChallenges = Challenge.generateDailyChallenges(today);

        // التحقق من الأسبوع
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        _weeklyChallenges = Challenge.generateWeeklyChallenges(weekStart);

        await prefs.setString(_lastChallengeDate, todayStr);
      } else {
        // تحميل التحديات المحفوظة
        final challengesJson = prefs.getString(_challengesKey);
        if (challengesJson != null) {
          final List<dynamic> saved = jsonDecode(challengesJson);
          // استعادة حالة التحديات
          _dailyChallenges = Challenge.generateDailyChallenges(today);
          for (var challenge in _dailyChallenges) {
            final savedChallenge = saved.firstWhere(
              (c) => c['id'] == challenge.id,
              orElse: () => null,
            );
            if (savedChallenge != null) {
              challenge.progress = savedChallenge['progress'] ?? 0;
              challenge.isCompleted = savedChallenge['isCompleted'] ?? false;
            }
          }
        } else {
          _dailyChallenges = Challenge.generateDailyChallenges(today);
        }

        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        _weeklyChallenges = Challenge.generateWeeklyChallenges(weekStart);
      }
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      _dailyChallenges = Challenge.generateDailyChallenges(DateTime.now());
    }
  }

  /// حفظ حالة التحديات
  Future<void> _saveChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesData =
          _dailyChallenges.map((c) => c.toJson()).toList();
      await prefs.setString(_challengesKey, jsonEncode(challengesData));
    } catch (e) {
      debugPrint('Error saving challenges: $e');
    }
  }

  /// إضافة نقاط
  Future<void> addPoints(int points, {String? reason}) async {
    final previousLevel = _stats.currentLevel;

    _stats = _stats.copyWith(
      totalPoints: _stats.totalPoints + points,
      todayPoints: _stats.todayPoints + points,
      weekPoints: _stats.weekPoints + points,
      monthPoints: _stats.monthPoints + points,
      lastReadingDate: DateTime.now(),
    );

    await _saveStats();
    notifyListeners();

    // التحقق من الترقية للمستوى التالي
    final newLevel = _stats.currentLevel;
    if (newLevel.level > previousLevel.level) {
      // تم الترقية! يمكن إضافة إشعار هنا
      debugPrint('🎉 Level Up! ${previousLevel.titleArabic} -> ${newLevel.titleArabic}');
    }
  }

  /// تسجيل قراءة
  Future<void> recordReading({
    required int ayahsRead,
    required int minutesSpent,
    int pagesRead = 0,
    bool completedJuz = false,
    bool completedSurah = false,
    bool completedKhatma = false,
  }) async {
    int earnedPoints = 0;

    // نقاط الآيات
    earnedPoints += ayahsRead * ActivityPoints.readAyah;

    // نقاط الصفحات
    if (pagesRead > 0) {
      earnedPoints += pagesRead * ActivityPoints.readPage;
    } else {
      // تقدير الصفحات من الآيات (تقريباً 15 آية = صفحة)
      earnedPoints += (ayahsRead ~/ 15) * ActivityPoints.readPage;
    }

    // نقاط إكمال الجزء
    if (completedJuz) {
      earnedPoints += ActivityPoints.completeJuz;
    }

    // نقاط إكمال السورة
    if (completedSurah) {
      earnedPoints += ActivityPoints.completeSurah;
    }

    // نقاط إكمال الختمة
    if (completedKhatma) {
      earnedPoints += ActivityPoints.completeKhatma;
      _stats = _stats.copyWith(totalKhatmat: _stats.totalKhatmat + 1);
    }

    // مضاعفات خاصة
    earnedPoints = _applyMultipliers(earnedPoints);

    // تحديث السلسلة
    await _updateStreak();

    // تحديث تقدم التحديات
    await _updateChallengeProgress(
      ayahsRead: ayahsRead,
      minutesSpent: minutesSpent,
      pagesRead: pagesRead,
      completedJuz: completedJuz,
    );

    await addPoints(earnedPoints, reason: 'reading');
  }

  /// تسجيل إكمال ذكر
  Future<void> recordDhikrCompletion({
    required bool isMorning,
    required bool isEvening,
    int dhikrCount = 1,
  }) async {
    int earnedPoints = dhikrCount * ActivityPoints.completeDhikr;

    if (isMorning) {
      earnedPoints += ActivityPoints.completeMorningAdhkar;
    }

    if (isEvening) {
      earnedPoints += ActivityPoints.completeEveningAdhkar;
    }

    if (isMorning && isEvening) {
      earnedPoints += ActivityPoints.completeAllDailyAdhkar -
          ActivityPoints.completeMorningAdhkar -
          ActivityPoints.completeEveningAdhkar;
    }

    // تحديث تحديات الأذكار
    for (var challenge in _dailyChallenges) {
      if (challenge.type == ChallengeType.dhikr && !challenge.isCompleted) {
        challenge.progress++;
        if (challenge.progress >= challenge.target) {
          challenge.isCompleted = true;
          challenge.completedAt = DateTime.now();
          earnedPoints += challenge.points;
          _stats = _stats.copyWith(
            completedChallenges: _stats.completedChallenges + 1,
          );
        }
      }
    }

    await _saveChallenges();
    await addPoints(earnedPoints, reason: 'dhikr');
  }

  /// تحديث السلسلة
  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final lastDate = _stats.lastReadingDate;

    if (lastDate == null) {
      // أول قراءة
      _stats = _stats.copyWith(
        currentStreak: 1,
        longestStreak: 1,
      );
    } else if (_isSameDay(now, lastDate)) {
      // نفس اليوم - لا تغيير
    } else if (_isYesterday(now, lastDate)) {
      // يوم متتالي
      final newStreak = _stats.currentStreak + 1;
      _stats = _stats.copyWith(
        currentStreak: newStreak,
        longestStreak:
            newStreak > _stats.longestStreak ? newStreak : _stats.longestStreak,
      );

      // مكافأة السلسلة اليومية
      await addPoints(ActivityPoints.dailyStreak, reason: 'streak');

      // مكافأة الأسبوع
      if (newStreak % 7 == 0) {
        await addPoints(ActivityPoints.weeklyBonus, reason: 'weekly_streak');
      }

      // مكافأة الشهر
      if (newStreak % 30 == 0) {
        await addPoints(ActivityPoints.monthlyBonus, reason: 'monthly_streak');
      }
    } else {
      // انقطعت السلسلة
      _stats = _stats.copyWith(currentStreak: 1);
    }
  }

  /// تحديث تقدم التحديات
  Future<void> _updateChallengeProgress({
    int ayahsRead = 0,
    int minutesSpent = 0,
    int pagesRead = 0,
    bool completedJuz = false,
  }) async {
    for (var challenge in _dailyChallenges) {
      if (challenge.isCompleted) continue;

      switch (challenge.type) {
        case ChallengeType.reading:
          if (pagesRead > 0) {
            challenge.progress += pagesRead;
          } else {
            challenge.progress += (ayahsRead / 15).ceil();
          }
          break;
        case ChallengeType.time:
          challenge.progress += minutesSpent;
          break;
        case ChallengeType.streak:
          challenge.progress = _stats.currentStreak;
          break;
        default:
          break;
      }

      if (challenge.progress >= challenge.target) {
        challenge.isCompleted = true;
        challenge.completedAt = DateTime.now();
        await addPoints(challenge.points, reason: 'challenge_${challenge.id}');
        _stats = _stats.copyWith(
          completedChallenges: _stats.completedChallenges + 1,
        );
      }
    }

    // تحديث التحديات الأسبوعية
    for (var challenge in _weeklyChallenges) {
      if (challenge.isCompleted) continue;

      if (challenge.type == ChallengeType.reading && completedJuz) {
        challenge.progress++;
      } else if (challenge.type == ChallengeType.streak) {
        challenge.progress = _stats.currentStreak;
      }

      if (challenge.progress >= challenge.target) {
        challenge.isCompleted = true;
        challenge.completedAt = DateTime.now();
        await addPoints(challenge.points, reason: 'weekly_${challenge.id}');
      }
    }

    await _saveChallenges();
    notifyListeners();
  }

  /// تطبيق المضاعفات الخاصة
  int _applyMultipliers(int points) {
    final now = DateTime.now();
    double multiplier = 1.0;

    // مضاعف يوم الجمعة
    if (now.weekday == DateTime.friday) {
      multiplier *= ActivityPoints.fridayMultiplier;
    }

    // يمكن إضافة مضاعفات رمضان وغيرها لاحقاً

    return (points * multiplier).round();
  }

  /// التحقق من نفس اليوم
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// التحقق من الأمس
  bool _isYesterday(DateTime now, DateTime other) {
    final yesterday = now.subtract(const Duration(days: 1));
    return _isSameDay(yesterday, other);
  }

  /// التحقق من نفس الأسبوع
  bool _isSameWeek(DateTime a, DateTime b) {
    final aWeekStart = a.subtract(Duration(days: a.weekday - 1));
    final bWeekStart = b.subtract(Duration(days: b.weekday - 1));
    return _isSameDay(aWeekStart, bWeekStart);
  }

  /// الحصول على التحديات المكتملة اليوم
  List<Challenge> get completedDailyChallenges =>
      _dailyChallenges.where((c) => c.isCompleted).toList();

  /// الحصول على التحديات غير المكتملة
  List<Challenge> get pendingDailyChallenges =>
      _dailyChallenges.where((c) => !c.isCompleted).toList();

  /// نسبة إكمال التحديات اليومية
  double get dailyChallengesProgress {
    if (_dailyChallenges.isEmpty) return 0.0;
    return completedDailyChallenges.length / _dailyChallenges.length;
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await _initialize();
  }
}
