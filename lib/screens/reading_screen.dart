import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../models/quran_data.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  int _selectedJuz = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القراءة'),
      ),
      body: Consumer<ReadingProvider>(
        builder: (context, provider, _) {
          final isReading = provider.isReading;

          return Column(
            children: [
              // معلومات الجلسة
              if (isReading) _buildSessionInfo(provider),

              // قائمة الأجزاء والسور
              Expanded(
                child: _buildQuranList(),
              ),

              // زر بدء/إنهاء القراءة
              _buildActionButton(provider, isReading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionInfo(ReadingProvider provider) {
    final session = provider.currentSession;
    if (session == null) return const SizedBox.shrink();

    final duration = DateTime.now().difference(session.startTime);
    final minutes = duration.inMinutes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFE8F5E9),
      child: Column(
        children: [
          const Text(
            'جلسة قراءة نشطة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'المدة: $minutes دقيقة',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranList() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF1B5E20),
            tabs: [
              Tab(text: 'الأجزاء'),
              Tab(text: 'السور'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildJuzList(),
                _buildSurahList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final surahs = QuranData.getSurahsByJuz(juzNumber);

        return Consumer<ReadingProvider>(
          builder: (context, provider, _) {
            final isCompleted =
                provider.userProgress?.completedJuzs[juzNumber] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isCompleted ? Colors.green : const Color(0xFF1B5E20),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : Text(
                          '$juzNumber',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                title: Text('الجزء $juzNumber'),
                subtitle: Text(
                  surahs.isNotEmpty
                      ? 'يبدأ من سورة ${surahs.first.nameArabic}'
                      : '',
                ),
                trailing: isCompleted
                    ? null
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  setState(() {
                    _selectedJuz = juzNumber;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      itemCount: QuranData.surahs.length,
      itemBuilder: (context, index) {
        final surah = QuranData.surahs[index];

        return Consumer<ReadingProvider>(
          builder: (context, provider, _) {
            final isCompleted =
                provider.userProgress?.completedSurahs[surah.number] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isCompleted ? Colors.green : const Color(0xFF1B5E20),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : Text(
                          '${surah.number}',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                title: Text(surah.nameArabic),
                subtitle: Text(
                  '${surah.revelationType} • ${surah.totalAyahs} آية',
                ),
                trailing: isCompleted
                    ? null
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // فتح صفحة قراءة السورة
                  _showSurahReader(surah);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(ReadingProvider provider, bool isReading) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            if (isReading) {
              _endSession(provider);
            } else {
              provider.startReadingSession();
            }
          },
          icon: Icon(isReading ? Icons.stop : Icons.play_arrow),
          label: Text(
            isReading ? 'إنهاء الجلسة' : 'بدء جلسة قراءة',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: isReading ? Colors.red : const Color(0xFF1B5E20),
          ),
        ),
      ),
    );
  }

  void _showSurahReader(Surah surah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(surah.nameArabic),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${surah.revelationType} • ${surah.totalAyahs} آية'),
            const SizedBox(height: 16),
            const Text(
              'ملاحظة: في التطبيق الكامل، سيتم عرض نص القرآن الكريم هنا',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = context.read<ReadingProvider>();
              provider.completeSurah(surah.number);
            },
            child: const Text('تم القراءة'),
          ),
        ],
      ),
    );
  }

  void _endSession(ReadingProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        int ayahsRead = 20;
        return AlertDialog(
          title: const Text('إنهاء الجلسة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كم آية قرأت؟'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'عدد الآيات',
                ),
                onChanged: (value) {
                  ayahsRead = int.tryParse(value) ?? 20;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                provider.endReadingSession(
                  ayahsRead: ayahsRead,
                  surahsRead: [_selectedJuz],
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
