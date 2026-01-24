/// نموذج بيانات السورة
class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int totalAyahs;
  final int juz;
  final String revelationType; // مكية أو مدنية

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.totalAyahs,
    required this.juz,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      totalAyahs: json['totalAyahs'] as int,
      juz: json['juz'] as int,
      revelationType: json['revelationType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'totalAyahs': totalAyahs,
      'juz': juz,
      'revelationType': revelationType,
    };
  }
}

/// نموذج بيانات الجزء
class Juz {
  final int number;
  final List<SurahInJuz> surahs;

  const Juz({
    required this.number,
    required this.surahs,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      number: json['number'] as int,
      surahs: (json['surahs'] as List)
          .map((s) => SurahInJuz.fromJson(s))
          .toList(),
    );
  }
}

/// السورة داخل الجزء مع نطاق الآيات
class SurahInJuz {
  final int surahNumber;
  final int startAyah;
  final int endAyah;

  const SurahInJuz({
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
  });

  factory SurahInJuz.fromJson(Map<String, dynamic> json) {
    return SurahInJuz(
      surahNumber: json['surahNumber'] as int,
      startAyah: json['startAyah'] as int,
      endAyah: json['endAyah'] as int,
    );
  }
}

/// قائمة جميع سور القرآن الكريم (114 سورة)
class QuranData {
  static const List<Surah> surahs = [
    Surah(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'Al-Fatihah', totalAyahs: 7, juz: 1, revelationType: 'مكية'),
    Surah(number: 2, nameArabic: 'البقرة', nameEnglish: 'Al-Baqarah', totalAyahs: 286, juz: 1, revelationType: 'مدنية'),
    Surah(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Aal-E-Imran', totalAyahs: 200, juz: 3, revelationType: 'مدنية'),
    Surah(number: 4, nameArabic: 'النساء', nameEnglish: 'An-Nisa', totalAyahs: 176, juz: 4, revelationType: 'مدنية'),
    Surah(number: 5, nameArabic: 'المائدة', nameEnglish: 'Al-Maidah', totalAyahs: 120, juz: 6, revelationType: 'مدنية'),
    Surah(number: 6, nameArabic: 'الأنعام', nameEnglish: 'Al-Anam', totalAyahs: 165, juz: 7, revelationType: 'مكية'),
    Surah(number: 7, nameArabic: 'الأعراف', nameEnglish: 'Al-Araf', totalAyahs: 206, juz: 8, revelationType: 'مكية'),
    Surah(number: 8, nameArabic: 'الأنفال', nameEnglish: 'Al-Anfal', totalAyahs: 75, juz: 9, revelationType: 'مدنية'),
    Surah(number: 9, nameArabic: 'التوبة', nameEnglish: 'At-Tawbah', totalAyahs: 129, juz: 10, revelationType: 'مدنية'),
    Surah(number: 10, nameArabic: 'يونس', nameEnglish: 'Yunus', totalAyahs: 109, juz: 11, revelationType: 'مكية'),
    Surah(number: 11, nameArabic: 'هود', nameEnglish: 'Hud', totalAyahs: 123, juz: 11, revelationType: 'مكية'),
    Surah(number: 12, nameArabic: 'يوسف', nameEnglish: 'Yusuf', totalAyahs: 111, juz: 12, revelationType: 'مكية'),
    Surah(number: 13, nameArabic: 'الرعد', nameEnglish: 'Ar-Rad', totalAyahs: 43, juz: 13, revelationType: 'مدنية'),
    Surah(number: 14, nameArabic: 'إبراهيم', nameEnglish: 'Ibrahim', totalAyahs: 52, juz: 13, revelationType: 'مكية'),
    Surah(number: 15, nameArabic: 'الحجر', nameEnglish: 'Al-Hijr', totalAyahs: 99, juz: 14, revelationType: 'مكية'),
    Surah(number: 16, nameArabic: 'النحل', nameEnglish: 'An-Nahl', totalAyahs: 128, juz: 14, revelationType: 'مكية'),
    Surah(number: 17, nameArabic: 'الإسراء', nameEnglish: 'Al-Isra', totalAyahs: 111, juz: 15, revelationType: 'مكية'),
    Surah(number: 18, nameArabic: 'الكهف', nameEnglish: 'Al-Kahf', totalAyahs: 110, juz: 15, revelationType: 'مكية'),
    Surah(number: 19, nameArabic: 'مريم', nameEnglish: 'Maryam', totalAyahs: 98, juz: 16, revelationType: 'مكية'),
    Surah(number: 20, nameArabic: 'طه', nameEnglish: 'Ta-Ha', totalAyahs: 135, juz: 16, revelationType: 'مكية'),
    Surah(number: 21, nameArabic: 'الأنبياء', nameEnglish: 'Al-Anbiya', totalAyahs: 112, juz: 17, revelationType: 'مكية'),
    Surah(number: 22, nameArabic: 'الحج', nameEnglish: 'Al-Hajj', totalAyahs: 78, juz: 17, revelationType: 'مدنية'),
    Surah(number: 23, nameArabic: 'المؤمنون', nameEnglish: 'Al-Muminun', totalAyahs: 118, juz: 18, revelationType: 'مكية'),
    Surah(number: 24, nameArabic: 'النور', nameEnglish: 'An-Nur', totalAyahs: 64, juz: 18, revelationType: 'مدنية'),
    Surah(number: 25, nameArabic: 'الفرقان', nameEnglish: 'Al-Furqan', totalAyahs: 77, juz: 18, revelationType: 'مكية'),
    Surah(number: 26, nameArabic: 'الشعراء', nameEnglish: 'Ash-Shuara', totalAyahs: 227, juz: 19, revelationType: 'مكية'),
    Surah(number: 27, nameArabic: 'النمل', nameEnglish: 'An-Naml', totalAyahs: 93, juz: 19, revelationType: 'مكية'),
    Surah(number: 28, nameArabic: 'القصص', nameEnglish: 'Al-Qasas', totalAyahs: 88, juz: 20, revelationType: 'مكية'),
    Surah(number: 29, nameArabic: 'العنكبوت', nameEnglish: 'Al-Ankabut', totalAyahs: 69, juz: 20, revelationType: 'مكية'),
    Surah(number: 30, nameArabic: 'الروم', nameEnglish: 'Ar-Rum', totalAyahs: 60, juz: 21, revelationType: 'مكية'),
    Surah(number: 31, nameArabic: 'لقمان', nameEnglish: 'Luqman', totalAyahs: 34, juz: 21, revelationType: 'مكية'),
    Surah(number: 32, nameArabic: 'السجدة', nameEnglish: 'As-Sajdah', totalAyahs: 30, juz: 21, revelationType: 'مكية'),
    Surah(number: 33, nameArabic: 'الأحزاب', nameEnglish: 'Al-Ahzab', totalAyahs: 73, juz: 21, revelationType: 'مدنية'),
    Surah(number: 34, nameArabic: 'سبأ', nameEnglish: 'Saba', totalAyahs: 54, juz: 22, revelationType: 'مكية'),
    Surah(number: 35, nameArabic: 'فاطر', nameEnglish: 'Fatir', totalAyahs: 45, juz: 22, revelationType: 'مكية'),
    Surah(number: 36, nameArabic: 'يس', nameEnglish: 'Ya-Sin', totalAyahs: 83, juz: 22, revelationType: 'مكية'),
    Surah(number: 37, nameArabic: 'الصافات', nameEnglish: 'As-Saffat', totalAyahs: 182, juz: 23, revelationType: 'مكية'),
    Surah(number: 38, nameArabic: 'ص', nameEnglish: 'Sad', totalAyahs: 88, juz: 23, revelationType: 'مكية'),
    Surah(number: 39, nameArabic: 'الزمر', nameEnglish: 'Az-Zumar', totalAyahs: 75, juz: 23, revelationType: 'مكية'),
    Surah(number: 40, nameArabic: 'غافر', nameEnglish: 'Ghafir', totalAyahs: 85, juz: 24, revelationType: 'مكية'),
    Surah(number: 41, nameArabic: 'فصلت', nameEnglish: 'Fussilat', totalAyahs: 54, juz: 24, revelationType: 'مكية'),
    Surah(number: 42, nameArabic: 'الشورى', nameEnglish: 'Ash-Shura', totalAyahs: 53, juz: 25, revelationType: 'مكية'),
    Surah(number: 43, nameArabic: 'الزخرف', nameEnglish: 'Az-Zukhruf', totalAyahs: 89, juz: 25, revelationType: 'مكية'),
    Surah(number: 44, nameArabic: 'الدخان', nameEnglish: 'Ad-Dukhan', totalAyahs: 59, juz: 25, revelationType: 'مكية'),
    Surah(number: 45, nameArabic: 'الجاثية', nameEnglish: 'Al-Jathiya', totalAyahs: 37, juz: 25, revelationType: 'مكية'),
    Surah(number: 46, nameArabic: 'الأحقاف', nameEnglish: 'Al-Ahqaf', totalAyahs: 35, juz: 26, revelationType: 'مكية'),
    Surah(number: 47, nameArabic: 'محمد', nameEnglish: 'Muhammad', totalAyahs: 38, juz: 26, revelationType: 'مدنية'),
    Surah(number: 48, nameArabic: 'الفتح', nameEnglish: 'Al-Fath', totalAyahs: 29, juz: 26, revelationType: 'مدنية'),
    Surah(number: 49, nameArabic: 'الحجرات', nameEnglish: 'Al-Hujurat', totalAyahs: 18, juz: 26, revelationType: 'مدنية'),
    Surah(number: 50, nameArabic: 'ق', nameEnglish: 'Qaf', totalAyahs: 45, juz: 26, revelationType: 'مكية'),
    Surah(number: 51, nameArabic: 'الذاريات', nameEnglish: 'Adh-Dhariyat', totalAyahs: 60, juz: 26, revelationType: 'مكية'),
    Surah(number: 52, nameArabic: 'الطور', nameEnglish: 'At-Tur', totalAyahs: 49, juz: 27, revelationType: 'مكية'),
    Surah(number: 53, nameArabic: 'النجم', nameEnglish: 'An-Najm', totalAyahs: 62, juz: 27, revelationType: 'مكية'),
    Surah(number: 54, nameArabic: 'القمر', nameEnglish: 'Al-Qamar', totalAyahs: 55, juz: 27, revelationType: 'مكية'),
    Surah(number: 55, nameArabic: 'الرحمن', nameEnglish: 'Ar-Rahman', totalAyahs: 78, juz: 27, revelationType: 'مدنية'),
    Surah(number: 56, nameArabic: 'الواقعة', nameEnglish: 'Al-Waqiah', totalAyahs: 96, juz: 27, revelationType: 'مكية'),
    Surah(number: 57, nameArabic: 'الحديد', nameEnglish: 'Al-Hadid', totalAyahs: 29, juz: 27, revelationType: 'مدنية'),
    Surah(number: 58, nameArabic: 'المجادلة', nameEnglish: 'Al-Mujadila', totalAyahs: 22, juz: 28, revelationType: 'مدنية'),
    Surah(number: 59, nameArabic: 'الحشر', nameEnglish: 'Al-Hashr', totalAyahs: 24, juz: 28, revelationType: 'مدنية'),
    Surah(number: 60, nameArabic: 'الممتحنة', nameEnglish: 'Al-Mumtahina', totalAyahs: 13, juz: 28, revelationType: 'مدنية'),
    Surah(number: 61, nameArabic: 'الصف', nameEnglish: 'As-Saff', totalAyahs: 14, juz: 28, revelationType: 'مدنية'),
    Surah(number: 62, nameArabic: 'الجمعة', nameEnglish: 'Al-Jumuah', totalAyahs: 11, juz: 28, revelationType: 'مدنية'),
    Surah(number: 63, nameArabic: 'المنافقون', nameEnglish: 'Al-Munafiqun', totalAyahs: 11, juz: 28, revelationType: 'مدنية'),
    Surah(number: 64, nameArabic: 'التغابن', nameEnglish: 'At-Taghabun', totalAyahs: 18, juz: 28, revelationType: 'مدنية'),
    Surah(number: 65, nameArabic: 'الطلاق', nameEnglish: 'At-Talaq', totalAyahs: 12, juz: 28, revelationType: 'مدنية'),
    Surah(number: 66, nameArabic: 'التحريم', nameEnglish: 'At-Tahrim', totalAyahs: 12, juz: 28, revelationType: 'مدنية'),
    Surah(number: 67, nameArabic: 'الملك', nameEnglish: 'Al-Mulk', totalAyahs: 30, juz: 29, revelationType: 'مكية'),
    Surah(number: 68, nameArabic: 'القلم', nameEnglish: 'Al-Qalam', totalAyahs: 52, juz: 29, revelationType: 'مكية'),
    Surah(number: 69, nameArabic: 'الحاقة', nameEnglish: 'Al-Haqqah', totalAyahs: 52, juz: 29, revelationType: 'مكية'),
    Surah(number: 70, nameArabic: 'المعارج', nameEnglish: 'Al-Maarij', totalAyahs: 44, juz: 29, revelationType: 'مكية'),
    Surah(number: 71, nameArabic: 'نوح', nameEnglish: 'Nuh', totalAyahs: 28, juz: 29, revelationType: 'مكية'),
    Surah(number: 72, nameArabic: 'الجن', nameEnglish: 'Al-Jinn', totalAyahs: 28, juz: 29, revelationType: 'مكية'),
    Surah(number: 73, nameArabic: 'المزمل', nameEnglish: 'Al-Muzzammil', totalAyahs: 20, juz: 29, revelationType: 'مكية'),
    Surah(number: 74, nameArabic: 'المدثر', nameEnglish: 'Al-Muddaththir', totalAyahs: 56, juz: 29, revelationType: 'مكية'),
    Surah(number: 75, nameArabic: 'القيامة', nameEnglish: 'Al-Qiyamah', totalAyahs: 40, juz: 29, revelationType: 'مكية'),
    Surah(number: 76, nameArabic: 'الإنسان', nameEnglish: 'Al-Insan', totalAyahs: 31, juz: 29, revelationType: 'مدنية'),
    Surah(number: 77, nameArabic: 'المرسلات', nameEnglish: 'Al-Mursalat', totalAyahs: 50, juz: 29, revelationType: 'مكية'),
    Surah(number: 78, nameArabic: 'النبأ', nameEnglish: 'An-Naba', totalAyahs: 40, juz: 30, revelationType: 'مكية'),
    Surah(number: 79, nameArabic: 'النازعات', nameEnglish: 'An-Naziat', totalAyahs: 46, juz: 30, revelationType: 'مكية'),
    Surah(number: 80, nameArabic: 'عبس', nameEnglish: 'Abasa', totalAyahs: 42, juz: 30, revelationType: 'مكية'),
    Surah(number: 81, nameArabic: 'التكوير', nameEnglish: 'At-Takwir', totalAyahs: 29, juz: 30, revelationType: 'مكية'),
    Surah(number: 82, nameArabic: 'الإنفطار', nameEnglish: 'Al-Infitar', totalAyahs: 19, juz: 30, revelationType: 'مكية'),
    Surah(number: 83, nameArabic: 'المطففين', nameEnglish: 'Al-Mutaffifin', totalAyahs: 36, juz: 30, revelationType: 'مكية'),
    Surah(number: 84, nameArabic: 'الإنشقاق', nameEnglish: 'Al-Inshiqaq', totalAyahs: 25, juz: 30, revelationType: 'مكية'),
    Surah(number: 85, nameArabic: 'البروج', nameEnglish: 'Al-Buruj', totalAyahs: 22, juz: 30, revelationType: 'مكية'),
    Surah(number: 86, nameArabic: 'الطارق', nameEnglish: 'At-Tariq', totalAyahs: 17, juz: 30, revelationType: 'مكية'),
    Surah(number: 87, nameArabic: 'الأعلى', nameEnglish: 'Al-Ala', totalAyahs: 19, juz: 30, revelationType: 'مكية'),
    Surah(number: 88, nameArabic: 'الغاشية', nameEnglish: 'Al-Ghashiyah', totalAyahs: 26, juz: 30, revelationType: 'مكية'),
    Surah(number: 89, nameArabic: 'الفجر', nameEnglish: 'Al-Fajr', totalAyahs: 30, juz: 30, revelationType: 'مكية'),
    Surah(number: 90, nameArabic: 'البلد', nameEnglish: 'Al-Balad', totalAyahs: 20, juz: 30, revelationType: 'مكية'),
    Surah(number: 91, nameArabic: 'الشمس', nameEnglish: 'Ash-Shams', totalAyahs: 15, juz: 30, revelationType: 'مكية'),
    Surah(number: 92, nameArabic: 'الليل', nameEnglish: 'Al-Lail', totalAyahs: 21, juz: 30, revelationType: 'مكية'),
    Surah(number: 93, nameArabic: 'الضحى', nameEnglish: 'Ad-Dhuha', totalAyahs: 11, juz: 30, revelationType: 'مكية'),
    Surah(number: 94, nameArabic: 'الشرح', nameEnglish: 'Ash-Sharh', totalAyahs: 8, juz: 30, revelationType: 'مكية'),
    Surah(number: 95, nameArabic: 'التين', nameEnglish: 'At-Tin', totalAyahs: 8, juz: 30, revelationType: 'مكية'),
    Surah(number: 96, nameArabic: 'العلق', nameEnglish: 'Al-Alaq', totalAyahs: 19, juz: 30, revelationType: 'مكية'),
    Surah(number: 97, nameArabic: 'القدر', nameEnglish: 'Al-Qadr', totalAyahs: 5, juz: 30, revelationType: 'مكية'),
    Surah(number: 98, nameArabic: 'البينة', nameEnglish: 'Al-Bayyinah', totalAyahs: 8, juz: 30, revelationType: 'مدنية'),
    Surah(number: 99, nameArabic: 'الزلزلة', nameEnglish: 'Az-Zalzalah', totalAyahs: 8, juz: 30, revelationType: 'مدنية'),
    Surah(number: 100, nameArabic: 'العاديات', nameEnglish: 'Al-Adiyat', totalAyahs: 11, juz: 30, revelationType: 'مكية'),
    Surah(number: 101, nameArabic: 'القارعة', nameEnglish: 'Al-Qariah', totalAyahs: 11, juz: 30, revelationType: 'مكية'),
    Surah(number: 102, nameArabic: 'التكاثر', nameEnglish: 'At-Takathur', totalAyahs: 8, juz: 30, revelationType: 'مكية'),
    Surah(number: 103, nameArabic: 'العصر', nameEnglish: 'Al-Asr', totalAyahs: 3, juz: 30, revelationType: 'مكية'),
    Surah(number: 104, nameArabic: 'الهمزة', nameEnglish: 'Al-Humazah', totalAyahs: 9, juz: 30, revelationType: 'مكية'),
    Surah(number: 105, nameArabic: 'الفيل', nameEnglish: 'Al-Fil', totalAyahs: 5, juz: 30, revelationType: 'مكية'),
    Surah(number: 106, nameArabic: 'قريش', nameEnglish: 'Quraish', totalAyahs: 4, juz: 30, revelationType: 'مكية'),
    Surah(number: 107, nameArabic: 'الماعون', nameEnglish: 'Al-Maun', totalAyahs: 7, juz: 30, revelationType: 'مكية'),
    Surah(number: 108, nameArabic: 'الكوثر', nameEnglish: 'Al-Kawthar', totalAyahs: 3, juz: 30, revelationType: 'مكية'),
    Surah(number: 109, nameArabic: 'الكافرون', nameEnglish: 'Al-Kafirun', totalAyahs: 6, juz: 30, revelationType: 'مكية'),
    Surah(number: 110, nameArabic: 'النصر', nameEnglish: 'An-Nasr', totalAyahs: 3, juz: 30, revelationType: 'مدنية'),
    Surah(number: 111, nameArabic: 'المسد', nameEnglish: 'Al-Masad', totalAyahs: 5, juz: 30, revelationType: 'مكية'),
    Surah(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Al-Ikhlas', totalAyahs: 4, juz: 30, revelationType: 'مكية'),
    Surah(number: 113, nameArabic: 'الفلق', nameEnglish: 'Al-Falaq', totalAyahs: 5, juz: 30, revelationType: 'مكية'),
    Surah(number: 114, nameArabic: 'الناس', nameEnglish: 'An-Nas', totalAyahs: 6, juz: 30, revelationType: 'مكية'),
  ];

  static Surah? getSurahByNumber(int number) {
    try {
      return surahs.firstWhere((s) => s.number == number);
    } catch (e) {
      return null;
    }
  }

  static List<Surah> getSurahsByJuz(int juz) {
    return surahs.where((s) => s.juz == juz).toList();
  }

  static int getTotalAyahs() {
    return surahs.fold(0, (sum, surah) => sum + surah.totalAyahs);
  }
}
