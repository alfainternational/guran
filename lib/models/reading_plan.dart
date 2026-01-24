import 'package:uuid/uuid.dart';

/// خطة ختم القرآن
class ReadingPlan {
  final String id;
  final DateTime startDate;
  final DateTime targetEndDate;
  final int totalDays;
  final PlanType planType;
  final List<DailyPortion> dailyPortions;
  final DateTime createdAt;
  bool isActive;

  ReadingPlan({
    String? id,
    required this.startDate,
    required this.targetEndDate,
    required this.planType,
    required this.dailyPortions,
    DateTime? createdAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        totalDays = targetEndDate.difference(startDate).inDays + 1,
        createdAt = createdAt ?? DateTime.now();

  /// إنشاء خطة جديدة بناءً على عدد الأيام
  factory ReadingPlan.create({
    required DateTime startDate,
    required int numberOfDays,
    PlanType planType = PlanType.byJuz,
  }) {
    final endDate = startDate.add(Duration(days: numberOfDays - 1));
    final portions = _calculateDailyPortions(
      numberOfDays: numberOfDays,
      planType: planType,
    );

    return ReadingPlan(
      startDate: startDate,
      targetEndDate: endDate,
      planType: planType,
      dailyPortions: portions,
    );
  }

  /// حساب الأجزاء اليومية
  static List<DailyPortion> _calculateDailyPortions({
    required int numberOfDays,
    required PlanType planType,
  }) {
    final List<DailyPortion> portions = [];

    if (planType == PlanType.byJuz) {
      // تقسيم 30 جزء على عدد الأيام
      final double juzPerDay = 30.0 / numberOfDays;

      for (int day = 0; day < numberOfDays; day++) {
        final startJuz = (day * juzPerDay) + 1;
        final endJuz = ((day + 1) * juzPerDay);

        portions.add(DailyPortion(
          dayNumber: day + 1,
          startJuz: startJuz.floor(),
          endJuz: endJuz.ceil(),
          estimatedMinutes: _estimateReadingTime(juzPerDay),
        ));
      }
    } else if (planType == PlanType.bySurah) {
      // تقسيم 114 سورة على عدد الأيام
      final double surahsPerDay = 114.0 / numberOfDays;

      for (int day = 0; day < numberOfDays; day++) {
        final startSurah = (day * surahsPerDay).floor() + 1;
        final endSurah = ((day + 1) * surahsPerDay).ceil();

        portions.add(DailyPortion(
          dayNumber: day + 1,
          startSurah: startSurah,
          endSurah: endSurah > 114 ? 114 : endSurah,
          estimatedMinutes: _estimateReadingTime(surahsPerDay / 4),
        ));
      }
    }

    return portions;
  }

  /// تقدير وقت القراءة بالدقائق (متوسط 20 دقيقة لكل جزء)
  static int _estimateReadingTime(double portions) {
    return (portions * 20).ceil();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'targetEndDate': targetEndDate.toIso8601String(),
      'totalDays': totalDays,
      'planType': planType.toString(),
      'dailyPortions': dailyPortions.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      targetEndDate: DateTime.parse(json['targetEndDate'] as String),
      planType: PlanType.values.firstWhere(
        (e) => e.toString() == json['planType'],
        orElse: () => PlanType.byJuz,
      ),
      dailyPortions: (json['dailyPortions'] as List)
          .map((p) => DailyPortion.fromJson(p))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// الجزء اليومي من القراءة
class DailyPortion {
  final int dayNumber;
  final int? startJuz;
  final int? endJuz;
  final int? startSurah;
  final int? endSurah;
  final int estimatedMinutes;
  bool isCompleted;
  DateTime? completedAt;

  DailyPortion({
    required this.dayNumber,
    this.startJuz,
    this.endJuz,
    this.startSurah,
    this.endSurah,
    required this.estimatedMinutes,
    this.isCompleted = false,
    this.completedAt,
  });

  void markCompleted() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'startJuz': startJuz,
      'endJuz': endJuz,
      'startSurah': startSurah,
      'endSurah': endSurah,
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DailyPortion.fromJson(Map<String, dynamic> json) {
    return DailyPortion(
      dayNumber: json['dayNumber'] as int,
      startJuz: json['startJuz'] as int?,
      endJuz: json['endJuz'] as int?,
      startSurah: json['startSurah'] as int?,
      endSurah: json['endSurah'] as int?,
      estimatedMinutes: json['estimatedMinutes'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// نوع خطة القراءة
enum PlanType {
  byJuz, // بالأجزاء
  bySurah, // بالسور
  custom, // مخصص
}

/// تقدم المستخدم في القراءة
class UserProgress {
  final String userId;
  final String? activePlanId;
  final int totalAyahsRead;
  final int totalMinutesSpent;
  final int currentStreak; // عدد الأيام المتتالية
  final int longestStreak;
  final DateTime lastReadDate;
  final List<ReadingSession> recentSessions;
  final Map<int, bool> completedJuzs; // الأجزاء المكتملة
  final Map<int, bool> completedSurahs; // السور المكتملة

  UserProgress({
    required this.userId,
    this.activePlanId,
    this.totalAyahsRead = 0,
    this.totalMinutesSpent = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastReadDate,
    List<ReadingSession>? recentSessions,
    Map<int, bool>? completedJuzs,
    Map<int, bool>? completedSurahs,
  })  : lastReadDate = lastReadDate ?? DateTime.now(),
        recentSessions = recentSessions ?? [],
        completedJuzs = completedJuzs ?? {},
        completedSurahs = completedSurahs ?? {};

  double get completionPercentage {
    return (completedJuzs.length / 30.0) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'activePlanId': activePlanId,
      'totalAyahsRead': totalAyahsRead,
      'totalMinutesSpent': totalMinutesSpent,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReadDate': lastReadDate.toIso8601String(),
      'recentSessions': recentSessions.map((s) => s.toJson()).toList(),
      'completedJuzs': completedJuzs,
      'completedSurahs': completedSurahs,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as String,
      activePlanId: json['activePlanId'] as String?,
      totalAyahsRead: json['totalAyahsRead'] as int? ?? 0,
      totalMinutesSpent: json['totalMinutesSpent'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastReadDate: DateTime.parse(json['lastReadDate'] as String),
      recentSessions: (json['recentSessions'] as List?)
              ?.map((s) => ReadingSession.fromJson(s))
              .toList() ??
          [],
      completedJuzs: Map<int, bool>.from(json['completedJuzs'] ?? {}),
      completedSurahs: Map<int, bool>.from(json['completedSurahs'] ?? {}),
    );
  }
}

/// جلسة قراءة واحدة
class ReadingSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int ayahsRead;
  final List<int> surahsRead;
  final int durationMinutes;

  ReadingSession({
    String? id,
    required this.startTime,
    required this.endTime,
    required this.ayahsRead,
    required this.surahsRead,
  })  : id = id ?? const Uuid().v4(),
        durationMinutes = endTime.difference(startTime).inMinutes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'ayahsRead': ayahsRead,
      'surahsRead': surahsRead,
      'durationMinutes': durationMinutes,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      ayahsRead: json['ayahsRead'] as int,
      surahsRead: List<int>.from(json['surahsRead'] ?? []),
    );
  }
}
