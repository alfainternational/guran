import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/prayer_times_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // إعدادات القراءة
  bool _quranRemindersEnabled = true;
  bool _wirdRemindersEnabled = true;

  // إعدادات الصلاة
  bool _prayerNotificationsEnabled = true;
  int _minutesBeforePrayer = 15;
  final Map<String, bool> _prayerEnabled = {
    'fajr': true,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _quranRemindersEnabled = prefs.getBool('quran_reminders_enabled') ?? true;
      _wirdRemindersEnabled = prefs.getBool('wird_reminders_enabled') ?? true;
      _prayerNotificationsEnabled =
          prefs.getBool('prayer_notifications_enabled') ?? true;
      _minutesBeforePrayer = prefs.getInt('prayer_reminder_minutes') ?? 15;

      for (var prayer in _prayerEnabled.keys) {
        _prayerEnabled[prayer] =
            prefs.getBool('prayer_${prayer}_enabled') ?? true;
      }
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }

    // إعادة جدولة التنبيهات
    if (key.startsWith('prayer')) {
      await PrayerTimesService().scheduleAllPrayerNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات التنبيهات'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('القرآن الكريم'),
          SwitchListTile(
            title: const Text('تذكيرات القراءة العامة'),
            subtitle: const Text('رسائل تحفيزية لقراءة القرآن'),
            value: _quranRemindersEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _quranRemindersEnabled = val);
              _saveSetting('quran_reminders_enabled', val);
            },
          ),
          SwitchListTile(
            title: const Text('تنبيهات الورد اليومي'),
            subtitle: const Text('تذكير عند عدم إكمال الورد اليومي'),
            value: _wirdRemindersEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _wirdRemindersEnabled = val);
              _saveSetting('wird_reminders_enabled', val);
            },
          ),
          const Divider(),
          _buildSectionHeader('الصلوات'),
          SwitchListTile(
            title: const Text('تفعيل تنبيهات الصلاة'),
            subtitle: const Text('التذكير بدخول أوقات الصلاة'),
            value: _prayerNotificationsEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _prayerNotificationsEnabled = val);
              _saveSetting('prayer_notifications_enabled', val);
            },
          ),
          if (_prayerNotificationsEnabled) ...[
            ListTile(
              title: const Text('وقت التنبيه قبل الصلاة'),
              subtitle: Text('$_minutesBeforePrayer دقيقة قبل الأذان'),
              trailing: DropdownButton<int>(
                value: _minutesBeforePrayer,
                underline: Container(),
                items: [5, 10, 15, 20, 30].map((int minutes) {
                  return DropdownMenuItem<int>(
                    value: minutes,
                    child: Text('$minutes دقيقة'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _minutesBeforePrayer = val);
                    _saveSetting('prayer_reminder_minutes', val);
                  }
                },
              ),
            ),
            _buildPrayerToggle('fajr', 'الفجر'),
            _buildPrayerToggle('dhuhr', 'الظهر'),
            _buildPrayerToggle('asr', 'العصر'),
            _buildPrayerToggle('maghrib', 'المغرب'),
            _buildPrayerToggle('isha', 'العشاء'),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerToggle(String key, String label) {
    return CheckboxListTile(
      title: Text(label),
      value: _prayerEnabled[key],
      activeColor: const Color(0xFF1B5E20),
      onChanged: (val) {
        if (val != null) {
          setState(() => _prayerEnabled[key] = val);
          _saveSetting('prayer_${key}_enabled', val);
        }
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1B5E20),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
