# 🛠️ تحسينات عملية قابلة للتنفيذ الفوري
## نماذج كود جاهزة للاستخدام

---

## 1️⃣ تحسين نظام الألوان والثيم

### ملف جديد: `lib/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';

/// نظام الألوان الجديد للتطبيق
class AppColors {
  // ================== الألوان الأساسية ==================
  static const Color primaryGreen = Color(0xFF0D5C4D);
  static const Color primaryGreenLight = Color(0xFF2E7D6E);
  static const Color primaryGreenDark = Color(0xFF004D40);

  // ================== الألوان الذهبية ==================
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE6C86E);
  static const Color goldDark = Color(0xFFB8860B);

  // ================== ألوان الخلفية ==================
  static const Color backgroundLight = Color(0xFFF5F5F0);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D44);

  // ================== ألوان النصوص ==================
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB2BEC3);

  // ================== ألوان الحالة ==================
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // ================== ألوان إضافية ==================
  static const Color quranGold = Color(0xFFDAA520);
  static const Color nightBlue = Color(0xFF2C3E50);
  static const Color morningOrange = Color(0xFFE67E22);
}

/// الثيم الفاتح
class LightTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // الألوان
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.backgroundLight,

    colorScheme: ColorScheme.light(
      primary: AppColors.primaryGreen,
      primaryContainer: AppColors.primaryGreenLight,
      secondary: AppColors.goldAccent,
      secondaryContainer: AppColors.goldLight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
    ),

    // الخطوط
    fontFamily: 'Amiri',
    textTheme: _buildTextTheme(isLight: true),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // البطاقات
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // شريط التنقل السفلي
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: Colors.grey[400],
      selectedLabelStyle: TextStyle(
        fontFamily: 'Amiri',
        fontWeight: FontWeight.bold,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // حقول الإدخال
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );

  static TextTheme _buildTextTheme({required bool isLight}) {
    final baseColor = isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final secondaryColor = isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: baseColor,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: secondaryColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: secondaryColor,
      ),
    );
  }
}

/// الثيم الداكن
class DarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    primaryColor: AppColors.primaryGreenLight,
    scaffoldBackgroundColor: AppColors.backgroundDark,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryGreenLight,
      primaryContainer: AppColors.primaryGreen,
      secondary: AppColors.goldAccent,
      secondaryContainer: AppColors.goldDark,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),

    fontFamily: 'Amiri',
    textTheme: LightTheme._buildTextTheme(isLight: false),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: CardTheme(
      color: AppColors.surfaceDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreenLight,
        foregroundColor: Colors.white,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.goldAccent,
      unselectedItemColor: Colors.grey[600],
    ),
  );
}
```

---

## 2️⃣ مكون بطاقة التقدم الجديدة

### ملف: `lib/widgets/progress_card.dart`

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// بطاقة تقدم دائرية جذابة
class CircularProgressCard extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? progressColor;
  final VoidCallback? onTap;

  const CircularProgressCard({
    super.key,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.progressColor,
    this.onTap,
  });

  @override
  State<CircularProgressCard> createState() => _CircularProgressCardState();
}

class _CircularProgressCardState extends State<CircularProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.progressColor ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // الدائرة المتحركة
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(80, 80),
                    painter: _CircularProgressPainter(
                      progress: _progressAnimation.value,
                      progressColor: color,
                      backgroundColor: Colors.grey[200]!,
                      strokeWidth: 8,
                    ),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: Text(
                          '${(_progressAnimation.value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 20),

              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(widget.icon, color: color, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // السهم
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // الخلفية
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // التقدم
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          progressColor.withOpacity(0.5),
          progressColor,
        ],
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
```

---

## 3️⃣ بطاقة الترحيب المحسّنة

### ملف محدث: تحسين `_buildWelcomeCard` في `home_screen.dart`

```dart
Widget _buildEnhancedWelcomeCard() {
  return Consumer<ProfileProvider>(
    builder: (context, provider, _) {
      final profile = provider.profile;
      if (profile == null) return const SizedBox.shrink();

      final now = DateTime.now();
      final hour = now.hour;

      // تحديد التحية والأيقونة حسب الوقت
      String greeting;
      IconData timeIcon;
      List<Color> gradientColors;

      if (hour >= 5 && hour < 12) {
        greeting = 'صباح الخير والبركة';
        timeIcon = Icons.wb_sunny_rounded;
        gradientColors = [
          const Color(0xFF1B5E20),
          const Color(0xFF43A047),
        ];
      } else if (hour >= 12 && hour < 17) {
        greeting = 'طاب يومك بذكر الله';
        timeIcon = Icons.light_mode_rounded;
        gradientColors = [
          const Color(0xFF0D5C4D),
          const Color(0xFF2E7D6E),
        ];
      } else if (hour >= 17 && hour < 20) {
        greeting = 'مساء الخير والسرور';
        timeIcon = Icons.wb_twilight_rounded;
        gradientColors = [
          const Color(0xFF5D4037),
          const Color(0xFF8D6E63),
        ];
      } else {
        greeting = 'طاب مساؤك بذكر الله';
        timeIcon = Icons.nightlight_round;
        gradientColors = [
          const Color(0xFF1A237E),
          const Color(0xFF3949AB),
        ];
      }

      final message = MotivationalMessages.getRandomMessage(MessageTrigger.appOpen);

      return Card(
        elevation: 8,
        shadowColor: gradientColors[0].withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // الزخرفة الخلفية
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // المحتوى
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // أيقونة الوقت
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            timeIcon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        // عداد الأيام المتتالية
                        _buildStreakBadge(profile.consecutiveDays),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // التحية
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // الرسالة التحفيزية
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message.arabicText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStreakBadge(int days) {
  Color badgeColor;
  IconData badgeIcon;

  if (days >= 30) {
    badgeColor = Colors.amber;
    badgeIcon = Icons.local_fire_department;
  } else if (days >= 7) {
    badgeColor = Colors.orange;
    badgeIcon = Icons.whatshot;
  } else {
    badgeColor = Colors.white;
    badgeIcon = Icons.local_fire_department;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: badgeColor.withOpacity(0.5),
        width: 2,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(badgeIcon, color: badgeColor, size: 20),
        const SizedBox(width: 6),
        Text(
          '$days',
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'يوم',
          style: TextStyle(
            color: badgeColor.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
```

---

## 4️⃣ نظام Gamification الأساسي

### ملف جديد: `lib/services/gamification_service.dart`

```dart
import 'package:flutter/material.dart';

/// نقاط الأنشطة
class ActivityPoints {
  static const int readAyah = 1;
  static const int readPage = 10;
  static const int completeJuz = 100;
  static const int completeSurah = 50;
  static const int dhikrSession = 15;
  static const int dailyStreak = 25;
  static const int weeklyStreak = 200;
  static const int completeKhatma = 5000;
}

/// المستويات
class UserLevel {
  final int level;
  final String title;
  final String titleArabic;
  final int minPoints;
  final int maxPoints;
  final Color color;
  final IconData icon;

  const UserLevel({
    required this.level,
    required this.title,
    required this.titleArabic,
    required this.minPoints,
    required this.maxPoints,
    required this.color,
    required this.icon,
  });

  static const List<UserLevel> allLevels = [
    UserLevel(
      level: 1,
      title: 'Beginner',
      titleArabic: 'قارئ مبتدئ',
      minPoints: 0,
      maxPoints: 500,
      color: Color(0xFF90A4AE),
      icon: Icons.eco,
    ),
    UserLevel(
      level: 2,
      title: 'Regular',
      titleArabic: 'قارئ منتظم',
      minPoints: 500,
      maxPoints: 1500,
      color: Color(0xFF66BB6A),
      icon: Icons.spa,
    ),
    UserLevel(
      level: 3,
      title: 'Committed',
      titleArabic: 'قارئ ملتزم',
      minPoints: 1500,
      maxPoints: 3500,
      color: Color(0xFF42A5F5),
      icon: Icons.auto_awesome,
    ),
    UserLevel(
      level: 4,
      title: 'Advanced',
      titleArabic: 'قارئ متقدم',
      minPoints: 3500,
      maxPoints: 7000,
      color: Color(0xFFAB47BC),
      icon: Icons.star,
    ),
    UserLevel(
      level: 5,
      title: 'Expert',
      titleArabic: 'قارئ محترف',
      minPoints: 7000,
      maxPoints: 15000,
      color: Color(0xFFFFB300),
      icon: Icons.emoji_events,
    ),
    UserLevel(
      level: 6,
      title: 'Master',
      titleArabic: 'سفير القرآن',
      minPoints: 15000,
      maxPoints: 30000,
      color: Color(0xFFFF7043),
      icon: Icons.military_tech,
    ),
    UserLevel(
      level: 7,
      title: 'Legend',
      titleArabic: 'نجم القرآن',
      minPoints: 30000,
      maxPoints: 999999999,
      color: Color(0xFFE91E63),
      icon: Icons.workspace_premium,
    ),
  ];

  static UserLevel getLevelForPoints(int points) {
    for (var level in allLevels.reversed) {
      if (points >= level.minPoints) {
        return level;
      }
    }
    return allLevels.first;
  }
}

/// خدمة Gamification
class GamificationService {
  // حساب النقاط المكتسبة
  static int calculateReadingPoints({
    required int ayahsRead,
    required int minutesSpent,
    required int juzCompleted,
    required int surahsCompleted,
  }) {
    int points = 0;
    points += ayahsRead * ActivityPoints.readAyah;
    points += (ayahsRead ~/ 15) * ActivityPoints.readPage; // تقريباً 15 آية = صفحة
    points += juzCompleted * ActivityPoints.completeJuz;
    points += surahsCompleted * ActivityPoints.completeSurah;
    return points;
  }

  // حساب نقاط السلسلة
  static int calculateStreakPoints(int consecutiveDays) {
    int points = 0;
    points += consecutiveDays * ActivityPoints.dailyStreak;
    points += (consecutiveDays ~/ 7) * ActivityPoints.weeklyStreak;
    return points;
  }

  // الحصول على المستوى الحالي
  static UserLevel getCurrentLevel(int totalPoints) {
    return UserLevel.getLevelForPoints(totalPoints);
  }

  // حساب التقدم نحو المستوى التالي
  static double getProgressToNextLevel(int totalPoints) {
    final currentLevel = UserLevel.getLevelForPoints(totalPoints);
    final levelIndex = UserLevel.allLevels.indexOf(currentLevel);

    if (levelIndex == UserLevel.allLevels.length - 1) {
      return 1.0; // آخر مستوى
    }

    final nextLevel = UserLevel.allLevels[levelIndex + 1];
    final pointsInLevel = totalPoints - currentLevel.minPoints;
    final levelRange = nextLevel.minPoints - currentLevel.minPoints;

    return pointsInLevel / levelRange;
  }

  // النقاط المتبقية للمستوى التالي
  static int getPointsToNextLevel(int totalPoints) {
    final currentLevel = UserLevel.getLevelForPoints(totalPoints);
    final levelIndex = UserLevel.allLevels.indexOf(currentLevel);

    if (levelIndex == UserLevel.allLevels.length - 1) {
      return 0;
    }

    final nextLevel = UserLevel.allLevels[levelIndex + 1];
    return nextLevel.minPoints - totalPoints;
  }
}

/// التحديات اليومية
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int target;
  final int points;
  int progress;
  bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.points,
    this.progress = 0,
    this.isCompleted = false,
  });

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);

  static List<DailyChallenge> generateDailyChallenges() {
    final now = DateTime.now();
    final seed = now.year * 1000 + now.month * 100 + now.day;

    // تحديات ثابتة لكل يوم
    return [
      DailyChallenge(
        id: 'daily_read_${seed}',
        title: 'القارئ النشيط',
        description: 'اقرأ صفحة واحدة على الأقل',
        type: ChallengeType.reading,
        target: 1,
        points: 20,
      ),
      DailyChallenge(
        id: 'daily_dhikr_${seed}',
        title: 'الذاكر',
        description: 'أكمل أذكار الصباح أو المساء',
        type: ChallengeType.dhikr,
        target: 1,
        points: 15,
      ),
      DailyChallenge(
        id: 'daily_time_${seed}',
        title: 'القارئ المتفاني',
        description: 'اقرأ لمدة 10 دقائق متواصلة',
        type: ChallengeType.time,
        target: 10,
        points: 25,
      ),
    ];
  }
}

enum ChallengeType {
  reading,
  dhikr,
  time,
  streak,
  special,
}
```

---

## 5️⃣ Widget عرض المستوى

### ملف جديد: `lib/widgets/level_display_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../services/gamification_service.dart';

class LevelDisplayWidget extends StatelessWidget {
  final int totalPoints;
  final bool showDetails;

  const LevelDisplayWidget({
    super.key,
    required this.totalPoints,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final level = GamificationService.getCurrentLevel(totalPoints);
    final progress = GamificationService.getProgressToNextLevel(totalPoints);
    final pointsToNext = GamificationService.getPointsToNextLevel(totalPoints);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              level.color.withOpacity(0.8),
              level.color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // أيقونة المستوى
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    level.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // معلومات المستوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المستوى ${level.level}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        level.titleArabic,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // النقاط الكلية
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    Text(
                      '$totalPoints',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'نقطة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (showDetails && pointsToNext > 0) ...[
              const SizedBox(height: 20),

              // شريط التقدم
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التقدم نحو المستوى التالي',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'باقي $pointsToNext نقطة للمستوى التالي',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 6️⃣ شاشة التحديات اليومية

### ملف جديد: `lib/screens/daily_challenges_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/gamification_service.dart';

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  late List<DailyChallenge> challenges;

  @override
  void initState() {
    super.initState();
    challenges = DailyChallenge.generateDailyChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديات اليوم'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // العنوان
          const Text(
            'أكمل التحديات واكسب النقاط!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تتجدد التحديات يومياً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // قائمة التحديات
          ...challenges.map((challenge) => _buildChallengeCard(challenge)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge) {
    final isCompleted = challenge.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // أيقونة نوع التحدي
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getChallengeColor(challenge.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getChallengeIcon(challenge.type),
                    color: _getChallengeColor(challenge.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // العنوان والوصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // النقاط أو علامة الإكمال
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.points}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (!isCompleted) ...[
              const SizedBox(height: 16),

              // شريط التقدم
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: challenge.progressPercentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getChallengeColor(challenge.type),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${challenge.progress}/${challenge.target}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getChallengeColor(challenge.type),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getChallengeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.reading:
        return const Color(0xFF1B5E20);
      case ChallengeType.dhikr:
        return const Color(0xFF0D47A1);
      case ChallengeType.time:
        return const Color(0xFFE65100);
      case ChallengeType.streak:
        return const Color(0xFFD32F2F);
      case ChallengeType.special:
        return const Color(0xFF7B1FA2);
    }
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.reading:
        return Icons.menu_book_rounded;
      case ChallengeType.dhikr:
        return Icons.format_quote_rounded;
      case ChallengeType.time:
        return Icons.timer_rounded;
      case ChallengeType.streak:
        return Icons.local_fire_department_rounded;
      case ChallengeType.special:
        return Icons.auto_awesome_rounded;
    }
  }
}
```

---

## 7️⃣ تحسين مزود الثيم

### ملف جديد: `lib/providers/theme_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
```

---

## 8️⃣ تطبيق التحسينات في `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
// ... باقي الاستيرادات

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... كود التهيئة الحالي
  runApp(const KhatmatiApp());
}

class KhatmatiApp extends StatefulWidget {
  const KhatmatiApp({super.key});

  @override
  State<KhatmatiApp> createState() => _KhatmatiAppState();
}

class _KhatmatiAppState extends State<KhatmatiApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // ... الكود الحالي
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
        ChangeNotifierProvider(create: (_) => DhikrProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // جديد
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ختمتي - رفيقك في رحلة القرآن الكريم',
            debugShowCheckedModeBanner: false,

            // استخدام الثيمات الجديدة
            theme: LightTheme.theme,
            darkTheme: DarkTheme.theme,
            themeMode: themeProvider.themeMode,

            locale: const Locale('ar', 'SA'),
            supportedLocales: const [
              Locale('ar', 'SA'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const RootHandler(),
            routes: {
              // ... المسارات الحالية
            },
          );
        },
      ),
    );
  }
}
```

---

## الخطوات التالية

1. **إنشاء الملفات الجديدة** في المجلدات المناسبة
2. **تحديث الاستيرادات** في الملفات الموجودة
3. **اختبار التحسينات** على محاكي أو جهاز حقيقي
4. **التكرار والتحسين** بناءً على النتائج

---

*آخر تحديث: 2026-01-26*
