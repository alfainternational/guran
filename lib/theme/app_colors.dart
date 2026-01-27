import 'package:flutter/material.dart';

/// نظام الألوان الشامل للتطبيق
/// يدعم الوضع الفاتح والداكن مع ألوان إسلامية أنيقة
class AppColors {
  AppColors._();

  // ================== الألوان الأساسية - الأخضر الإسلامي ==================
  static const Color primaryGreen = Color(0xFF0D5C4D);
  static const Color primaryGreenLight = Color(0xFF2E8B7B);
  static const Color primaryGreenDark = Color(0xFF004D40);
  static const Color primaryGreenSoft = Color(0xFF4CAF93);

  // ================== الألوان الذهبية - للتأكيد والإنجازات ==================
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE6C86E);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldSoft = Color(0xFFF5DEB3);

  // ================== ألوان الخلفية - الوضع الفاتح ==================
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ================== ألوان الخلفية - الوضع الداكن ==================
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);

  // ================== ألوان النصوص - الوضع الفاتح ==================
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textTertiaryLight = Color(0xFF999999);

  // ================== ألوان النصوص - الوضع الداكن ==================
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);

  // ================== ألوان الحالة ==================
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFB9F6CA);
  static const Color successDark = Color(0xFF00A844);

  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFE082);
  static const Color warningDark = Color(0xFFFF8F00);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);
  static const Color infoDark = Color(0xFF1976D2);

  // ================== ألوان خاصة بالقرآن ==================
  static const Color quranPageBg = Color(0xFFFFFBF0);
  static const Color quranPageBgDark = Color(0xFF2A2520);
  static const Color quranText = Color(0xFF1A1A1A);
  static const Color quranTextDark = Color(0xFFE8E0D0);
  static const Color ayahHighlight = Color(0xFFE8F5E9);
  static const Color ayahHighlightDark = Color(0xFF1B3A2F);
  static const Color surahHeader = Color(0xFF1B5E20);
  static const Color juzMarker = Color(0xFFD4AF37);

  // ================== ألوان الأذكار ==================
  static const Color morningColor = Color(0xFFFF9800);
  static const Color eveningColor = Color(0xFF3F51B5);
  static const Color generalDhikrColor = Color(0xFF009688);

  // ================== ألوان المستويات (Gamification) ==================
  static const Color levelBronze = Color(0xFFCD7F32);
  static const Color levelSilver = Color(0xFFC0C0C0);
  static const Color levelGold = Color(0xFFFFD700);
  static const Color levelPlatinum = Color(0xFFE5E4E2);
  static const Color levelDiamond = Color(0xFFB9F2FF);
  static const Color levelLegendary = Color(0xFFFF6B6B);

  // ================== ألوان الشريط المتتالي (Streak) ==================
  static const Color streakFire = Color(0xFFFF5722);
  static const Color streakHot = Color(0xFFFF9800);
  static const Color streakWarm = Color(0xFFFFC107);

  // ================== تدرجات لونية ==================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient morningGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient eveningGradient = LinearGradient(
    colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF69F0AE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ================== ظلال ==================
  static List<BoxShadow> get lightShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get heavyShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryGreen.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get goldGlowShadow => [
        BoxShadow(
          color: gold.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
}

/// Extension للحصول على ألوان حسب السطوع
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => AppColors.primaryGreen;
  Color get accentColor => AppColors.gold;

  Color get backgroundColor =>
      isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get cardColor => isDarkMode ? AppColors.cardDark : AppColors.cardLight;

  Color get textPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  Color get quranBg =>
      isDarkMode ? AppColors.quranPageBgDark : AppColors.quranPageBg;
  Color get quranText =>
      isDarkMode ? AppColors.quranTextDark : AppColors.quranText;
}
