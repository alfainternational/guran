import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../providers/dhikr_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/gamification_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common/welcome_card.dart';
import '../widgets/common/animated_progress_card.dart';
import '../widgets/common/level_display_widget.dart';
import '../widgets/common/challenge_card.dart';

/// الصفحة الرئيسية المحسّنة
class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _initializeData,
        color: AppColors.primaryGreen,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // AppBar مخصص
            _buildSliverAppBar(isDark),

            // المحتوى
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // بطاقة الترحيب
                  _buildWelcomeSection(),
                  const SizedBox(height: 20),

                  // المستوى والنقاط
                  _buildLevelSection(),
                  const SizedBox(height: 20),

                  // التقدم اليومي
                  _buildDailyProgressSection(),
                  const SizedBox(height: 20),

                  // التحديات
                  _buildChallengesSection(),
                  const SizedBox(height: 20),

                  // أذكار اليوم
                  _buildDhikrSection(),
                  const SizedBox(height: 20),

                  // الإحصائيات السريعة
                  _buildQuickStatsSection(),
                  const SizedBox(height: 100), // مساحة للـ Navigation Bar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'ختمتي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primaryGreen,
            ),
          ),
        ],
      ),
      actions: [
        // زر الإشعارات
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // فتح الإشعارات
          },
        ),
        // زر الإعدادات
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        if (profile == null) return const SizedBox.shrink();

        return EnhancedWelcomeCard(
          userName: profile.name,
          consecutiveDays: profile.consecutiveDays,
          totalPoints: 0, // سيتم ربطه بـ GamificationProvider
          onProfileTap: () => _showProfileDialog(),
          onStreakTap: () => _showStreakDetails(),
        );
      },
    );
  }

  Widget _buildLevelSection() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        // في المستقبل سيتم استخدام GamificationProvider
        final totalPoints = (profileProvider.profile?.consecutiveDays ?? 0) * 30;

        return LevelDisplayWidget(
          totalPoints: totalPoints,
          showDetails: true,
          onTap: () => _showLevelDetails(),
        );
      },
    );
  }

  Widget _buildDailyProgressSection() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final todayPortion = provider.getTodayPortion();
        final isCompleted = provider.isTodayCompleted();
        final plan = provider.activePlan;
        final progress = provider.userProgress;

        if (todayPortion == null) {
          return _buildNoPlanCard();
        }

        final completionPercentage = progress?.completionPercentage ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today_rounded,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'قراءة اليوم',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'مكتمل',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // بطاقة التقدم
            AnimatedProgressCard(
              progress: completionPercentage / 100,
              title: todayPortion.startJuz != null
                  ? 'الجزء ${todayPortion.startJuz}'
                  : 'السورة ${todayPortion.startSurah}',
              subtitle: 'حوالي ${todayPortion.estimatedMinutes} دقيقة',
              icon: Icons.menu_book_rounded,
              progressColor: isCompleted ? AppColors.success : AppColors.primaryGreen,
              onTap: () => Navigator.pushNamed(context, '/reading'),
            ),

            // معلومات الخطة
            if (plan != null) ...[
              const SizedBox(height: 12),
              _buildPlanInfoCard(plan, progress),
            ],

            // زر البدء
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/reading'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('ابدأ القراءة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoPlanCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ابدأ رحلتك القرآنية',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أنشئ خطة ختم مخصصة لك',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/plan-setup'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('إنشاء خطة جديدة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfoCard(dynamic plan, dynamic progress) {
    final daysLeft = plan.targetEndDate.difference(DateTime.now()).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.calendar_today_rounded,
                value: '$daysLeft',
                label: 'يوم متبقي',
                color: AppColors.info,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.trending_up_rounded,
                value: '${(progress?.completionPercentage ?? 0).toStringAsFixed(0)}%',
                label: 'مكتمل',
                color: AppColors.success,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.book_rounded,
                value: '${progress?.completedJuzs.values.where((v) => v).length ?? 0}',
                label: 'جزء',
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesSection() {
    // استخدام تحديات افتراضية حتى يتم ربط GamificationProvider
    final challenges = [
      _MockChallenge(
        title: 'القارئ النشيط',
        description: 'اقرأ صفحة واحدة',
        progress: 0,
        target: 1,
        points: 25,
        icon: Icons.menu_book_rounded,
        color: AppColors.primaryGreen,
      ),
      _MockChallenge(
        title: 'المسبّح',
        description: 'أكمل أذكار الصباح أو المساء',
        progress: 0,
        target: 1,
        points: 20,
        icon: Icons.format_quote_rounded,
        color: AppColors.eveningColor,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تحديات اليوم',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // عرض كل التحديات
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...challenges.map((c) => _buildMockChallengeCard(c)),
      ],
    );
  }

  Widget _buildMockChallengeCard(_MockChallenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: challenge.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                challenge.icon,
                color: challenge.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: challenge.progress / challenge.target,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(challenge.color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.gold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.points}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrSection() {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        final morningProgress = provider.getMorningAdhkarProgress();
        final eveningProgress = provider.getEveningAdhkarProgress();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: AppColors.eveningColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'أذكار اليوم',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // الانتقال لشاشة الأذكار
                  },
                  child: const Text('المزيد'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDhikrCard(
                    title: 'أذكار الصباح',
                    progress: morningProgress,
                    icon: Icons.wb_sunny_rounded,
                    gradient: AppColors.morningGradient,
                    onTap: () {
                      // فتح أذكار الصباح
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDhikrCard(
                    title: 'أذكار المساء',
                    progress: eveningProgress,
                    icon: Icons.nightlight_rounded,
                    gradient: AppColors.eveningGradient,
                    onTap: () {
                      // فتح أذكار المساء
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDhikrCard({
    required String title,
    required double progress,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: gradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final progress = provider.userProgress;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: AppColors.info,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'إحصائيات سريعة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AnimatedStatCard(
                    title: 'الآيات المقروءة',
                    value: '${progress?.totalAyahsRead ?? 0}',
                    icon: Icons.format_list_numbered_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedStatCard(
                    title: 'وقت القراءة',
                    value: '${progress?.totalMinutesSpent ?? 0}د',
                    icon: Icons.timer_rounded,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AnimatedStatCard(
                    title: 'أطول سلسلة',
                    value: '${progress?.longestStreak ?? 0}',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.gold,
                    subtitle: 'يوم',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedStatCard(
                    title: 'الجلسات',
                    value: '${progress?.completedJuzs.values.where((v) => v).length ?? 0}',
                    icon: Icons.repeat_rounded,
                    color: AppColors.success,
                    subtitle: 'جزء مكتمل',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog() {
    // عرض نافذة الملف الشخصي
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _ProfileBottomSheet(),
    );
  }

  void _showStreakDetails() {
    // عرض تفاصيل السلسلة
  }

  void _showLevelDetails() {
    // عرض تفاصيل المستوى
  }
}

class _MockChallenge {
  final String title;
  final String description;
  final int progress;
  final int target;
  final int points;
  final IconData icon;
  final Color color;

  _MockChallenge({
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.points,
    required this.icon,
    required this.color,
  });
}

class _ProfileBottomSheet extends StatelessWidget {
  const _ProfileBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

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

              // الصورة الرمزية
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: Text(
                  profile?.name.isNotEmpty == true
                      ? profile!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // الاسم
              Text(
                profile?.name ?? 'ضيف',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // معلومات إضافية
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (profile?.age != null && profile!.age > 0) ...[
                    Icon(Icons.cake_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.age} سنة',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: AppColors.streakFire,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${profile?.consecutiveDays ?? 0} يوم متتالي',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // أزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // فتح إعدادات الملف الشخصي
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('الإعدادات'),
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
}
