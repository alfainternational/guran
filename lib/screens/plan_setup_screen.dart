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
  PlanType _selectedType = PlanType.byJuz;

  final List<int> _daysOptions = [7, 14, 30, 60, 90];

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

            const SizedBox(height: 24),

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
                      'القراءة اليومية:',
                      _selectedType == PlanType.byJuz
                          ? '${(30 / _selectedDays).toStringAsFixed(1)} جزء'
                          : '${(114 / _selectedDays).ceil()} سورة',
                    ),
                    _buildInfoRow(
                      'الوقت المتوقع يومياً:',
                      '${(600 / _selectedDays).ceil()} دقيقة',
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
        numberOfDays: _selectedDays,
        planType: _selectedType,
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
}
