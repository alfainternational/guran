class SpiritualFootprint {
  final String userId;
  final DateTime date;
  final Duration quranTime;
  final Duration dhikrTime;
  final Duration prayerTime;
  final Duration socialMediaTime;
  final Duration entertainmentTime;
  final Duration productiveTime;

  SpiritualFootprint({
    required this.userId,
    required this.date,
    this.quranTime = Duration.zero,
    this.dhikrTime = Duration.zero,
    this.prayerTime = Duration.zero,
    this.socialMediaTime = Duration.zero,
    this.entertainmentTime = Duration.zero,
    this.productiveTime = Duration.zero,
  });

  // حساب النسبة الروحانية
  double get spiritualPercentage {
    final totalSpiritual =
        quranTime.inMinutes + dhikrTime.inMinutes + prayerTime.inMinutes;
    final totalTime = totalSpiritual +
        socialMediaTime.inMinutes +
        entertainmentTime.inMinutes +
        productiveTime.inMinutes;

    return totalTime > 0 ? (totalSpiritual / totalTime) * 100 : 0;
  }

  // مقارنة الوقت الروحاني بوسائل التواصل
  String getComparisonInsight() {
    final spiritualMinutes =
        quranTime.inMinutes + dhikrTime.inMinutes + prayerTime.inMinutes;
    final socialMinutes = socialMediaTime.inMinutes;

    if (spiritualMinutes > socialMinutes) {
      final diff = spiritualMinutes - socialMinutes;
      return 'ما شاء الله! وقتك الروحاني أكثر بـ $diff دقيقة من وسائل التواصل 🌟';
    } else if (socialMinutes > spiritualMinutes) {
      final diff = socialMinutes - spiritualMinutes;
      return 'لو قللت $diff دقيقة من وسائل التواصل، يمكنك مضاعفة وقتك الروحاني 💚';
    } else {
      return 'متوازن! حاول زيادة الوقت الروحاني تدريجياً 📖';
    }
  }

  // اقتراحات التحسين
  List<ImprovementSuggestion> getSuggestions() {
    List<ImprovementSuggestion> suggestions = [];

    // اقتراح بناءً على وسائل التواصل
    if (socialMediaTime.inMinutes > 60) {
      suggestions.add(ImprovementSuggestion(
        title: 'تقليل وسائل التواصل',
        description:
            'تقضي ${socialMediaTime.inMinutes} دقيقة يومياً في وسائل التواصل. لو قللت 30 دقيقة، يمكنك ختم القرآن في شهرين!',
        actionText: 'ضع هدف',
        priority: Priority.high,
      ));
    }

    // اقتراح بناءً على القراءة
    if (quranTime.inMinutes < 15) {
      suggestions.add(ImprovementSuggestion(
        title: 'زيادة وقت القراءة',
        description:
            'ابدأ بـ 10 دقائق يومياً. يمكنك قراءة صفحتين فقط والحصول على أجر عظيم',
        actionText: 'ابدأ الآن',
        priority: Priority.medium,
      ));
    }

    return suggestions;
  }
}

enum Priority { high, medium, low }

class ImprovementSuggestion {
  final String title;
  final String description;
  final String actionText;
  final Priority priority;

  ImprovementSuggestion({
    required this.title,
    required this.description,
    required this.actionText,
    required this.priority,
  });
}
