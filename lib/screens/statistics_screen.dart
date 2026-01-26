import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../providers/dhikr_provider.dart';
import '../providers/profile_provider.dart';
import '../models/medal.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إحصائيات القراءة
            _buildSectionTitle('إحصائيات القراءة'),
            _buildReadingStats(),
            const SizedBox(height: 24),

            // إحصائيات الأذكار
            _buildSectionTitle('إحصائيات الأذكار'),
            _buildDhikrStats(),
            const SizedBox(height: 24),

            // الإنجازات
            _buildSectionTitle('الإنجازات'),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReadingStats() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final progress = provider.userProgress;

        if (progress == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('لا توجد بيانات بعد'),
            ),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'إجمالي الآيات',
                    '${progress.totalAyahsRead}',
                    Icons.book,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'الوقت الكلي',
                    '${progress.totalMinutesSpent} د',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'السلسلة الحالية',
                    '${progress.currentStreak} يوم',
                    Icons.local_fire_department,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'أطول سلسلة',
                    '${progress.longestStreak} يوم',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // التقدم في الأجزاء
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الأجزاء المكتملة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        final juzNumber = index + 1;
                        final isCompleted =
                            progress.completedJuzs[juzNumber] ?? false;

                        return Container(
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFF1B5E20)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$juzNumber',
                              style: TextStyle(
                                color: isCompleted ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.completionPercentage / 100,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF1B5E20),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '${progress.completionPercentage.toStringAsFixed(1)}% مكتمل',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDhikrStats() {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        final todayCount = provider.getTodayCompletedCount();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'أذكار اليوم',
                    '$todayCount',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'إجمالي الأذكار',
                    '${provider.progress?.totalDhikrCount ?? 0}',
                    Icons.format_quote,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // تقدم الأذكار
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDhikrProgressRow(
                      'أذكار الصباح',
                      provider.getMorningAdhkarProgress(),
                      Icons.wb_sunny,
                    ),
                    const SizedBox(height: 12),
                    _buildDhikrProgressRow(
                      'أذكار المساء',
                      provider.getEveningAdhkarProgress(),
                      Icons.nightlight_round,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrProgressRow(
    String title,
    double progress,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF1B5E20),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Consumer2<ReadingProvider, ProfileProvider>(
      builder: (context, readingProvider, profileProvider, _) {
        final profile = profileProvider.profile;
        final allMedals = MedalService.getInitialMedals();

        return Column(
          children: allMedals.map((medal) {
            final isUnlocked =
                profile?.unlockedMedalIds.contains(medal.id) ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isUnlocked
                      ? MedalService.getTierColor(medal.tier).withOpacity(0.2)
                      : Colors.grey[200],
                  child: Icon(
                    medal.icon,
                    color: isUnlocked
                        ? MedalService.getTierColor(medal.tier)
                        : Colors.grey,
                  ),
                ),
                title: Text(
                  medal.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black : Colors.grey,
                  ),
                ),
                subtitle: Text(medal.description),
                trailing: isUnlocked
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.lock_outline, color: Colors.grey),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
