import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/reading_plan.dart';
import '../models/dhikr.dart';
import '../models/user_profile.dart';
import '../models/bookmark.dart';

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
    String path;
    if (kIsWeb) {
      path = 'guran.db';
    } else {
      final databasePath = await getDatabasesPath();
      path = join(databasePath, 'guran.db');
    }

    return await openDatabase(
      path,
      version: 6,
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
        badges TEXT
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

    // جدول الأذكار المخصصة
    await db.execute('''
      CREATE TABLE custom_adhkar (
        id TEXT PRIMARY KEY,
        arabicText TEXT NOT NULL,
        transliteration TEXT,
        translation TEXT,
        repetitions INTEGER,
        category TEXT NOT NULL,
        timeOfDay TEXT,
        audioPath TEXT,
        reference TEXT,
        isCustom INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // جدول الملف الشخصي
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        joinedDate TEXT NOT NULL,
        lastOpenDate TEXT NOT NULL,
        consecutiveDays INTEGER NOT NULL DEFAULT 1,
        unlockedMedalIds TEXT
      )
    ''');

    // جدول العلامات المرجعية
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        page INTEGER,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // جدول آخر موقع قراءة
    await db.execute('''
      CREATE TABLE last_read_position (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        page INTEGER,
        updated_at TEXT NOT NULL
      )
    ''');

    // جدول إعدادات التنبيهات
    await db.execute('''
      CREATE TABLE notification_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        reminder_times TEXT,
        extra_settings TEXT
      )
    ''');

    // جدول إعدادات مواقيت الصلاة
    await db.execute('''
      CREATE TABLE prayer_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_name TEXT NOT NULL UNIQUE,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        minutes_before INTEGER NOT NULL DEFAULT 15
      )
    ''');

    // جدول تتبع الأذكار المخصصة
    await db.execute('''
      CREATE TABLE dhikr_trackers (
        id TEXT PRIMARY KEY,
        dhikr_id TEXT NOT NULL,
        dhikr_name TEXT NOT NULL,
        target_count INTEGER NOT NULL,
        current_count INTEGER NOT NULL DEFAULT 0,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        reminder_interval INTEGER NOT NULL DEFAULT 30,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE custom_adhkar (
          id TEXT PRIMARY KEY,
          arabicText TEXT NOT NULL,
          transliteration TEXT,
          translation TEXT,
          repetitions INTEGER,
          category TEXT NOT NULL,
          timeOfDay TEXT,
          audioPath TEXT,
          reference TEXT,
          isCustom INTEGER NOT NULL DEFAULT 1
        )
      ''');
    }
    if (oldVersion < 5) {
      // إضافة جداول العلامات المرجعية وآخر موقع قراءة
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          surah_number INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          page INTEGER,
          note TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS last_read_position (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          surah_number INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          page INTEGER,
          updated_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 6) {
      // إضافة جداول التنبيهات ومواقيت الصلاة
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notification_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          is_enabled INTEGER NOT NULL DEFAULT 1,
          reminder_times TEXT,
          extra_settings TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS prayer_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          prayer_name TEXT NOT NULL UNIQUE,
          is_enabled INTEGER NOT NULL DEFAULT 1,
          minutes_before INTEGER NOT NULL DEFAULT 15
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS dhikr_trackers (
          id TEXT PRIMARY KEY,
          dhikr_id TEXT NOT NULL,
          dhikr_name TEXT NOT NULL,
          target_count INTEGER NOT NULL,
          current_count INTEGER NOT NULL DEFAULT 0,
          started_at TEXT NOT NULL,
          completed_at TEXT,
          reminder_interval INTEGER NOT NULL DEFAULT 30,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');

      // إضافة إعدادات افتراضية للصلوات
      for (var prayer in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        await db.insert('prayer_settings', {
          'prayer_name': prayer,
          'is_enabled': 1,
          'minutes_before': 15,
        });
      }
    }
  }

  // ============= خطط القراءة =============

  Future<void> saveReadingPlan(ReadingPlan plan) async {
    final db = await database;
    await db.insert(
      'reading_plans',
      {
        'id': plan.id,
        'start_date': plan.startDate.toIso8601String(),
        'target_end_date': plan.targetEndDate.toIso8601String(),
        'total_days': plan.totalDays,
        'plan_type': plan.planType.toString(),
        'daily_portions':
            jsonEncode(plan.dailyPortions.map((p) => p.toJson()).toList()),
        'created_at': plan.createdAt.toIso8601String(),
        'is_active': plan.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ReadingPlan?> getReadingPlan(String id) async {
    final db = await database;
    final maps = await db.query(
      'reading_plans',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
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
    return null;
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
        'daily_portions':
            jsonEncode(plan.dailyPortions.map((p) => p.toJson()).toList()),
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
        'recent_sessions':
            jsonEncode(progress.recentSessions.map((s) => s.toJson()).toList()),
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
    final completedJuzsRaw =
        jsonDecode(map['completed_juzs'] as String) as Map<String, dynamic>;
    final completedSurahsRaw =
        jsonDecode(map['completed_surahs'] as String) as Map<String, dynamic>;

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
      completedJuzs:
          completedJuzsRaw.map((k, v) => MapEntry(int.parse(k), v as bool)),
      completedSurahs:
          completedSurahsRaw.map((k, v) => MapEntry(int.parse(k), v as bool)),
    );
  }

  // ============= جلسات القراءة =============

  Future<int> insertReadingSession(
      ReadingSession session, String userId) async {
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
        'completions': jsonEncode(
            progress.completions.map((k, v) => MapEntry(k, v.toJson()))),
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
      completions:
          (jsonDecode(map['completions'] as String) as Map<String, dynamic>)
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

  // ============= الأذكار المخصصة =============

  Future<void> saveCustomDhikr(Dhikr dhikr) async {
    final db = await database;
    await db.insert(
      'custom_adhkar',
      {
        'id': dhikr.id,
        'arabicText': dhikr.arabicText,
        'transliteration': dhikr.transliteration,
        'translation': dhikr.translation,
        'repetitions': dhikr.repetitions,
        'category': dhikr.category.toString(),
        'timeOfDay': dhikr.timeOfDay?.toString(),
        'audioPath': dhikr.audioPath,
        'reference': dhikr.reference,
        'isCustom': dhikr.isCustom ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dhikr>> getCustomAdhkar() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('custom_adhkar');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Dhikr(
        id: map['id'] as String,
        arabicText: map['arabicText'] as String,
        transliteration: map['transliteration'] as String?,
        translation: map['translation'] as String?,
        repetitions: map['repetitions'] as int?,
        category: DhikrCategory.values.firstWhere(
          (e) => e.toString() == map['category'],
          orElse: () => DhikrCategory.custom,
        ),
        timeOfDay: map['timeOfDay'] != null
            ? DhikrTime.values.firstWhere(
                (e) => e.toString() == map['timeOfDay'],
              )
            : null,
        audioPath: map['audioPath'] as String?,
        reference: map['reference'] as String?,
        isCustom: map['isCustom'] == 1,
      );
    });
  }

  Future<void> deleteCustomDhikr(String id) async {
    final db = await database;
    await db.delete(
      'custom_adhkar',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============= الملف الشخصي =============

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    final data = profile.toJson();
    // تحويل القائمة إلى نص JSON للتخزين في SQLite
    data['unlockedMedalIds'] = jsonEncode(profile.unlockedMedalIds);

    await db.insert(
      'user_profile',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);

    if (maps.isNotEmpty) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(maps.first);
      if (data['unlockedMedalIds'] != null) {
        data['unlockedMedalIds'] =
            jsonDecode(data['unlockedMedalIds'] as String);
      }
      return UserProfile.fromJson(data);
    }
    return null;
  }

  // ============= تنظيف =============

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
