/// نموذج الذكر
class Dhikr {
  final String id;
  final String arabicText;
  final String? transliteration;
  final String? translation;
  final int? repetitions;
  final DhikrCategory category;
  final DhikrTime? timeOfDay;
  final String? audioPath;
  final String? reference; // المصدر (حديث، قرآن، إلخ)

  const Dhikr({
    required this.id,
    required this.arabicText,
    this.transliteration,
    this.translation,
    this.repetitions,
    required this.category,
    this.timeOfDay,
    this.audioPath,
    this.reference,
  });

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: json['id'] as String,
      arabicText: json['arabicText'] as String,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      repetitions: json['repetitions'] as int?,
      category: DhikrCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => DhikrCategory.general,
      ),
      timeOfDay: json['timeOfDay'] != null
          ? DhikrTime.values.firstWhere(
              (e) => e.toString() == json['timeOfDay'],
            )
          : null,
      audioPath: json['audioPath'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'repetitions': repetitions,
      'category': category.toString(),
      'timeOfDay': timeOfDay?.toString(),
      'audioPath': audioPath,
      'reference': reference,
    };
  }
}

/// فئات الأذكار
enum DhikrCategory {
  morning, // أذكار الصباح
  evening, // أذكار المساء
  afterPrayer, // أذكار بعد الصلاة
  sleeping, // أذكار النوم
  waking, // أذكار الاستيقاظ
  general, // عامة
  istighfar, // استغفار
  salawat, // صلوات على النبي
  tasbih, // تسبيح
  protection, // أذكار الحفظ
}

/// وقت الذكر
enum DhikrTime {
  morning, // صباح (بعد الفجر)
  evening, // مساء (بعد العصر)
  night, // ليل
  anytime, // أي وقت
}

/// مجموعة الأذكار المحددة مسبقاً
class DhikrData {
  static final List<Dhikr> morningAdhkar = [
    const Dhikr(
      id: 'morning_1',
      arabicText:
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      translation:
          'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
      repetitions: 1,
      category: DhikrCategory.morning,
      timeOfDay: DhikrTime.morning,
      reference: 'صحيح مسلم',
    ),
    const Dhikr(
      id: 'morning_2',
      arabicText:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      translation:
          'اللهم بك أصبحنا، وبك أمسينا، وبك نحيا، وبك نموت، وإليك النشور',
      repetitions: 1,
      category: DhikrCategory.morning,
      timeOfDay: DhikrTime.morning,
      reference: 'صحيح الترمذي',
    ),
    const Dhikr(
      id: 'morning_3',
      arabicText:
          'أَعُوذُ بِاللَّهِ السَّمِيعِ الْعَلِيمِ مِنَ الشَّيْطَانِ الرَّجِيمِ، مِنْ هَمْزِهِ وَنَفْخِهِ وَنَفْثِهِ',
      translation:
          'أعوذ بالله السميع العليم من الشيطان الرجيم، من همزه ونفخه ونفثه',
      repetitions: 3,
      category: DhikrCategory.morning,
      timeOfDay: DhikrTime.morning,
      reference: 'صحيح أبي داود',
    ),
    const Dhikr(
      id: 'morning_4',
      arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      translation: 'سبحان الله وبحمده',
      repetitions: 100,
      category: DhikrCategory.morning,
      timeOfDay: DhikrTime.morning,
      reference: 'صحيح البخاري',
    ),
    const Dhikr(
      id: 'ayat_kursi',
      arabicText:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...',
      translation: 'آية الكرسي',
      repetitions: 1,
      category: DhikrCategory.morning,
      timeOfDay: DhikrTime.morning,
      reference: 'القرآن الكريم - البقرة 255',
    ),
  ];

  static final List<Dhikr> eveningAdhkar = [
    const Dhikr(
      id: 'evening_1',
      arabicText:
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      translation:
          'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له',
      repetitions: 1,
      category: DhikrCategory.evening,
      timeOfDay: DhikrTime.evening,
      reference: 'صحيح مسلم',
    ),
    const Dhikr(
      id: 'evening_2',
      arabicText:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      translation:
          'اللهم بك أمسينا، وبك أصبحنا، وبك نحيا، وبك نموت، وإليك المصير',
      repetitions: 1,
      category: DhikrCategory.evening,
      timeOfDay: DhikrTime.evening,
      reference: 'صحيح الترمذي',
    ),
  ];

  static final List<Dhikr> generalAdhkar = [
    const Dhikr(
      id: 'istighfar_1',
      arabicText: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      translation: 'أستغفر الله وأتوب إليه',
      repetitions: 100,
      category: DhikrCategory.istighfar,
      timeOfDay: DhikrTime.anytime,
      reference: 'صحيح البخاري',
    ),
    const Dhikr(
      id: 'salawat_1',
      arabicText:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      translation: 'الصلاة الإبراهيمية على النبي صلى الله عليه وسلم',
      repetitions: 10,
      category: DhikrCategory.salawat,
      timeOfDay: DhikrTime.anytime,
      reference: 'صحيح البخاري',
    ),
    const Dhikr(
      id: 'tasbih_1',
      arabicText: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      translation: 'سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر',
      repetitions: 33,
      category: DhikrCategory.tasbih,
      timeOfDay: DhikrTime.anytime,
      reference: 'صحيح مسلم',
    ),
    const Dhikr(
      id: 'protection_1',
      arabicText:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      translation:
          'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم',
      repetitions: 3,
      category: DhikrCategory.protection,
      timeOfDay: DhikrTime.anytime,
      reference: 'صحيح الترمذي',
    ),
  ];

  static List<Dhikr> getAllAdhkar() {
    return [...morningAdhkar, ...eveningAdhkar, ...generalAdhkar];
  }

  static List<Dhikr> getAdhkarByCategory(DhikrCategory category) {
    return getAllAdhkar().where((d) => d.category == category).toList();
  }

  static List<Dhikr> getAdhkarByTime(DhikrTime time) {
    return getAllAdhkar().where((d) => d.timeOfDay == time).toList();
  }
}

/// تتبع الأذكار المكتملة
class DhikrProgress {
  final String userId;
  final Map<String, DhikrCompletion> completions;
  final int totalDhikrCount;
  final DateTime lastDhikrDate;

  DhikrProgress({
    required this.userId,
    Map<String, DhikrCompletion>? completions,
    this.totalDhikrCount = 0,
    DateTime? lastDhikrDate,
  })  : completions = completions ?? {},
        lastDhikrDate = lastDhikrDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'completions': completions.map((k, v) => MapEntry(k, v.toJson())),
      'totalDhikrCount': totalDhikrCount,
      'lastDhikrDate': lastDhikrDate.toIso8601String(),
    };
  }

  factory DhikrProgress.fromJson(Map<String, dynamic> json) {
    return DhikrProgress(
      userId: json['userId'] as String,
      completions: (json['completions'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, DhikrCompletion.fromJson(v)),
          ) ??
          {},
      totalDhikrCount: json['totalDhikrCount'] as int? ?? 0,
      lastDhikrDate: json['lastDhikrDate'] != null
          ? DateTime.parse(json['lastDhikrDate'] as String)
          : DateTime.now(),
    );
  }
}

/// إكمال ذكر معين
class DhikrCompletion {
  final String dhikrId;
  final DateTime completedAt;
  final int repetitionsCompleted;

  DhikrCompletion({
    required this.dhikrId,
    required this.completedAt,
    required this.repetitionsCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'dhikrId': dhikrId,
      'completedAt': completedAt.toIso8601String(),
      'repetitionsCompleted': repetitionsCompleted,
    };
  }

  factory DhikrCompletion.fromJson(Map<String, dynamic> json) {
    return DhikrCompletion(
      dhikrId: json['dhikrId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      repetitionsCompleted: json['repetitionsCompleted'] as int,
    );
  }
}
