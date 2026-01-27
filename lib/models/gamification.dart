import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ===============================================
/// نظام النقاط - Activity Points
/// ===============================================
class ActivityPoints {
  ActivityPoints._();

  // نقاط القراءة
  static const int readAyah = 1;
  static const int readPage = 10;
  static const int readHizb = 50;
  static const int completeJuz = 150;
  static const int completeSurah = 75;
  static const int completeKhatma = 10000;

  // نقاط الأذكار
  static const int completeDhikr = 5;
  static const int completeMorningAdhkar = 50;
  static const int completeEveningAdhkar = 50;
  static const int completeAllDailyAdhkar = 120;

  // نقاط الانتظام
  static const int dailyStreak = 30;
  static const int weeklyBonus = 250;
  static const int monthlyBonus = 1500;

  // نقاط إضافية
  static const int firstTimeBonus = 100;
  static const int earlyMorningReading = 20; // قراءة قبل الفجر
  static const int nightReading = 15; // قراءة بعد العشاء
  static const int consistentTime = 10; // القراءة في نفس الوقت يومياً

  // مضاعفات
  static const double ramadanMultiplier = 2.0;
  static const double fridayMultiplier = 1.5;
  static const double lastTenNightsMultiplier = 3.0;
}

/// ===============================================
/// المستويات - User Levels
/// ===============================================
class UserLevel {
  final int level;
  final String id;
  final String titleArabic;
  final String titleEnglish;
  final String description;
  final int minPoints;
  final int maxPoints;
  final Color color;
  final IconData icon;
  final String badge;

  const UserLevel({
    required this.level,
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.description,
    required this.minPoints,
    required this.maxPoints,
    required this.color,
    required this.icon,
    required this.badge,
  });

  /// جميع المستويات المتاحة
  static const List<UserLevel> allLevels = [
    UserLevel(
      level: 1,
      id: 'beginner',
      titleArabic: 'قارئ مبتدئ',
      titleEnglish: 'Beginner',
      description: 'بداية رحلتك مع القرآن الكريم',
      minPoints: 0,
      maxPoints: 500,
      color: Color(0xFF90A4AE),
      icon: Icons.eco_rounded,
      badge: '🌱',
    ),
    UserLevel(
      level: 2,
      id: 'learner',
      titleArabic: 'متعلم',
      titleEnglish: 'Learner',
      description: 'بدأت تتعلم وتنمو',
      minPoints: 500,
      maxPoints: 1500,
      color: Color(0xFF66BB6A),
      icon: Icons.spa_rounded,
      badge: '🌿',
    ),
    UserLevel(
      level: 3,
      id: 'regular',
      titleArabic: 'قارئ منتظم',
      titleEnglish: 'Regular Reader',
      description: 'أصبحت القراءة جزءاً من يومك',
      minPoints: 1500,
      maxPoints: 3500,
      color: Color(0xFF42A5F5),
      icon: Icons.auto_awesome_rounded,
      badge: '⭐',
    ),
    UserLevel(
      level: 4,
      id: 'committed',
      titleArabic: 'ملتزم',
      titleEnglish: 'Committed',
      description: 'التزامك يلهم الآخرين',
      minPoints: 3500,
      maxPoints: 7000,
      color: Color(0xFFAB47BC),
      icon: Icons.star_rounded,
      badge: '🌟',
    ),
    UserLevel(
      level: 5,
      id: 'advanced',
      titleArabic: 'متقدم',
      titleEnglish: 'Advanced',
      description: 'وصلت لمستوى متقدم من الالتزام',
      minPoints: 7000,
      maxPoints: 15000,
      color: Color(0xFFFFB300),
      icon: Icons.emoji_events_rounded,
      badge: '🏆',
    ),
    UserLevel(
      level: 6,
      id: 'expert',
      titleArabic: 'خبير',
      titleEnglish: 'Expert',
      description: 'أنت قدوة في القراءة والالتزام',
      minPoints: 15000,
      maxPoints: 30000,
      color: Color(0xFFFF7043),
      icon: Icons.military_tech_rounded,
      badge: '🎖️',
    ),
    UserLevel(
      level: 7,
      id: 'master',
      titleArabic: 'سفير القرآن',
      titleEnglish: 'Quran Ambassador',
      description: 'أنت سفير للقرآن الكريم',
      minPoints: 30000,
      maxPoints: 60000,
      color: Color(0xFFE91E63),
      icon: Icons.workspace_premium_rounded,
      badge: '👑',
    ),
    UserLevel(
      level: 8,
      id: 'legend',
      titleArabic: 'أسطورة',
      titleEnglish: 'Legend',
      description: 'مستوى أسطوري من الإنجاز',
      minPoints: 60000,
      maxPoints: 999999999,
      color: Color(0xFFD4AF37),
      icon: Icons.diamond_rounded,
      badge: '💎',
    ),
  ];

  /// الحصول على المستوى حسب النقاط
  static UserLevel getLevelForPoints(int points) {
    for (var level in allLevels.reversed) {
      if (points >= level.minPoints) {
        return level;
      }
    }
    return allLevels.first;
  }

  /// الحصول على المستوى التالي
  static UserLevel? getNextLevel(int points) {
    final currentLevel = getLevelForPoints(points);
    final currentIndex = allLevels.indexOf(currentLevel);
    if (currentIndex < allLevels.length - 1) {
      return allLevels[currentIndex + 1];
    }
    return null;
  }

  /// حساب نسبة التقدم نحو المستوى التالي
  static double getProgressToNextLevel(int points) {
    final currentLevel = getLevelForPoints(points);
    final levelIndex = allLevels.indexOf(currentLevel);

    if (levelIndex == allLevels.length - 1) {
      return 1.0;
    }

    final nextLevel = allLevels[levelIndex + 1];
    final pointsInLevel = points - currentLevel.minPoints;
    final levelRange = nextLevel.minPoints - currentLevel.minPoints;

    return (pointsInLevel / levelRange).clamp(0.0, 1.0);
  }

  /// النقاط المتبقية للمستوى التالي
  static int getPointsToNextLevel(int points) {
    final currentLevel = getLevelForPoints(points);
    final levelIndex = allLevels.indexOf(currentLevel);

    if (levelIndex == allLevels.length - 1) {
      return 0;
    }

    final nextLevel = allLevels[levelIndex + 1];
    return nextLevel.minPoints - points;
  }
}

/// ===============================================
/// التحديات - Challenges
/// ===============================================
enum ChallengeType {
  reading, // قراءة
  dhikr, // أذكار
  time, // وقت
  streak, // سلسلة
  special, // خاص
}

enum ChallengeDifficulty {
  easy, // سهل
  medium, // متوسط
  hard, // صعب
  epic, // ملحمي
}

class Challenge {
  final String id;
  final String titleArabic;
  final String descriptionArabic;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int target;
  final int points;
  final IconData icon;
  final Color color;
  final Duration? duration; // مدة التحدي (للتحديات المؤقتة)

  int progress;
  bool isCompleted;
  DateTime? completedAt;

  Challenge({
    required this.id,
    required this.titleArabic,
    required this.descriptionArabic,
    required this.type,
    required this.difficulty,
    required this.target,
    required this.points,
    required this.icon,
    required this.color,
    this.duration,
    this.progress = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);

  String get difficultyArabic {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'سهل';
      case ChallengeDifficulty.medium:
        return 'متوسط';
      case ChallengeDifficulty.hard:
        return 'صعب';
      case ChallengeDifficulty.epic:
        return 'ملحمي';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return AppColors.success;
      case ChallengeDifficulty.medium:
        return AppColors.warning;
      case ChallengeDifficulty.hard:
        return AppColors.error;
      case ChallengeDifficulty.epic:
        return AppColors.levelLegendary;
    }
  }

  /// التحديات اليومية
  static List<Challenge> generateDailyChallenges(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = seed % 10;

    List<Challenge> challenges = [
      // تحدي ثابت - القراءة اليومية
      Challenge(
        id: 'daily_read_${date.toIso8601String()}',
        titleArabic: 'القارئ النشيط',
        descriptionArabic: 'اقرأ صفحة واحدة على الأقل',
        type: ChallengeType.reading,
        difficulty: ChallengeDifficulty.easy,
        target: 1,
        points: 25,
        icon: Icons.menu_book_rounded,
        color: AppColors.primaryGreen,
        duration: const Duration(days: 1),
      ),

      // تحدي ثابت - الأذكار
      Challenge(
        id: 'daily_dhikr_${date.toIso8601String()}',
        titleArabic: 'المسبّح',
        descriptionArabic: 'أكمل أذكار الصباح أو المساء',
        type: ChallengeType.dhikr,
        difficulty: ChallengeDifficulty.easy,
        target: 1,
        points: 20,
        icon: Icons.format_quote_rounded,
        color: AppColors.eveningColor,
        duration: const Duration(days: 1),
      ),
    ];

    // تحدي متغير بناءً على اليوم
    if (random < 3) {
      challenges.add(Challenge(
        id: 'daily_time_${date.toIso8601String()}',
        titleArabic: 'القارئ المتفاني',
        descriptionArabic: 'اقرأ لمدة 15 دقيقة متواصلة',
        type: ChallengeType.time,
        difficulty: ChallengeDifficulty.medium,
        target: 15,
        points: 40,
        icon: Icons.timer_rounded,
        color: AppColors.warning,
        duration: const Duration(days: 1),
      ));
    } else if (random < 6) {
      challenges.add(Challenge(
        id: 'daily_pages_${date.toIso8601String()}',
        titleArabic: 'القارئ المجتهد',
        descriptionArabic: 'اقرأ 3 صفحات اليوم',
        type: ChallengeType.reading,
        difficulty: ChallengeDifficulty.medium,
        target: 3,
        points: 50,
        icon: Icons.auto_stories_rounded,
        color: AppColors.primaryGreenLight,
        duration: const Duration(days: 1),
      ));
    } else {
      challenges.add(Challenge(
        id: 'daily_both_${date.toIso8601String()}',
        titleArabic: 'المتكامل',
        descriptionArabic: 'أكمل أذكار الصباح والمساء معاً',
        type: ChallengeType.dhikr,
        difficulty: ChallengeDifficulty.medium,
        target: 2,
        points: 45,
        icon: Icons.wb_twilight_rounded,
        color: AppColors.morningColor,
        duration: const Duration(days: 1),
      ));
    }

    return challenges;
  }

  /// التحديات الأسبوعية
  static List<Challenge> generateWeeklyChallenges(DateTime weekStart) {
    return [
      Challenge(
        id: 'weekly_juz_${weekStart.toIso8601String()}',
        titleArabic: 'ختام الجزء',
        descriptionArabic: 'أكمل جزءاً كاملاً هذا الأسبوع',
        type: ChallengeType.reading,
        difficulty: ChallengeDifficulty.hard,
        target: 1,
        points: 200,
        icon: Icons.bookmark_rounded,
        color: AppColors.gold,
        duration: const Duration(days: 7),
      ),
      Challenge(
        id: 'weekly_streak_${weekStart.toIso8601String()}',
        titleArabic: 'أسبوع ذهبي',
        descriptionArabic: 'اقرأ كل يوم لمدة 7 أيام متتالية',
        type: ChallengeType.streak,
        difficulty: ChallengeDifficulty.hard,
        target: 7,
        points: 300,
        icon: Icons.local_fire_department_rounded,
        color: AppColors.streakFire,
        duration: const Duration(days: 7),
      ),
      Challenge(
        id: 'weekly_adhkar_${weekStart.toIso8601String()}',
        titleArabic: 'الذاكر المنتظم',
        descriptionArabic: 'أكمل أذكار الصباح والمساء 5 أيام',
        type: ChallengeType.dhikr,
        difficulty: ChallengeDifficulty.medium,
        target: 10,
        points: 150,
        icon: Icons.repeat_rounded,
        color: AppColors.info,
        duration: const Duration(days: 7),
      ),
    ];
  }

  /// تحديات الإنجاز (لمرة واحدة)
  static List<Challenge> achievementChallenges = [
    Challenge(
      id: 'achievement_first_khatma',
      titleArabic: 'الختمة الأولى',
      descriptionArabic: 'أكمل ختمة كاملة للقرآن',
      type: ChallengeType.reading,
      difficulty: ChallengeDifficulty.epic,
      target: 1,
      points: 10000,
      icon: Icons.emoji_events_rounded,
      color: AppColors.gold,
    ),
    Challenge(
      id: 'achievement_30_days',
      titleArabic: 'شهر من الالتزام',
      descriptionArabic: '30 يوماً متتالياً من القراءة',
      type: ChallengeType.streak,
      difficulty: ChallengeDifficulty.epic,
      target: 30,
      points: 2000,
      icon: Icons.calendar_month_rounded,
      color: AppColors.levelGold,
    ),
    Challenge(
      id: 'achievement_100_days',
      titleArabic: '100 يوم',
      descriptionArabic: '100 يوم متتالي من القراءة',
      type: ChallengeType.streak,
      difficulty: ChallengeDifficulty.epic,
      target: 100,
      points: 10000,
      icon: Icons.military_tech_rounded,
      color: AppColors.levelDiamond,
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// ===============================================
/// إحصائيات Gamification
/// ===============================================
class GamificationStats {
  final int totalPoints;
  final int todayPoints;
  final int weekPoints;
  final int monthPoints;
  final int currentStreak;
  final int longestStreak;
  final int completedChallenges;
  final int totalKhatmat;
  final DateTime? lastReadingDate;
  final Map<String, bool> unlockedAchievements;

  GamificationStats({
    this.totalPoints = 0,
    this.todayPoints = 0,
    this.weekPoints = 0,
    this.monthPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedChallenges = 0,
    this.totalKhatmat = 0,
    this.lastReadingDate,
    Map<String, bool>? unlockedAchievements,
  }) : unlockedAchievements = unlockedAchievements ?? {};

  UserLevel get currentLevel => UserLevel.getLevelForPoints(totalPoints);

  double get progressToNextLevel =>
      UserLevel.getProgressToNextLevel(totalPoints);

  int get pointsToNextLevel => UserLevel.getPointsToNextLevel(totalPoints);

  GamificationStats copyWith({
    int? totalPoints,
    int? todayPoints,
    int? weekPoints,
    int? monthPoints,
    int? currentStreak,
    int? longestStreak,
    int? completedChallenges,
    int? totalKhatmat,
    DateTime? lastReadingDate,
    Map<String, bool>? unlockedAchievements,
  }) {
    return GamificationStats(
      totalPoints: totalPoints ?? this.totalPoints,
      todayPoints: todayPoints ?? this.todayPoints,
      weekPoints: weekPoints ?? this.weekPoints,
      monthPoints: monthPoints ?? this.monthPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      totalKhatmat: totalKhatmat ?? this.totalKhatmat,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'todayPoints': todayPoints,
      'weekPoints': weekPoints,
      'monthPoints': monthPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completedChallenges': completedChallenges,
      'totalKhatmat': totalKhatmat,
      'lastReadingDate': lastReadingDate?.toIso8601String(),
      'unlockedAchievements': unlockedAchievements,
    };
  }

  factory GamificationStats.fromJson(Map<String, dynamic> json) {
    return GamificationStats(
      totalPoints: json['totalPoints'] as int? ?? 0,
      todayPoints: json['todayPoints'] as int? ?? 0,
      weekPoints: json['weekPoints'] as int? ?? 0,
      monthPoints: json['monthPoints'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      completedChallenges: json['completedChallenges'] as int? ?? 0,
      totalKhatmat: json['totalKhatmat'] as int? ?? 0,
      lastReadingDate: json['lastReadingDate'] != null
          ? DateTime.parse(json['lastReadingDate'] as String)
          : null,
      unlockedAchievements:
          Map<String, bool>.from(json['unlockedAchievements'] ?? {}),
    );
  }
}
