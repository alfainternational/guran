import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../providers/dhikr_provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';
import '../models/motivational_messages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final readingProvider = context.read<ReadingProvider>();
    final dhikrProvider = context.read<DhikrProvider>();
    final profileProvider = context.read<ProfileProvider>();

    await readingProvider.loadActivePlan();
    await readingProvider.loadUserProgress('user_001');
    await dhikrProvider.loadProgress('user_001');
    await profileProvider.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ختمتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'الملف الشخصي',
            onPressed: _showProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رسالة ترحيب
              _buildWelcomeCard(),
              const SizedBox(height: 16),

              // التقدم اليومي
              _buildDailyProgress(),
              const SizedBox(height: 16),

              // الخطة الحالية
              _buildCurrentPlan(),
              const SizedBox(height: 16),

              // أذكار اليوم
              _buildTodayDhikr(),
              const SizedBox(height: 16),

              // إحصائيات سريعة
              _buildQuickStats(),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog() {
    final profileProvider = context.read<ProfileProvider>();
    final nameController =
        TextEditingController(text: profileProvider.profile?.name ?? '');
    final ageController = TextEditingController(
        text: profileProvider.profile?.age.toString() ?? '');
    Gender selectedGender = profileProvider.profile?.gender ?? Gender.male;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('الملف الشخصي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'العمر'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('الجنس'),
                Row(
                  children: [
                    Radio<Gender>(
                      value: Gender.male,
                      groupValue: selectedGender,
                      onChanged: (v) =>
                          setDialogState(() => selectedGender = v!),
                    ),
                    const Text('ذكر'),
                    Radio<Gender>(
                      value: Gender.female,
                      groupValue: selectedGender,
                      onChanged: (v) =>
                          setDialogState(() => selectedGender = v!),
                    ),
                    const Text('أنثى'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  profileProvider.saveProfile(UserProfile(
                    name: nameController.text,
                    age: int.tryParse(ageController.text) ?? 0,
                    gender: selectedGender,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        if (profile == null) return const SizedBox.shrink();

        final now = DateTime.now();
        final hour = now.hour;

        String dayGreeting;
        if (hour < 12) {
          dayGreeting = 'صباح الخير والبركة';
        } else if (hour < 17) {
          dayGreeting = 'مساء الخير والسرور';
        } else {
          dayGreeting = 'طاب مساؤك بذكر الله';
        }

        final message =
            MotivationalMessages.getRandomMessage(MessageTrigger.appOpen);

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [const Color(0xFF1B5E20), Colors.green[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$dayGreeting، ${profile.name} ✨',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.whatshot,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.consecutiveDays} يوم',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message.arabicText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyProgress() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final todayPortion = provider.getTodayPortion();
        final isCompleted = provider.isTodayCompleted();

        if (todayPortion == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_stories_outlined,
                    size: 48,
                    color: Color(0xFF1B5E20),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ابدأ خطة ختم جديدة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'حدد المدة التي تريد إتمام القرآن فيها',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/plan-setup');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إنشاء خطة جديدة'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'قراءة اليوم',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'مكتمل',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (todayPortion.startJuz != null)
                  Text(
                    'الجزء ${todayPortion.startJuz}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (todayPortion.startSurah != null)
                  Text(
                    'السورة ${todayPortion.startSurah}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'حوالي ${todayPortion.estimatedMinutes} دقيقة',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                if (!isCompleted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/reading');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('ابدأ القراءة'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPlan() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final plan = provider.activePlan;
        final progress = provider.userProgress;

        if (plan == null || progress == null) {
          return const SizedBox.shrink();
        }

        final daysLeft = plan.targetEndDate.difference(DateTime.now()).inDays;
        final completionPercentage = progress.completionPercentage;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الخطة الحالية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الأيام المتبقية'),
                        Text(
                          '$daysLeft يوم',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('نسبة الإنجاز'),
                        Text(
                          '${completionPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF1B5E20),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayDhikr() {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        final morningProgress = provider.getMorningAdhkarProgress();
        final eveningProgress = provider.getEveningAdhkarProgress();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أذكار اليوم',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDhikrProgressRow(
                  'أذكار الصباح',
                  morningProgress,
                  Icons.wb_sunny,
                ),
                const SizedBox(height: 12),
                _buildDhikrProgressRow(
                  'أذكار المساء',
                  eveningProgress,
                  Icons.nightlight_round,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDhikrProgressRow(String title, double progress, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
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

  Widget _buildQuickStats() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final progress = provider.userProgress;

        if (progress == null) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'السلسلة الحالية',
                '${progress.currentStreak} يوم',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'إجمالي الوقت',
                '${progress.totalMinutesSpent} دقيقة',
                Icons.timer,
                Colors.blue,
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
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
}
