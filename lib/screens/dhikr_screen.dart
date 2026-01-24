import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dhikr_provider.dart';
import '../models/dhikr.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: Color(0xFF1B5E20),
              tabs: [
                Tab(text: 'الصباح'),
                Tab(text: 'المساء'),
                Tab(text: 'عامة'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDhikrList(DhikrData.morningAdhkar),
                  _buildDhikrList(DhikrData.eveningAdhkar),
                  _buildDhikrList(DhikrData.generalAdhkar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrList(List<Dhikr> adhkar) {
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
              child: InkWell(
                onTap: () => _showDhikrDetail(dhikr),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dhikr.arabicText,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.8,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.green[700],
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      if (dhikr.translation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          dhikr.translation!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (dhikr.repetitions != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.repeat, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'التكرار: ${dhikr.repetitions} مرة',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (dhikr.reference != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'المصدر: ${dhikr.reference}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
                        color: Colors.black.withOpacity(0.2),
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

              // زر إعادة التعيين
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
