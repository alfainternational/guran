import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dhikr_provider.dart';
import '../models/dhikr.dart';
import '../widgets/dhikr_tracker_dialog.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الأذكار المخصصة عند البدء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DhikrProvider>(context, listen: false).loadCustomDhikr();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار'),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'الصباح'),
              Tab(text: 'المساء'),
              Tab(text: 'عامة'),
              Tab(text: 'مخصص'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDhikrList(DhikrData.morningAdhkar),
            _buildDhikrList(DhikrData.eveningAdhkar),
            _buildDhikrList(DhikrData.generalAdhkar),
            _buildCustomDhikrList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDhikrDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCustomDhikrList() {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        final customAdhkar =
            provider.currentDhikrList.where((d) => d.isCustom).toList();

        if (customAdhkar.isEmpty) {
          return const Center(
            child: Text(
                'لا توجد أذكار مخصصة حالياً.\nاضغط على + لإضافة ذكر جديد.'),
          );
        }

        return _buildDhikrList(customAdhkar, isCustom: true);
      },
    );
  }

  Widget _buildDhikrList(List<Dhikr> adhkar, {bool isCustom = false}) {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adhkar.length,
          itemBuilder: (context, index) {
            final dhikr = adhkar[index];
            final isCompleted = provider.isDhikrCompletedToday(dhikr.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                onTap: () => _showDhikrDetail(dhikr),
                title: Text(
                  dhikr.arabicText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                  ),
                ),
                subtitle: dhikr.translation != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dhikr.translation!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${dhikr.repetitions} مرات',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '${dhikr.repetitions} مرات',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted)
                      const Icon(Icons.check_circle, color: Colors.green),
                    if (isCustom)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(dhikr.id),
                      ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الذكر'),
        content: const Text('هل أنت متأكد من حذف هذا الذكر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DhikrProvider>(context, listen: false)
                  .deleteCustomDhikr(id);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDhikrDialog() {
    final textController = TextEditingController();
    final countController = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ذكر جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'نص الذكر',
                hintText: 'مثال: سبحان الله وبحمده',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: countController,
              decoration:
                  const InputDecoration(labelText: 'عدد المرات (اختياري)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                final newDhikr = Dhikr(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  arabicText: textController.text.trim(),
                  repetitions: int.tryParse(countController.text) ?? 1,
                  category: DhikrCategory.custom,
                  isCustom: true,
                );
                Provider.of<DhikrProvider>(context, listen: false)
                    .addCustomDhikr(newDhikr);
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDhikrDetail(Dhikr dhikr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DhikrDetailSheet(dhikr: dhikr),
    );
  }
}

class _DhikrDetailSheet extends StatefulWidget {
  final Dhikr dhikr;

  const _DhikrDetailSheet({required this.dhikr});

  @override
  State<_DhikrDetailSheet> createState() => _DhikrDetailSheetState();
}

class _DhikrDetailSheetState extends State<_DhikrDetailSheet> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final targetCount = widget.dhikr.repetitions ?? 1;
    final progress = _counter / targetCount;

    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // النص العربي
              Text(
                widget.dhikr.arabicText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 2,
                ),
              ),

              if (widget.dhikr.translation != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.dhikr.translation!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // العداد الدائري
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$_counter',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        'من $targetCount',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // زر التسبيح
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_counter < targetCount) {
                      _counter++;
                    }

                    if (_counter == targetCount) {
                      _completeDhikr(provider);
                    }
                  });
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _counter >= targetCount
                        ? Colors.green
                        : const Color(0xFF1B5E20),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _counter >= targetCount
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 48,
                          )
                        : const Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 48,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // زر إعادة التعيين وتتبع التقدم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_counter > 0)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _counter = 0;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة'),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DhikrTrackerDialog(
                          dhikrId: widget.dhikr.id,
                          dhikrName: widget.dhikr.arabicText,
                        ),
                      );
                    },
                    icon: const Icon(Icons.alarm_add),
                    label: const Text('تذكيري'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _completeDhikr(DhikrProvider provider) {
    provider.completeDhikr(widget.dhikr.id, _counter);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('بارك الله فيك! أكملت الذكر ✨'),
        backgroundColor: Color(0xFF1B5E20),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
