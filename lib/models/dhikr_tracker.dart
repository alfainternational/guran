/// نموذج متتبع الذكر المخصص
class DhikrTracker {
  final String id;
  final String dhikrId;
  final String dhikrName;
  final int targetCount;
  final int currentCount;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int reminderIntervalMinutes; // الفاصل الزمني بالدقائق
  final bool isActive;

  DhikrTracker({
    required this.id,
    required this.dhikrId,
    required this.dhikrName,
    required this.targetCount,
    this.currentCount = 0,
    required this.startedAt,
    this.completedAt,
    this.reminderIntervalMinutes = 30,
    this.isActive = true,
  });

  bool get isCompleted => currentCount >= targetCount;
  int get remainingCount => targetCount - currentCount;
  double get progress => targetCount > 0 ? currentCount / targetCount : 0.0;

  factory DhikrTracker.fromJson(Map<String, dynamic> json) {
    return DhikrTracker(
      id: json['id'] as String,
      dhikrId: json['dhikr_id'] as String,
      dhikrName: json['dhikr_name'] as String,
      targetCount: json['target_count'] as int,
      currentCount: json['current_count'] as int,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      reminderIntervalMinutes: json['reminder_interval'] as int,
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dhikr_id': dhikrId,
      'dhikr_name': dhikrName,
      'target_count': targetCount,
      'current_count': currentCount,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'reminder_interval': reminderIntervalMinutes,
      'is_active': isActive ? 1 : 0,
    };
  }

  DhikrTracker copyWith({
    String? id,
    String? dhikrId,
    String? dhikrName,
    int? targetCount,
    int? currentCount,
    DateTime? startedAt,
    DateTime? completedAt,
    int? reminderIntervalMinutes,
    bool? isActive,
  }) {
    return DhikrTracker(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
      dhikrName: dhikrName ?? this.dhikrName,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      isActive: isActive ?? this.isActive,
    );
  }
}
