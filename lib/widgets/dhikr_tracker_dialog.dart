import 'package:flutter/material.dart';
import '../models/dhikr_tracker.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class DhikrTrackerDialog extends StatefulWidget {
  final String dhikrId;
  final String dhikrName;

  const DhikrTrackerDialog({
    super.key,
    required this.dhikrId,
    required this.dhikrName,
  });

  @override
  State<DhikrTrackerDialog> createState() => _DhikrTrackerDialogState();
}

class _DhikrTrackerDialogState extends State<DhikrTrackerDialog> {
  final TextEditingController _targetController =
      TextEditingController(text: '100');
  int _intervalMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تتبع الذكر وتذكيري'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الذكر: ${widget.dhikrName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'العدد المطلوب',
                border: OutlineInputBorder(),
                suffixText: 'مرة',
              ),
            ),
            const SizedBox(height: 16),
            const Text('تذكيري كل:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _intervalMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 دقيقة')),
                DropdownMenuItem(value: 30, child: Text('30 دقيقة')),
                DropdownMenuItem(value: 60, child: Text('ساعة واحدة')),
                DropdownMenuItem(value: 120, child: Text('ساعتين')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _intervalMinutes = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveTracker,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
          ),
          child: const Text('بدء التتبع'),
        ),
      ],
    );
  }

  Future<void> _saveTracker() async {
    final target = int.tryParse(_targetController.text);
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال عدد صحيح')),
      );
      return;
    }

    final tracker = DhikrTracker(
      id: const Uuid().v4(),
      dhikrId: widget.dhikrId,
      dhikrName: widget.dhikrName,
      targetCount: target,
      startedAt: DateTime.now(),
      reminderIntervalMinutes: _intervalMinutes,
    );

    // حفظ في قاعدة البيانات direct execution via service helper if needed or direct DB
    final db = DatabaseService();
    final database = await db.database;
    await database.insert('dhikr_trackers', tracker.toJson());

    // جدولة التنبيه الأول
    await NotificationService().scheduleDhikrTrackerReminder(
      dhikrId: tracker.id,
      dhikrName: tracker.dhikrName,
      currentCount: 0,
      targetCount: tracker.targetCount,
      interval: Duration(minutes: tracker.reminderIntervalMinutes),
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تفعيل تتبع الذكر وتجدول التنبيهات')),
      );
    }
  }
}
