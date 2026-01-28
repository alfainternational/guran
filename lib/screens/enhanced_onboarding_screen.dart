import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';

/// شاشة الترحيب المحسّنة - 7 خطوات
class EnhancedOnboardingScreen extends StatefulWidget {
  const EnhancedOnboardingScreen({super.key});

  @override
  State<EnhancedOnboardingScreen> createState() =>
      _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState extends State<EnhancedOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  // بيانات المستخدم
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  Gender _selectedGender = Gender.male;
  ReadingLevel _readingLevel = ReadingLevel.beginner;
  List<UserGoal> _selectedGoals = [];
  int _selectedPlanDays = 30;
  List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 9, minute: 0)];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0: // الترحيب
        return true;
      case 1: // الميزات
        return true;
      case 2: // المعلومات الشخصية
        return _nameController.text.trim().isNotEmpty;
      case 3: // مستوى القراءة
        return true;
      case 4: // الأهداف
        return _selectedGoals.isNotEmpty;
      case 5: // الخطة
        return true;
      case 6: // التذكيرات
        return true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // شريط التقدم
              _buildProgressBar(),

              // المحتوى
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildFeaturesPage(),
                    _buildPersonalInfoPage(),
                    _buildReadingLevelPage(),
                    _buildGoalsPage(),
                    _buildPlanPage(),
                    _buildRemindersPage(),
                  ],
                ),
              ),

              // أزرار التنقل
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(7, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? AppColors.primaryGreen
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==================== الصفحة 1: الترحيب ====================
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // الأيقونة الرئيسية
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppColors.glowShadow,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          // العنوان
          const Text(
            'مرحباً بك في ختمتي',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // الوصف
          Text(
            'رفيقك الأمين في رحلة القرآن الكريم والأذكار اليومية',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // النقاط الرئيسية
          _buildHighlightItem(
            icon: Icons.auto_stories_rounded,
            title: 'ختم القرآن',
            description: 'خطط مرنة تناسب جدولك',
          ),
          _buildHighlightItem(
            icon: Icons.format_quote_rounded,
            title: 'الأذكار اليومية',
            description: 'أذكار الصباح والمساء مع عداد تفاعلي',
          ),
          _buildHighlightItem(
            icon: Icons.emoji_events_rounded,
            title: 'تحفيز مستمر',
            description: 'نقاط وإنجازات تشجعك على الاستمرار',
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== الصفحة 2: الميزات ====================
  Widget _buildFeaturesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Icon(
            Icons.stars_rounded,
            size: 80,
            color: AppColors.gold,
          ),
          const SizedBox(height: 24),

          const Text(
            'اكتشف الميزات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            'أدوات ذكية لمساعدتك في رحلتك',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _buildFeatureCard(
            icon: Icons.calendar_month_rounded,
            title: 'خطط مرنة',
            description: 'اختر مدة الختم التي تناسبك (7-90 يوم)',
            color: AppColors.primaryGreen,
          ),
          _buildFeatureCard(
            icon: Icons.notifications_active_rounded,
            title: 'تذكيرات ذكية',
            description: 'تنبيهات مخصصة للقراءة والأذكار',
            color: AppColors.info,
          ),
          _buildFeatureCard(
            icon: Icons.bar_chart_rounded,
            title: 'إحصائيات تفصيلية',
            description: 'تابع تقدمك وإنجازاتك',
            color: AppColors.warning,
          ),
          _buildFeatureCard(
            icon: Icons.emoji_events_rounded,
            title: 'نظام مكافآت',
            description: 'اكسب نقاط ومستويات وشارات',
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

  // ==================== الصفحة 3: المعلومات الشخصية ====================
  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'من أنت؟',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'نود التعرف عليك لتقديم تجربة مخصصة',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // الاسم
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'اسمك الكريم',
              hintText: 'أدخل اسمك',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // العمر
          TextField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: 'العمر (اختياري)',
              hintText: 'أدخل عمرك',
              prefixIcon: const Icon(Icons.cake_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          // الجنس
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الجنس',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  gender: Gender.male,
                  icon: Icons.male_rounded,
                  label: 'ذكر',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderOption(
                  gender: Gender.female,
                  icon: Icons.female_rounded,
                  label: 'أنثى',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required Gender gender,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : AppColors.primaryGreen,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== الصفحة 4: مستوى القراءة ====================
  Widget _buildReadingLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 60,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'ما مستوى قراءتك الحالي؟',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'سنقترح لك خطة مناسبة بناءً على ذلك',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _buildLevelOption(
            level: ReadingLevel.beginner,
            title: 'مبتدئ',
            description: 'لا أقرأ القرآن بانتظام',
            icon: Icons.eco_rounded,
            color: Colors.green[400]!,
          ),
          _buildLevelOption(
            level: ReadingLevel.intermediate,
            title: 'متوسط',
            description: 'أقرأ أحياناً ولكن بدون التزام',
            icon: Icons.spa_rounded,
            color: Colors.blue[400]!,
          ),
          _buildLevelOption(
            level: ReadingLevel.advanced,
            title: 'متقدم',
            description: 'أقرأ يومياً بانتظام',
            icon: Icons.star_rounded,
            color: Colors.purple[400]!,
          ),
          _buildLevelOption(
            level: ReadingLevel.hafiz,
            title: 'حافظ',
            description: 'أحفظ القرآن وأريد المراجعة',
            icon: Icons.workspace_premium_rounded,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelOption({
    required ReadingLevel level,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _readingLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _readingLevel = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== الصفحة 5: الأهداف ====================
  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 60,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'ما أهدافك؟',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر واحداً أو أكثر',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          _buildGoalOption(
            goal: UserGoal.khatma,
            title: 'ختم القرآن الكريم',
            description: 'إتمام قراءة القرآن كاملاً',
            icon: Icons.menu_book_rounded,
          ),
          _buildGoalOption(
            goal: UserGoal.adhkar,
            title: 'المحافظة على الأذكار',
            description: 'أذكار الصباح والمساء يومياً',
            icon: Icons.format_quote_rounded,
          ),
          _buildGoalOption(
            goal: UserGoal.memorization,
            title: 'الحفظ والمراجعة',
            description: 'حفظ آيات جديدة ومراجعة المحفوظ',
            icon: Icons.psychology_rounded,
          ),
          _buildGoalOption(
            goal: UserGoal.habit,
            title: 'بناء عادة يومية',
            description: 'جعل القراءة جزءاً من يومي',
            icon: Icons.repeat_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required UserGoal goal,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedGoals.contains(goal);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGoals.remove(goal);
          } else {
            _selectedGoals.add(goal);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== الصفحة 6: الخطة ====================
  Widget _buildPlanPage() {
    final recommendedPlan = _getRecommendedPlan();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 60,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'اختر خطة الختم',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'بناءً على مستواك، نقترح خطة ${recommendedPlan} يوم',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _buildPlanOption(7, 'أسبوع', 'مكثفة - للمتقدمين', recommendedPlan == 7),
          _buildPlanOption(14, 'أسبوعين', 'سريعة', recommendedPlan == 14),
          _buildPlanOption(30, 'شهر', 'متوازنة - موصى بها للمبتدئين', recommendedPlan == 30),
          _buildPlanOption(60, 'شهرين', 'مريحة', recommendedPlan == 60),
          _buildPlanOption(90, '3 أشهر', 'هادئة - صفحة يومياً', recommendedPlan == 90),
        ],
      ),
    );
  }

  int _getRecommendedPlan() {
    switch (_readingLevel) {
      case ReadingLevel.beginner:
        return 60;
      case ReadingLevel.intermediate:
        return 30;
      case ReadingLevel.advanced:
        return 14;
      case ReadingLevel.hafiz:
        return 7;
    }
  }

  Widget _buildPlanOption(int days, String title, String description, bool isRecommended) {
    final isSelected = _selectedPlanDays == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanDays = days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : isRecommended
                    ? AppColors.gold
                    : Colors.grey[200]!,
            width: isSelected || isRecommended ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$days',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'موصى به',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  // ==================== الصفحة 7: التذكيرات ====================
  Widget _buildRemindersPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 60,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'متى تريد التذكير؟',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سنذكرك بالقراءة والأذكار',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // أوقات مقترحة
          _buildReminderTimeOption(
            const TimeOfDay(hour: 6, minute: 0),
            'بعد الفجر',
            Icons.wb_twilight_rounded,
          ),
          _buildReminderTimeOption(
            const TimeOfDay(hour: 9, minute: 0),
            'صباحاً',
            Icons.wb_sunny_rounded,
          ),
          _buildReminderTimeOption(
            const TimeOfDay(hour: 14, minute: 0),
            'بعد الظهر',
            Icons.light_mode_rounded,
          ),
          _buildReminderTimeOption(
            const TimeOfDay(hour: 18, minute: 0),
            'قبل المغرب',
            Icons.wb_twilight_rounded,
          ),
          _buildReminderTimeOption(
            const TimeOfDay(hour: 21, minute: 0),
            'مساءً',
            Icons.nightlight_rounded,
          ),

          const SizedBox(height: 24),

          // زر إضافة وقت مخصص
          OutlinedButton.icon(
            onPressed: _pickCustomTime,
            icon: const Icon(Icons.add_alarm_rounded),
            label: const Text('إضافة وقت مخصص'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimeOption(TimeOfDay time, String label, IconData icon) {
    final isSelected = _reminderTimes.any((t) =>
        t.hour == time.hour && t.minute == time.minute);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _reminderTimes.removeWhere((t) =>
                t.hour == time.hour && t.minute == time.minute);
          } else {
            _reminderTimes.add(time);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.info.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.info : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.info : Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.info : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.info : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickCustomTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        if (!_reminderTimes.any((t) =>
            t.hour == time.hour && t.minute == time.minute)) {
          _reminderTimes.add(time);
        }
      });
    }
  }

  // ==================== أزرار التنقل ====================
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('السابق'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canProceed()
                  ? (_isSaving ? null : _nextPage)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentPage == 6 ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final age = int.tryParse(_ageController.text) ?? 0;
      final profile = UserProfile(
        name: _nameController.text.trim(),
        age: age,
        gender: _selectedGender,
      );

      final error = await context.read<ProfileProvider>().saveProfile(profile);

      if (error == null && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ البيانات: $error')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

// ==================== Enums ====================
enum ReadingLevel {
  beginner,
  intermediate,
  advanced,
  hafiz,
}

enum UserGoal {
  khatma,
  adhkar,
  memorization,
  habit,
}
