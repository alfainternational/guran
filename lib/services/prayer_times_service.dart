import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// خدمة حساب مواقيت الصلاة
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  PrayerTimes? _cachedPrayerTimes;
  DateTime? _cachedDate;
  Coordinates? _lastKnownLocation;

  /// الحصول على الموقع الحالي
  Future<Coordinates?> getCurrentLocation() async {
    try {
      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('تم رفض أذونات الموقع');
          return _loadLastKnownLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('أذونات الموقع مرفوضة بشكل دائم');
        return _loadLastKnownLocation();
      }

      // الحصول على الموقع
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final coordinates = Coordinates(position.latitude, position.longitude);
      _lastKnownLocation = coordinates;
      await _saveLocation(coordinates);

      return coordinates;
    } catch (e) {
      debugPrint('خطأ في الحصول على الموقع: $e');
      return _loadLastKnownLocation();
    }
  }

  /// حفظ آخر موقع معروف
  Future<void> _saveLocation(Coordinates coordinates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_latitude', coordinates.latitude);
    await prefs.setDouble('last_longitude', coordinates.longitude);
  }

  /// تحميل آخر موقع معروف
  Future<Coordinates?> _loadLastKnownLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_latitude');
    final lon = prefs.getDouble('last_longitude');

    if (lat != null && lon != null) {
      return Coordinates(lat, lon);
    }

    // موقع افتراضي (الرياض)
    return Coordinates(24.7136, 46.6753);
  }

  /// حساب مواقيت الصلاة لليوم الحالي
  Future<PrayerTimes?> calculatePrayerTimes() async {
    final now = DateTime.now();

    // استخدام cache إذا كان نفس اليوم
    if (_cachedPrayerTimes != null &&
        _cachedDate != null &&
        _cachedDate!.year == now.year &&
        _cachedDate!.month == now.month &&
        _cachedDate!.day == now.day) {
      return _cachedPrayerTimes;
    }

    final coordinates = await getCurrentLocation();
    if (coordinates == null) return null;

    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(now),
      params,
    );

    _cachedPrayerTimes = prayerTimes;
    _cachedDate = now;

    return prayerTimes;
  }

  /// جدولة تنبيهات لجميع الصلوات
  Future<void> scheduleAllPrayerNotifications() async {
    final prayerTimes = await calculatePrayerTimes();
    if (prayerTimes == null) {
      debugPrint('فشل في حساب مواقيت الصلاة');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final minutesBefore = prefs.getInt('prayer_reminder_minutes') ?? 15;

    // جدولة تنبيه لكل صلاة
    final prayers = {
      'fajr': prayerTimes.fajr,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
    };

    for (var entry in prayers.entries) {
      final prayerName = _getPrayerNameArabic(entry.key);
      final prayerTime = entry.value;

      // التحقق من تفعيل التنبيه لهذه الصلاة
      final isEnabled = prefs.getBool('prayer_${entry.key}_enabled') ?? true;
      if (!isEnabled) continue;

      // جدولة التنبيه
      if (prayerTime.isAfter(DateTime.now())) {
        await NotificationService().schedulePrayerNotification(
          prayerName: prayerName,
          prayerTime: prayerTime,
          minutesBefore: minutesBefore,
        );
      }
    }

    debugPrint('تم جدولة تنبيهات الصلاة');
  }

  String _getPrayerNameArabic(String prayerKey) {
    switch (prayerKey) {
      case 'fajr':
        return 'الفجر';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return prayerKey;
    }
  }

  /// الحصول على الصلاة التالية
  Future<Map<String, dynamic>?> getNextPrayer() async {
    final prayerTimes = await calculatePrayerTimes();
    if (prayerTimes == null) return null;

    final now = DateTime.now();
    final prayers = {
      'الفجر': prayerTimes.fajr,
      'الظهر': prayerTimes.dhuhr,
      'العصر': prayerTimes.asr,
      'المغرب': prayerTimes.maghrib,
      'العشاء': prayerTimes.isha,
    };

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        final timeUntil = entry.value.difference(now);
        return {
          'name': entry.key,
          'time': entry.value,
          'timeUntil': timeUntil,
        };
      }
    }

    return null; // كل الصلوات مرت
  }
}
