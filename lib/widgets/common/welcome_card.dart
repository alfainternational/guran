import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/motivational_messages.dart';

/// بطاقة الترحيب المحسّنة
class EnhancedWelcomeCard extends StatefulWidget {
  final String userName;
  final int consecutiveDays;
  final int totalPoints;
  final VoidCallback? onProfileTap;
  final VoidCallback? onStreakTap;

  const EnhancedWelcomeCard({
    super.key,
    required this.userName,
    required this.consecutiveDays,
    required this.totalPoints,
    this.onProfileTap,
    this.onStreakTap,
  });

  @override
  State<EnhancedWelcomeCard> createState() => _EnhancedWelcomeCardState();
}

class _EnhancedWelcomeCardState extends State<EnhancedWelcomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;

    // تحديد التحية والألوان حسب الوقت
    final (greeting, timeIcon, gradientColors) = _getTimeBasedData(hour);
    final message =
        MotivationalMessages.getRandomMessage(MessageTrigger.appOpen);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 8,
          shadowColor: gradientColors[0].withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // الزخارف الخلفية
                _buildBackgroundDecorations(),

                // المحتوى
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الصف العلوي
                      Row(
                        children: [
                          // أيقونة الوقت
                          GestureDetector(
                            onTap: widget.onProfileTap,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                timeIcon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // عداد الأيام المتتالية
                          _buildStreakBadge(),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // التحية
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // الرسالة التحفيزية
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.format_quote_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message.arabicText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          right: -40,
          top: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          right: 50,
          bottom: 20,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge() {
    final days = widget.consecutiveDays;
    Color badgeColor;
    IconData badgeIcon;
    String label;

    if (days >= 30) {
      badgeColor = AppColors.gold;
      badgeIcon = Icons.local_fire_department_rounded;
      label = 'ملتزم';
    } else if (days >= 7) {
      badgeColor = Colors.orange;
      badgeIcon = Icons.whatshot_rounded;
      label = 'متحمس';
    } else if (days >= 3) {
      badgeColor = Colors.amber;
      badgeIcon = Icons.local_fire_department_rounded;
      label = 'مبشر';
    } else {
      badgeColor = Colors.white;
      badgeIcon = Icons.local_fire_department_rounded;
      label = '';
    }

    return GestureDetector(
      onTap: widget.onStreakTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: badgeColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badgeIcon, color: badgeColor, size: 22),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$days',
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1,
                  ),
                ),
                Text(
                  days == 1 ? 'يوم' : 'يوم',
                  style: TextStyle(
                    color: badgeColor.withOpacity(0.8),
                    fontSize: 11,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String, IconData, List<Color>) _getTimeBasedData(int hour) {
    if (hour >= 5 && hour < 12) {
      return (
        'صباح الخير والبركة',
        Icons.wb_sunny_rounded,
        [const Color(0xFF1B5E20), const Color(0xFF43A047)],
      );
    } else if (hour >= 12 && hour < 15) {
      return (
        'طاب يومك بذكر الله',
        Icons.light_mode_rounded,
        [const Color(0xFF0D5C4D), const Color(0xFF2E7D6E)],
      );
    } else if (hour >= 15 && hour < 18) {
      return (
        'مساء الخير والسعادة',
        Icons.wb_twilight_rounded,
        [const Color(0xFF5D4037), const Color(0xFF8D6E63)],
      );
    } else if (hour >= 18 && hour < 21) {
      return (
        'مساء النور والسرور',
        Icons.nights_stay_rounded,
        [const Color(0xFF1A237E), const Color(0xFF3949AB)],
      );
    } else {
      return (
        'طاب وقتك بذكر الله',
        Icons.nightlight_round,
        [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
      );
    }
  }
}

/// بطاقة ترحيب مصغرة
class CompactWelcomeCard extends StatelessWidget {
  final String userName;
  final int consecutiveDays;
  final VoidCallback? onTap;

  const CompactWelcomeCard({
    super.key,
    required this.userName,
    required this.consecutiveDays,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء النور';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting، $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'استمر في رحلتك القرآنية',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (consecutiveDays > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: consecutiveDays >= 7
                          ? AppColors.gold
                          : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$consecutiveDays',
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
      ),
    );
  }
}
