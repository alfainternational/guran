// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../models/reading_plan.dart';

class PlanSetupScreen extends StatefulWidget {
  const PlanSetupScreen({super.key});

  @override
  State<PlanSetupScreen> createState() => _PlanSetupScreenState();
}

class _PlanSetupScreenState extends State<PlanSetupScreen> {
  int _selectedDays = 30;
  int _targetDailyMinutes = 20;
  int _sessionsPerDay = 1;
  DateTime _selectedStartDate = DateTime.now();
  PlanType _selectedType = PlanType.byJuz;
  final TextEditingController _customDaysController = TextEditingController();
  final TextEditingController _minutesController =
      TextEditingController(text: '20');

  final List<int> _daysOptions = [7, 14, 30, 60, 90];

  @override
  void dispose() {
    _customDaysController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد خطة الختم'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة توضيحية
            Center(
              child: Icon(
                Icons.auto_stories,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'اختر المدة التي تريد ختم القرآن فيها',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // خيارات المدة
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _daysOptions.map((days) {
                return ChoiceChip(
                  label: Text('$days يوم'),
                  selected: _selectedDays == days,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDays = days;
                      });
                    }
                  },
                  selectedColor: const Color(0xFF1B5E20),
                  labelStyle: TextStyle(
                    color: _selectedDays == days ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customDaysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'أو أدخل مدة مخصصة (بالأيام)',
                hintText: 'مثال: 3 أو 40',
                border: const OutlineInputBorder(),
                suffixIcon: TextButton(
                  onPressed: _applyCustomDays,
                  child: const Text('تطبيق'),
                ),
              ),
              onSubmitted: (_) => _applyCustomDays(),
            ),

            const SizedBox(height: 24),

            const Text(
              'نوع التقسيم',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // نوع الخطة
            RadioListTile<PlanType>(
              title: const Text('بالأجزاء'),
              subtitle: const Text('تقسيم القرآن إلى 30 جزء'),
              value: PlanType.byJuz,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              activeColor: const Color(0xFF1B5E20),
            ),

            RadioListTile<PlanType>(
              title: const Text('بالسور'),
              subtitle: const Text('تقسيم القرآن حسب السور'),
              value: PlanType.bySurah,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              activeColor: const Color(0xFF1B5E20),
            ),
            RadioListTile<PlanType>(
              title: const Text('مرن (تلقائي)'),
              subtitle: const Text('توزيع ذكي حسب الزمن اليومي المتاح'),
              value: PlanType.custom,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              activeColor: const Color(0xFF1B5E20),
            ),

            const SizedBox(height: 24),
            const Text(
              'وقت بداية الخطة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(
                '${_selectedStartDate.year}-${_selectedStartDate.month.toString().padLeft(2, '0')}-${_selectedStartDate.day.toString().padLeft(2, '0')}  ${_selectedStartDate.hour.toString().padLeft(2, '0')}:${_selectedStartDate.minute.toString().padLeft(2, '0')}',
              ),
              trailing: TextButton(
                onPressed: _pickStartDateTime,
                child: const Text('تعديل'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الوقت اليومي المستهدف (بالدقائق)',
                hintText: 'مثال: 25',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed > 0) {
                  setState(() {
                    _targetDailyMinutes = parsed;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _sessionsPerDay,
              decoration: const InputDecoration(
                labelText: 'تقسيم الورد اليومي على عدد مرات',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                6,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1} مرة يوميًا'),
                ),
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _sessionsPerDay = value;
                });
              },
            ),

            // معلومات الخطة
            Card(
              color: const Color(0xFFF1F8E9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF1B5E20)),
                        SizedBox(width: 8),
                        Text(
                          'تفاصيل الخطة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('المدة:', '$_selectedDays يوم'),
                    _buildInfoRow(
                      'تاريخ البداية:',
                      '${_selectedStartDate.year}-${_selectedStartDate.month.toString().padLeft(2, '0')}-${_selectedStartDate.day.toString().padLeft(2, '0')}',
                    ),
                    _buildInfoRow(
                      'وقت البداية:',
                      '${_selectedStartDate.hour.toString().padLeft(2, '0')}:${_selectedStartDate.minute.toString().padLeft(2, '0')}',
                    ),
                    _buildInfoRow(
                      'القراءة اليومية:',
                      _selectedType == PlanType.byJuz
                          ? '${(30 / _selectedDays).toStringAsFixed(1)} جزء'
                          : _selectedType == PlanType.bySurah
                              ? '${(114 / _selectedDays).ceil()} سورة'
                              : '${(30 / _selectedDays).toStringAsFixed(1)} جزء (مرن)',
                    ),
                    _buildInfoRow(
                      'الوقت المتوقع يومياً:',
                      '$_targetDailyMinutes دقيقة',
                    ),
                    _buildInfoRow(
                      'تقسيم الورد:',
                      '$_sessionsPerDay ${_sessionsPerDay == 1 ? 'مرة' : 'مرات'} يوميًا',
                    ),
                    _buildInfoRow(
                      'تاريخ النهاية:',
                      _formatDate(_selectedStartDate
                          .add(Duration(days: _selectedDays - 1))),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // زر البدء
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createPlan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'ابدأ الآن',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlan() async {
    final provider = context.read<ReadingProvider>();
    final days = _selectedDays;
    final minutes = int.tryParse(_minutesController.text) ?? _targetDailyMinutes;

    if (days < 1) {
      _showError('مدة الخطة يجب أن تكون يومًا واحدًا على الأقل');
      return;
    }
    if (minutes < 5 || minutes > 300) {
      _showError('الوقت اليومي يجب أن يكون بين 5 و300 دقيقة');
      return;
    }

    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await provider.createPlan(
        numberOfDays: days,
        planType: _selectedType,
        startDate: _selectedStartDate,
        targetDailyMinutes: minutes,
        sessionsPerDay: _sessionsPerDay,
      );

      if (!mounted) return;

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الخطة بنجاح! بالتوفيق 🌟'),
          backgroundColor: Color(0xFF1B5E20),
        ),
      );

      // العودة للصفحة الرئيسية
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickStartDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedStartDate),
    );

    if (!mounted) return;

    setState(() {
      _selectedStartDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime?.hour ?? _selectedStartDate.hour,
        selectedTime?.minute ?? _selectedStartDate.minute,
      );
    });
  }

  void _applyCustomDays() {
    final parsed = int.tryParse(_customDaysController.text.trim());
    if (parsed == null || parsed < 1 || parsed > 3650) {
      _showError('أدخل عدد أيام صحيح بين 1 و3650');
      return;
    }
    setState(() {
      _selectedDays = parsed;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
