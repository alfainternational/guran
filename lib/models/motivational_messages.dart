/// رسائل تحفيزية
class MotivationalMessage {
  final String id;
  final String arabicText;
  final MessageType type;
  final MessageTrigger trigger;

  const MotivationalMessage({
    required this.id,
    required this.arabicText,
    required this.type,
    required this.trigger,
  });
}

/// نوع الرسالة
enum MessageType {
  encouragement, // تشجيع
  reminder, // تذكير
  achievement, // إنجاز
  gentle, // لطيفة
  motivational, // تحفيزية
}

/// محفز الرسالة
enum MessageTrigger {
  appOpen, // فتح التطبيق
  afterReading, // بعد القراءة
  dailyStreak, // سلسلة يومية
  socialMediaDetected, // اكتشاف وسائل التواصل
  reminderTime, // وقت التذكير
  completedPortion, // إكمال جزء
  milestone, // معلم إنجاز
}

/// مجموعة الرسائل التحفيزية
class MotivationalMessages {
  static const List<MotivationalMessage> gentleReminders = [
    MotivationalMessage(
      id: 'gentle_1',
      arabicText: 'ما رأيك في قراءة بعض الآيات الآن؟ 📖',
      type: MessageType.gentle,
      trigger: MessageTrigger.socialMediaDetected,
    ),
    MotivationalMessage(
      id: 'gentle_2',
      arabicText: 'لديك بضع دقائق، لنقرأ قليلاً من القرآن ✨',
      type: MessageType.gentle,
      trigger: MessageTrigger.socialMediaDetected,
    ),
    MotivationalMessage(
      id: 'gentle_3',
      arabicText: 'القرآن ينتظرك، دعنا نقرأ آية أو آيتين 🌙',
      type: MessageType.gentle,
      trigger: MessageTrigger.socialMediaDetected,
    ),
    MotivationalMessage(
      id: 'gentle_4',
      arabicText: 'وقت جميل لقراءة القرآن، هل نبدأ؟ 🌟',
      type: MessageType.gentle,
      trigger: MessageTrigger.socialMediaDetected,
    ),
    MotivationalMessage(
      id: 'gentle_5',
      arabicText: 'دقائق قليلة من القرآن خير من ساعات في وسائل التواصل 💚',
      type: MessageType.gentle,
      trigger: MessageTrigger.socialMediaDetected,
    ),
  ];

  static const List<MotivationalMessage> achievements = [
    MotivationalMessage(
      id: 'achievement_1',
      arabicText: 'ما شاء الله! أكملت قراءة اليوم 🎉',
      type: MessageType.achievement,
      trigger: MessageTrigger.completedPortion,
    ),
    MotivationalMessage(
      id: 'achievement_2',
      arabicText: 'بارك الله فيك! أنت ملتزم بخطتك 💪',
      type: MessageType.achievement,
      trigger: MessageTrigger.completedPortion,
    ),
    MotivationalMessage(
      id: 'achievement_3',
      arabicText: 'رائع! يوم آخر من القراءة المباركة ✨',
      type: MessageType.achievement,
      trigger: MessageTrigger.completedPortion,
    ),
    MotivationalMessage(
      id: 'achievement_4',
      arabicText: 'أحسنت! استمر على هذا النهج الجميل 🌟',
      type: MessageType.achievement,
      trigger: MessageTrigger.afterReading,
    ),
  ];

  static const List<MotivationalMessage> streakMessages = [
    MotivationalMessage(
      id: 'streak_1',
      arabicText: 'ما شاء الله! 3 أيام متتالية من القراءة 🔥',
      type: MessageType.achievement,
      trigger: MessageTrigger.dailyStreak,
    ),
    MotivationalMessage(
      id: 'streak_2',
      arabicText: 'رائع! أسبوع كامل من الالتزام 🌟',
      type: MessageType.achievement,
      trigger: MessageTrigger.dailyStreak,
    ),
    MotivationalMessage(
      id: 'streak_3',
      arabicText: 'إنجاز مذهل! 30 يوماً من القراءة المستمرة 🎊',
      type: MessageType.achievement,
      trigger: MessageTrigger.dailyStreak,
    ),
  ];

  static const List<MotivationalMessage> encouragements = [
    MotivationalMessage(
      id: 'encourage_1',
      arabicText: 'اختيارك للقرآن على التطبيقات الأخرى اختيار موفق 💚',
      type: MessageType.encouragement,
      trigger: MessageTrigger.appOpen,
    ),
    MotivationalMessage(
      id: 'encourage_2',
      arabicText: 'كل آية تقرأها هي نور في قلبك ✨',
      type: MessageType.encouragement,
      trigger: MessageTrigger.appOpen,
    ),
    MotivationalMessage(
      id: 'encourage_3',
      arabicText: 'القرآن شفاء للقلوب، واصل القراءة 🌙',
      type: MessageType.encouragement,
      trigger: MessageTrigger.afterReading,
    ),
    MotivationalMessage(
      id: 'encourage_4',
      arabicText: 'بارك الله في وقتك وجعل القرآن ربيع قلبك 🌸',
      type: MessageType.encouragement,
      trigger: MessageTrigger.afterReading,
    ),
  ];

  static const List<MotivationalMessage> reminders = [
    MotivationalMessage(
      id: 'reminder_1',
      arabicText: 'حان وقت قراءة وردك اليومي من القرآن 📖',
      type: MessageType.reminder,
      trigger: MessageTrigger.reminderTime,
    ),
    MotivationalMessage(
      id: 'reminder_2',
      arabicText: 'لا تنس قراءة أذكار الصباح اليوم 🌅',
      type: MessageType.reminder,
      trigger: MessageTrigger.reminderTime,
    ),
    MotivationalMessage(
      id: 'reminder_3',
      arabicText: 'وقت أذكار المساء قد حان 🌙',
      type: MessageType.reminder,
      trigger: MessageTrigger.reminderTime,
    ),
    MotivationalMessage(
      id: 'reminder_4',
      arabicText: 'لم تكمل قراءة اليوم بعد، لنقرأ الآن؟ 📚',
      type: MessageType.reminder,
      trigger: MessageTrigger.reminderTime,
    ),
  ];

  static const List<MotivationalMessage> milestones = [
    MotivationalMessage(
      id: 'milestone_1',
      arabicText: 'تهانينا! أكملت جزء كامل من القرآن 🎉',
      type: MessageType.achievement,
      trigger: MessageTrigger.milestone,
    ),
    MotivationalMessage(
      id: 'milestone_2',
      arabicText: 'ما شاء الله! أتممت 10 أجزاء من القرآن 🌟',
      type: MessageType.achievement,
      trigger: MessageTrigger.milestone,
    ),
    MotivationalMessage(
      id: 'milestone_3',
      arabicText: 'بارك الله فيك! نصف القرآن قد اكتمل 🎊',
      type: MessageType.achievement,
      trigger: MessageTrigger.milestone,
    ),
    MotivationalMessage(
      id: 'milestone_4',
      arabicText: 'ألف مبروك! ختمت القرآن الكريم كاملاً 🎉🎊',
      type: MessageType.achievement,
      trigger: MessageTrigger.milestone,
    ),
  ];

  /// الحصول على رسالة عشوائية حسب النوع
  static MotivationalMessage getRandomMessage(MessageTrigger trigger) {
    List<MotivationalMessage> messages;

    switch (trigger) {
      case MessageTrigger.socialMediaDetected:
        messages = gentleReminders;
        break;
      case MessageTrigger.afterReading:
      case MessageTrigger.appOpen:
        messages = encouragements;
        break;
      case MessageTrigger.completedPortion:
        messages = achievements;
        break;
      case MessageTrigger.dailyStreak:
        messages = streakMessages;
        break;
      case MessageTrigger.reminderTime:
        messages = reminders;
        break;
      case MessageTrigger.milestone:
        messages = milestones;
        break;
    }

    return messages[DateTime.now().millisecond % messages.length];
  }

  /// الحصول على جميع الرسائل
  static List<MotivationalMessage> getAllMessages() {
    return [
      ...gentleReminders,
      ...achievements,
      ...streakMessages,
      ...encouragements,
      ...reminders,
      ...milestones,
    ];
  }
}

/// إحصائيات المكافآت
class RewardStats {
  final int totalMessagesReceived;
  final int consecutiveDays;
  final int totalJuzCompleted;
  final Map<String, int> achievementCounts;

  RewardStats({
    this.totalMessagesReceived = 0,
    this.consecutiveDays = 0,
    this.totalJuzCompleted = 0,
    Map<String, int>? achievementCounts,
  }) : achievementCounts = achievementCounts ?? {};

  Map<String, dynamic> toJson() {
    return {
      'totalMessagesReceived': totalMessagesReceived,
      'consecutiveDays': consecutiveDays,
      'totalJuzCompleted': totalJuzCompleted,
      'achievementCounts': achievementCounts,
    };
  }

  factory RewardStats.fromJson(Map<String, dynamic> json) {
    return RewardStats(
      totalMessagesReceived: json['totalMessagesReceived'] as int? ?? 0,
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
      totalJuzCompleted: json['totalJuzCompleted'] as int? ?? 0,
      achievementCounts:
          Map<String, int>.from(json['achievementCounts'] ?? {}),
    );
  }
}
