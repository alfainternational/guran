import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مزود الثيم - يدير التبديل بين الوضع الفاتح والداكن
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _autoThemeKey = 'app_auto_theme';

  ThemeMode _themeMode = ThemeMode.system;
  bool _useAutoTheme = true;

  ThemeMode get themeMode => _themeMode;
  bool get useAutoTheme => _useAutoTheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// تحميل تفضيلات الثيم المحفوظة
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _useAutoTheme = prefs.getBool(_autoThemeKey) ?? true;

      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// تغيير وضع الثيم
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// تفعيل/تعطيل الثيم التلقائي
  Future<void> setAutoTheme(bool value) async {
    if (_useAutoTheme == value) return;

    _useAutoTheme = value;
    if (value) {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoThemeKey, value);
      if (value) {
        await prefs.setInt(_themeKey, ThemeMode.system.index);
      }
    } catch (e) {
      debugPrint('Error saving auto theme preference: $e');
    }
  }

  /// تبديل الثيم بين الفاتح والداكن
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
    _useAutoTheme = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoThemeKey, false);
    } catch (e) {
      debugPrint('Error saving auto theme preference: $e');
    }
  }

  /// تعيين الوضع الفاتح
  Future<void> setLightMode() async {
    _useAutoTheme = false;
    await setThemeMode(ThemeMode.light);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoThemeKey, false);
    } catch (e) {
      debugPrint('Error saving auto theme preference: $e');
    }
  }

  /// تعيين الوضع الداكن
  Future<void> setDarkMode() async {
    _useAutoTheme = false;
    await setThemeMode(ThemeMode.dark);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoThemeKey, false);
    } catch (e) {
      debugPrint('Error saving auto theme preference: $e');
    }
  }

  /// تعيين الوضع التلقائي (حسب النظام)
  Future<void> setSystemMode() async {
    _useAutoTheme = true;
    await setThemeMode(ThemeMode.system);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoThemeKey, true);
    } catch (e) {
      debugPrint('Error saving auto theme preference: $e');
    }
  }

  /// الحصول على اسم الوضع الحالي بالعربية
  String get currentModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي';
    }
  }

  /// الحصول على أيقونة الوضع الحالي
  IconData get currentModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}
