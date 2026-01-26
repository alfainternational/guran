import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class ProfileProvider with ChangeNotifier {
  final _db = DatabaseService();
  UserProfile? _profile;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _db.getUserProfile();

    if (_profile != null) {
      final now = DateTime.now();
      final lastOpen = _profile!.lastOpenDate;

      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(lastOpen.year, lastOpen.month, lastOpen.day);

      final difference = today.difference(lastDay).inDays;

      if (difference == 1) {
        // مستخدم ملتزم، زد العداد
        _profile = UserProfile(
          name: _profile!.name,
          age: _profile!.age,
          gender: _profile!.gender,
          joinedDate: _profile!.joinedDate,
          lastOpenDate: now,
          consecutiveDays: _profile!.consecutiveDays + 1,
        );
        await _db.saveUserProfile(_profile!);
      } else if (difference > 1) {
        // انقطع التتابع، ابدأ من جديد
        _profile = UserProfile(
          name: _profile!.name,
          age: _profile!.age,
          gender: _profile!.gender,
          joinedDate: _profile!.joinedDate,
          lastOpenDate: now,
          consecutiveDays: 1,
        );
        await _db.saveUserProfile(_profile!);
      } else if (difference == 0) {
        // فتح التطبيق في نفس اليوم، حدث الوقت فقط ليكون دقيقاً (اختياري)
        // لا نزيد العداد
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> saveProfile(UserProfile profile) async {
    try {
      debugPrint('جاري حفظ الملف الشخصي: ${profile.name}');
      await _db.saveUserProfile(profile);
      _profile = profile;
      notifyListeners();
      debugPrint('تم حفظ الملف الشخصي بنجاح');
      return null; // Success
    } catch (e) {
      debugPrint('خطأ في حفظ الملف الشخصي: $e');
      return e.toString(); // Return error message
    }
  }
}
