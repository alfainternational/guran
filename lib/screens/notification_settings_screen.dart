import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_scheduler.dart';
import '../services/sun_calculation_service.dart';

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

  // إعدادات الأذكار
  bool _morningAdhkarEnabled = true;
  bool _eveningAdhkarEnabled = true;
  bool _istighfarEnabled = true;
  bool _duhaEnabled = false;
  bool _sleepAdhkarEnabled = false;

  // إعدادات الليل
  bool _lastThirdEnabled = false;

  // معلومات أوقات اليوم
  DayTimeInfo? _dayTimeInfo;
  bool _loadingTimes = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadDayTimes();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _quranRemindersEnabled =
          prefs.getBool('quran_reminders_enabled') ?? true;
      _wirdRemindersEnabled =
          prefs.getBool('wird_reminders_enabled') ?? true;
      _prayerNotificationsEnabled =
          prefs.getBool('prayer_notifications_enabled') ?? true;
      _minutesBeforePrayer =
          prefs.getInt('prayer_reminder_minutes') ?? 15;

      for (var prayer in _prayerEnabled.keys) {
        _prayerEnabled[prayer] =
            prefs.getBool('prayer_${prayer}_enabled') ?? true;
      }

      // إعدادات الأذكار
      _morningAdhkarEnabled =
          prefs.getBool('morning_adhkar_enabled') ?? true;
      _eveningAdhkarEnabled =
          prefs.getBool('evening_adhkar_enabled') ?? true;
      _istighfarEnabled =
          prefs.getBool('istighfar_reminder_enabled') ?? true;
      _duhaEnabled = prefs.getBool('duha_reminder_enabled') ?? false;
      _sleepAdhkarEnabled =
          prefs.getBool('sleep_adhkar_enabled') ?? false;

      // إعدادات الليل
      _lastThirdEnabled =
          prefs.getBool('last_third_night_enabled') ?? false;
    });
  }

  Future<void> _loadDayTimes() async {
    try {
      final dayTimes = await SunCalculationService().calculateDayTimes();
      if (mounted) {
        setState(() {
          _dayTimeInfo = dayTimes;
          _loadingTimes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingTimes = false;
        });
      }
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }

    // إعادة جدولة جميع التنبيهات عند تغيير أي إعداد
    await NotificationScheduler().rescheduleOnSettingsChange();
  }

  String _formatTimeInfo(DateTime? time) {
    if (time == null || _dayTimeInfo == null) return '';
    return _dayTimeInfo!.formatTime(time);
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
          // معلومات أوقات اليوم
          if (_dayTimeInfo != null) _buildDayTimesCard(),

          // === قسم الأذكار ===
          _buildSectionHeader('الأذكار والأدعية'),

          SwitchListTile(
            title: const Text('أذكار الصباح'),
            subtitle: Text(
              _dayTimeInfo != null
                  ? 'بعد صلاة الفجر (${_formatTimeInfo(_dayTimeInfo!.fajr.add(const Duration(minutes: 5)))})'
                  : 'بعد صلاة الفجر بناءً على موقعك',
            ),
            secondary: const Icon(Icons.wb_sunny_outlined,
                color: Color(0xFFFF8F00)),
            value: _morningAdhkarEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _morningAdhkarEnabled = val);
              _saveSetting('morning_adhkar_enabled', val);
            },
          ),

          SwitchListTile(
            title: const Text('أذكار المساء'),
            subtitle: Text(
              _dayTimeInfo != null
                  ? 'بعد صلاة العصر (${_formatTimeInfo(_dayTimeInfo!.asr.add(const Duration(minutes: 5)))})'
                  : 'بعد صلاة العصر بناءً على موقعك',
            ),
            secondary: const Icon(Icons.nightlight_round_outlined,
                color: Color(0xFF5C6BC0)),
            value: _eveningAdhkarEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _eveningAdhkarEnabled = val);
              _saveSetting('evening_adhkar_enabled', val);
            },
          ),

          SwitchListTile(
            title: const Text('تذكير بالاستغفار'),
            subtitle: Text(
              _dayTimeInfo != null
                  ? 'قبل صلاة الظهر (${_formatTimeInfo(_dayTimeInfo!.dhuhr.subtract(const Duration(minutes: 30)))})'
                  : 'قبل صلاة الظهر',
            ),
            secondary: const Icon(Icons.favorite_outline,
                color: Color(0xFF26A69A)),
            value: _istighfarEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _istighfarEnabled = val);
              _saveSetting('istighfar_reminder_enabled', val);
            },
          ),

          SwitchListTile(
            title: const Text('تذكير بصلاة الضحى'),
            subtitle: Text(
              _dayTimeInfo != null
                  ? 'بعد الشروق (${_formatTimeInfo(_dayTimeInfo!.sunrise.add(const Duration(minutes: 20)))})'
                  : 'بعد شروق الشمس',
            ),
            secondary: const Icon(Icons.wb_twilight,
                color: Color(0xFFFF7043)),
            value: _duhaEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _duhaEnabled = val);
              _saveSetting('duha_reminder_enabled', val);
            },
          ),

          SwitchListTile(
            title: const Text('أذكار النوم'),
            subtitle: Text(
              _dayTimeInfo != null
                  ? 'بعد صلاة العشاء (${_formatTimeInfo(_dayTimeInfo!.isha.add(const Duration(hours: 2)))})'
                  : 'بعد صلاة العشاء بساعتين',
            ),
            secondary: const Icon(Icons.bedtime_outlined,
                color: Color(0xFF7E57C2)),
            value: _sleepAdhkarEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _sleepAdhkarEnabled = val);
              _saveSetting('sleep_adhkar_enabled', val);
            },
          ),

          const Divider(),

          // === قسم الليل ===
          _buildSectionHeader('قيام الليل'),

          SwitchListTile(
            title: const Text('تنبيه الثلث الأخير من الليل'),
            subtitle: Text(
              _dayTimeInfo != null
                  ? 'يبدأ ${_formatTimeInfo(_dayTimeInfo!.lastThirdStart)} وينتهي عند الفجر'
                  : 'الثلث الأخير من الليل بناءً على موقعك',
            ),
            secondary: const Icon(Icons.dark_mode_outlined,
                color: Color(0xFF283593)),
            value: _lastThirdEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (val) {
              setState(() => _lastThirdEnabled = val);
              _saveSetting('last_third_night_enabled', val);
            },
          ),

          if (_dayTimeInfo != null) _buildNightInfoCard(),

          const Divider(),

          // === قسم الصلوات ===
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
            _buildPrayerToggle('fajr', 'الفجر', _dayTimeInfo?.fajr),
            _buildPrayerToggle('dhuhr', 'الظهر', _dayTimeInfo?.dhuhr),
            _buildPrayerToggle('asr', 'العصر', _dayTimeInfo?.asr),
            _buildPrayerToggle(
                'maghrib', 'المغرب', _dayTimeInfo?.maghrib),
            _buildPrayerToggle('isha', 'العشاء', _dayTimeInfo?.isha),
          ],

          const Divider(),

          // === قسم القراءة ===
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// بطاقة عرض أوقات اليوم الحالية
  Widget _buildDayTimesCard() {
    if (_loadingTimes) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_dayTimeInfo == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1B5E20),
              Colors.green[800]!,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'مواقيت اليوم (حسب موقعك)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeChip(
                      'الفجر', _formatTimeInfo(_dayTimeInfo!.fajr)),
                  _buildTimeChip(
                      'الشروق', _formatTimeInfo(_dayTimeInfo!.sunrise)),
                  _buildTimeChip(
                      'الظهر', _formatTimeInfo(_dayTimeInfo!.dhuhr)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeChip(
                      'العصر', _formatTimeInfo(_dayTimeInfo!.asr)),
                  _buildTimeChip(
                      'المغرب', _formatTimeInfo(_dayTimeInfo!.maghrib)),
                  _buildTimeChip(
                      'العشاء', _formatTimeInfo(_dayTimeInfo!.isha)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// بطاقة معلومات أثلاث الليل
  Widget _buildNightInfoCard() {
    if (_dayTimeInfo == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A237E).withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أثلاث الليل',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF283593),
              ),
            ),
            const SizedBox(height: 12),
            _buildNightThirdRow(
              'الثلث الأول',
              '${_formatTimeInfo(_dayTimeInfo!.nightStart)} - ${_formatTimeInfo(_dayTimeInfo!.firstThirdEnd)}',
              Colors.indigo[300]!,
            ),
            const SizedBox(height: 8),
            _buildNightThirdRow(
              'الثلث الأوسط',
              '${_formatTimeInfo(_dayTimeInfo!.firstThirdEnd)} - ${_formatTimeInfo(_dayTimeInfo!.secondThirdEnd)}',
              Colors.indigo[500]!,
            ),
            const SizedBox(height: 8),
            _buildNightThirdRow(
              'الثلث الأخير',
              '${_formatTimeInfo(_dayTimeInfo!.lastThirdStart)} - ${_formatTimeInfo(_dayTimeInfo!.nightEnd)}',
              Colors.indigo[800]!,
            ),
            const SizedBox(height: 8),
            Text(
              'مدة الليل: ${_dayTimeInfo!.nightDuration.inHours} ساعة و ${_dayTimeInfo!.nightDuration.inMinutes % 60} دقيقة',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNightThirdRow(String label, String time, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          time,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerToggle(
      String key, String label, DateTime? time) {
    return CheckboxListTile(
      title: Text(label),
      subtitle: time != null ? Text(_formatTimeInfo(time)) : null,
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
