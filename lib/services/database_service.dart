import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/reading_plan.dart';
import '../models/dhikr.dart';

/// خدمة قاعدة البيانات المحلية
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'guran.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول خطط القراءة
    await db.execute('''
      CREATE TABLE reading_plans (
        id TEXT PRIMARY KEY,
        start_date TEXT NOT NULL,
        target_end_date TEXT NOT NULL,
        total_days INTEGER NOT NULL,
        plan_type TEXT NOT NULL,
        daily_portions TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // جدول تقدم المستخدم
    await db.execute('''
      CREATE TABLE user_progress (
        user_id TEXT PRIMARY KEY,
        active_plan_id TEXT,
        total_ayahs_read INTEGER DEFAULT 0,
        total_minutes_spent INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_read_date TEXT,
        recent_sessions TEXT,
        completed_juzs TEXT,
        completed_surahs TEXT,
        FOREIGN KEY (active_plan_id) REFERENCES reading_plans (id)
      )
    ''');

    // جدول جلسات القراءة
    await db.execute('''
      CREATE TABLE reading_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        ayahs_read INTEGER NOT NULL,
        surahs_read TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL
      )
    ''');

    // جدول تقدم الأذكار
    await db.execute('''
      CREATE TABLE dhikr_progress (
        user_id TEXT PRIMARY KEY,
        completions TEXT,
        total_dhikr_count INTEGER DEFAULT 0,
        last_dhikr_date TEXT
      )
    ''');

    // جدول الإحصائيات والمكافآت
    await db.execute('''
      CREATE TABLE reward_stats (
        user_id TEXT PRIMARY KEY,
        total_messages_received INTEGER DEFAULT 0,
        consecutive_days INTEGER DEFAULT 0,
        total_juz_completed INTEGER DEFAULT 0,
        achievement_counts TEXT
      )
    ''');

    // جدول استخدام التطبيقات
    await db.execute('''
      CREATE TABLE app_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        package_name TEXT NOT NULL,
        usage_time_minutes INTEGER NOT NULL,
        open_count INTEGER NOT NULL
      )
    ''');

    // جدول الإعدادات
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // سيتم تنفيذ الترقيات المستقبلية هنا
  }

  // ============= خطط القراءة =============

  Future<int> insertReadingPlan(ReadingPlan plan) async {
    final db = await database;
    await db.insert(
      'reading_plans',
      {
        'id': plan.id,
        'start_date': plan.startDate.toIso8601String(),
        'target_end_date': plan.targetEndDate.toIso8601String(),
        'total_days': plan.totalDays,
        'plan_type': plan.planType.toString(),
        'daily_portions': jsonEncode(plan.dailyPortions.map((p) => p.toJson()).toList()),
        'created_at': plan.createdAt.toIso8601String(),
        'is_active': plan.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return 1;
  }

  Future<ReadingPlan?> getActiveReadingPlan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_plans',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return ReadingPlan(
      id: map['id'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      targetEndDate: DateTime.parse(map['target_end_date'] as String),
      planType: PlanType.values.firstWhere(
        (e) => e.toString() == map['plan_type'],
        orElse: () => PlanType.byJuz,
      ),
      dailyPortions: (jsonDecode(map['daily_portions'] as String) as List)
          .map((p) => DailyPortion.fromJson(p))
          .toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
      isActive: map['is_active'] == 1,
    );
  }

  Future<List<ReadingPlan>> getAllReadingPlans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_plans',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return ReadingPlan(
        id: map['id'] as String,
        startDate: DateTime.parse(map['start_date'] as String),
        targetEndDate: DateTime.parse(map['target_end_date'] as String),
        planType: PlanType.values.firstWhere(
          (e) => e.toString() == map['plan_type'],
          orElse: () => PlanType.byJuz,
        ),
        dailyPortions: (jsonDecode(map['daily_portions'] as String) as List)
            .map((p) => DailyPortion.fromJson(p))
            .toList(),
        createdAt: DateTime.parse(map['created_at'] as String),
        isActive: map['is_active'] == 1,
      );
    });
  }

  Future<int> updateReadingPlan(ReadingPlan plan) async {
    final db = await database;
    return await db.update(
      'reading_plans',
      {
        'start_date': plan.startDate.toIso8601String(),
        'target_end_date': plan.targetEndDate.toIso8601String(),
        'total_days': plan.totalDays,
        'plan_type': plan.planType.toString(),
        'daily_portions': jsonEncode(plan.dailyPortions.map((p) => p.toJson()).toList()),
        'is_active': plan.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  // ============= تقدم المستخدم =============

  Future<int> saveUserProgress(UserProgress progress) async {
    final db = await database;
    await db.insert(
      'user_progress',
      {
        'user_id': progress.userId,
        'active_plan_id': progress.activePlanId,
        'total_ayahs_read': progress.totalAyahsRead,
        'total_minutes_spent': progress.totalMinutesSpent,
        'current_streak': progress.currentStreak,
        'longest_streak': progress.longestStreak,
        'last_read_date': progress.lastReadDate.toIso8601String(),
        'recent_sessions': jsonEncode(progress.recentSessions.map((s) => s.toJson()).toList()),
        'completed_juzs': jsonEncode(progress.completedJuzs),
        'completed_surahs': jsonEncode(progress.completedSurahs),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return 1;
  }

  Future<UserProgress?> getUserProgress(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return UserProgress(
      userId: map['user_id'] as String,
      activePlanId: map['active_plan_id'] as String?,
      totalAyahsRead: map['total_ayahs_read'] as int,
      totalMinutesSpent: map['total_minutes_spent'] as int,
      currentStreak: map['current_streak'] as int,
      longestStreak: map['longest_streak'] as int,
      lastReadDate: DateTime.parse(map['last_read_date'] as String),
      recentSessions: (jsonDecode(map['recent_sessions'] as String) as List)
          .map((s) => ReadingSession.fromJson(s))
          .toList(),
      completedJuzs: Map<int, bool>.from(jsonDecode(map['completed_juzs'] as String)),
      completedSurahs: Map<int, bool>.from(jsonDecode(map['completed_surahs'] as String)),
    );
  }

  // ============= جلسات القراءة =============

  Future<int> insertReadingSession(ReadingSession session, String userId) async {
    final db = await database;
    await db.insert(
      'reading_sessions',
      {
        'id': session.id,
        'user_id': userId,
        'start_time': session.startTime.toIso8601String(),
        'end_time': session.endTime.toIso8601String(),
        'ayahs_read': session.ayahsRead,
        'surahs_read': jsonEncode(session.surahsRead),
        'duration_minutes': session.durationMinutes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return 1;
  }

  // ============= تقدم الأذكار =============

  Future<int> saveDhikrProgress(DhikrProgress progress) async {
    final db = await database;
    await db.insert(
      'dhikr_progress',
      {
        'user_id': progress.userId,
        'completions': jsonEncode(progress.completions.map((k, v) => MapEntry(k, v.toJson()))),
        'total_dhikr_count': progress.totalDhikrCount,
        'last_dhikr_date': progress.lastDhikrDate.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return 1;
  }

  Future<DhikrProgress?> getDhikrProgress(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dhikr_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return DhikrProgress(
      userId: map['user_id'] as String,
      completions: (jsonDecode(map['completions'] as String) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, DhikrCompletion.fromJson(v))),
      totalDhikrCount: map['total_dhikr_count'] as int,
      lastDhikrDate: DateTime.parse(map['last_dhikr_date'] as String),
    );
  }

  // ============= الإعدادات =============

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  // ============= تنظيف =============

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
