import 'package:flutter/material.dart';
import '../../models/gamification.dart';
import '../../theme/app_colors.dart';

/// Widget لعرض المستوى الحالي والتقدم
class LevelDisplayWidget extends StatefulWidget {
  final int totalPoints;
  final bool showDetails;
  final bool compact;
  final VoidCallback? onTap;

  const LevelDisplayWidget({
    super.key,
    required this.totalPoints,
    this.showDetails = true,
    this.compact = false,
    this.onTap,
  });

  @override
  State<LevelDisplayWidget> createState() => _LevelDisplayWidgetState();
}

class _LevelDisplayWidgetState extends State<LevelDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final progress = UserLevel.getProgressToNextLevel(widget.totalPoints);
    _progressAnimation = Tween<double>(
      begin: 0,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(LevelDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalPoints != widget.totalPoints) {
      final progress = UserLevel.getProgressToNextLevel(widget.totalPoints);
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactVersion();
    }
    return _buildFullVersion();
  }

  Widget _buildCompactVersion() {
    final level = UserLevel.getLevelForPoints(widget.totalPoints);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: level.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: level.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              level.badge,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              'مستوى ${level.level}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: level.color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullVersion() {
    final level = UserLevel.getLevelForPoints(widget.totalPoints);
    final nextLevel = UserLevel.getNextLevel(widget.totalPoints);
    final pointsToNext = UserLevel.getPointsToNextLevel(widget.totalPoints);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Card(
              elevation: 6,
              shadowColor: level.color.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      level.color,
                      level.color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الصف العلوي
                    Row(
                      children: [
                        // أيقونة المستوى
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            level.badge,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // معلومات المستوى
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المستوى ${level.level}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                level.titleArabic,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // النقاط الكلية
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  color: AppColors.gold,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.totalPoints}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'نقطة',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // شريط التقدم والمعلومات الإضافية
                    if (widget.showDetails && nextLevel != null) ...[
                      const SizedBox(height: 20),

                      // وصف المستوى
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              level.icon,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                level.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // شريط التقدم
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'نحو ${nextLevel.titleArabic}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                '${(_progressAnimation.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressAnimation.value,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'باقي $pointsToNext نقطة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    nextLevel.badge,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    nextLevel.titleArabic,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget مصغر لعرض المستوى في شريط التطبيق
class LevelBadge extends StatelessWidget {
  final int totalPoints;
  final double size;
  final VoidCallback? onTap;

  const LevelBadge({
    super.key,
    required this.totalPoints,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final level = UserLevel.getLevelForPoints(totalPoints);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: level.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: level.color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            level.badge,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }
}
