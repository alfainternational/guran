import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/dhikr_provider.dart';
import '../providers/gamification_provider.dart';
import '../models/dhikr.dart';
import '../widgets/dhikr_tracker_dialog.dart';

class EnhancedDhikrScreen extends StatefulWidget {
  const EnhancedDhikrScreen({super.key});

  @override
  State<EnhancedDhikrScreen> createState() => _EnhancedDhikrScreenState();
}

class _EnhancedDhikrScreenState extends State<EnhancedDhikrScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DhikrProvider>(context, listen: false).loadCustomDhikr();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              pinned: true,
              title: const Text('الأذكار'),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                      child: _buildDhikrSummary(theme),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                isScrollable: true,
                tabs: const [
                  Tab(icon: Icon(Icons.wb_sunny_rounded), text: 'الصباح'),
                  Tab(icon: Icon(Icons.nightlight_round), text: 'المساء'),
                  Tab(icon: Icon(Icons.auto_awesome_rounded), text: 'عامة'),
                  Tab(icon: Icon(Icons.edit_note_rounded), text: 'مخصص'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEnhancedDhikrList(DhikrData.morningAdhkar, theme),
            _buildEnhancedDhikrList(DhikrData.eveningAdhkar, theme),
            _buildEnhancedDhikrList(DhikrData.generalAdhkar, theme),
            _buildCustomDhikrList(theme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDhikrDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة ذكر', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDhikrSummary(ThemeData theme) {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        final todayCount = provider.getTodayCompletedCount();
        final morningProgress = provider.getMorningAdhkarProgress();
        final eveningProgress = provider.getEveningAdhkarProgress();

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'أذكار اليوم',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$todayCount ذكر مكتمل',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildMiniProgress('الصباح', morningProgress, Icons.wb_sunny_rounded),
            const SizedBox(width: 16),
            _buildMiniProgress('المساء', eveningProgress, Icons.nightlight_round),
          ],
        );
      },
    );
  }

  Widget _buildMiniProgress(String label, double progress, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
              Icon(icon, color: Colors.white, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCustomDhikrList(ThemeData theme) {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        final customAdhkar = provider.currentDhikrList.where((d) => d.isCustom).toList();

        if (customAdhkar.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد أذكار مخصصة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على + لإضافة ذكر جديد',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return _buildEnhancedDhikrList(customAdhkar, theme, isCustom: true);
      },
    );
  }

  Widget _buildEnhancedDhikrList(List<Dhikr> adhkar, ThemeData theme,
      {bool isCustom = false}) {
    return Consumer<DhikrProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adhkar.length,
          itemBuilder: (context, index) {
            final dhikr = adhkar[index];
            final isCompleted = provider.isDhikrCompletedToday(dhikr.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showEnhancedDhikrDetail(dhikr);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.colorScheme.primary.withOpacity(0.05)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted
                            ? theme.colorScheme.primary.withOpacity(0.3)
                            : theme.dividerColor.withOpacity(0.15),
                        width: isCompleted ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // النص العربي
                        Text(
                          dhikr.arabicText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.8,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (dhikr.translation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            dhikr.translation!,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        // شريط المعلومات
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${dhikr.repetitions} مرات',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Colors.green, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'مكتمل',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (isCustom && !isCompleted)
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red.shade300,
                                  size: 20,
                                ),
                                onPressed: () => _confirmDelete(dhikr.id),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEnhancedDhikrDetail(Dhikr dhikr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedDhikrDetailSheet(dhikr: dhikr),
    );
  }

  void _confirmDelete(String id) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الذكر'),
        content: const Text('هل أنت متأكد من حذف هذا الذكر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<DhikrProvider>(context, listen: false)
                  .deleteCustomDhikr(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDhikrDialog() {
    final theme = Theme.of(context);
    final textController = TextEditingController();
    final countController = TextEditingController(text: '33');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.add_circle_outline_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              const Text(
                'إضافة ذكر جديد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'نص الذكر',
                  hintText: 'مثال: سبحان الله وبحمده',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: countController,
                decoration: InputDecoration(
                  labelText: 'عدد المرات',
                  hintText: '33',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'إضافة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

/// شاشة تفاصيل الذكر المحسّنة
class _EnhancedDhikrDetailSheet extends StatefulWidget {
  final Dhikr dhikr;

  const _EnhancedDhikrDetailSheet({required this.dhikr});

  @override
  State<_EnhancedDhikrDetailSheet> createState() =>
      _EnhancedDhikrDetailSheetState();
}

class _EnhancedDhikrDetailSheetState extends State<_EnhancedDhikrDetailSheet>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetCount = widget.dhikr.repetitions ?? 1;
    final progress = _counter / targetCount;
    final isCompleted = _counter >= targetCount;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Consumer<DhikrProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 28),

                // النص العربي
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    widget.dhikr.arabicText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                if (widget.dhikr.translation != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.dhikr.translation!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // العداد الدائري المحسّن
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 10,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          color: isCompleted
                              ? Colors.green
                              : theme.colorScheme.primary,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_counter',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'من $targetCount',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // زر التسبيح المحسّن
                GestureDetector(
                  onTapDown: (_) => _pulseController.forward(),
                  onTapUp: (_) {
                    _pulseController.reverse();
                    _onTap(provider);
                  },
                  onTapCancel: () => _pulseController.reverse(),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isCompleted
                              ? [Colors.green, Colors.green.shade700]
                              : [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted
                                    ? Colors.green
                                    : theme.colorScheme.primary)
                                .withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : Icons.touch_app_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  isCompleted ? 'تم الانتهاء' : 'اضغط للتسبيح',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),

                const SizedBox(height: 24),

                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_counter > 0)
                      _buildControlButton(
                        icon: Icons.refresh_rounded,
                        label: 'إعادة',
                        onTap: () {
                          setState(() => _counter = 0);
                          HapticFeedback.lightImpact();
                        },
                        theme: theme,
                      ),
                    _buildControlButton(
                      icon: Icons.alarm_add_rounded,
                      label: 'تذكيري',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => DhikrTrackerDialog(
                            dhikrId: widget.dhikr.id,
                            dhikrName: widget.dhikr.arabicText,
                          ),
                        );
                      },
                      theme: theme,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _onTap(DhikrProvider provider) {
    if (_counter < (widget.dhikr.repetitions ?? 1)) {
      HapticFeedback.lightImpact();
      setState(() {
        _counter++;
      });

      if (_counter == (widget.dhikr.repetitions ?? 1)) {
        _completeDhikr(provider);
      }
    }
  }

  void _completeDhikr(DhikrProvider provider) {
    HapticFeedback.heavyImpact();
    provider.completeDhikr(widget.dhikr.id, _counter);

    // إضافة نقاط gamification
    try {
      final gamProvider = Provider.of<GamificationProvider>(
        context,
        listen: false,
      );
      gamProvider.recordDhikrCompletion();
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('بارك الله فيك! أكملت الذكر'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
