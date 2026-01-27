import 'package:flutter/material.dart';
import '../../models/gamification.dart';
import '../../theme/app_colors.dart';

/// بطاقة عرض التحدي
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;
  final bool showProgress;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = challenge.isCompleted;

    return Card(
      elevation: isCompleted ? 1 : 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة التحدي
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.15)
                          : challenge.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_rounded : challenge.icon,
                      color: isCompleted ? AppColors.success : challenge.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // العنوان والوصف
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                challenge.titleArabic,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            // شارة الصعوبة
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: challenge.difficultyColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                challenge.difficultyArabic,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: challenge.difficultyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.descriptionArabic,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // النقاط أو علامة الإكمال
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold,
                            AppColors.goldLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.points}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // شريط التقدم
              if (showProgress && !isCompleted) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: challenge.progressPercentage,
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            challenge.color,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${challenge.progress}/${challenge.target}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: challenge.color,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// قائمة التحديات اليومية
class DailyChallengesList extends StatelessWidget {
  final List<Challenge> challenges;
  final String title;
  final VoidCallback? onViewAll;

  const DailyChallengesList({
    super.key,
    required this.challenges,
    this.title = 'تحديات اليوم',
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed = challenges.where((c) => c.isCompleted).length;
    final total = challenges.length;

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
                  Icons.flag_rounded,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: completed == total
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completed/$total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: completed == total
                          ? AppColors.success
                          : AppColors.primaryGreen,
                    ),
                  ),
                ),
                if (onViewAll != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onViewAll,
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // قائمة التحديات
        ...challenges.map((challenge) => ChallengeCard(challenge: challenge)),
      ],
    );
  }
}

/// Widget ملخص التحديات
class ChallengesSummary extends StatelessWidget {
  final List<Challenge> challenges;
  final VoidCallback? onTap;

  const ChallengesSummary({
    super.key,
    required this.challenges,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed = challenges.where((c) => c.isCompleted).length;
    final total = challenges.length;
    final progress = total > 0 ? completed / total : 0.0;
    final totalPoints = challenges
        .where((c) => !c.isCompleted)
        .fold<int>(0, (sum, c) => sum + c.points);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen.withOpacity(0.1),
                AppColors.primaryGreen.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // دائرة التقدم
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed == total
                            ? AppColors.success
                            : AppColors.primaryGreen,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$completed/$total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحديات اليوم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (completed == total)
                      Row(
                        children: [
                          Icon(
                            Icons.celebration_rounded,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'أكملت جميع التحديات!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'باقي ${total - completed} تحديات • $totalPoints نقطة متاحة',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),

              // السهم
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
