import 'quran_data_full.dart';

/// نموذج بيانات السورة
class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int totalAyahs;
  final int juz;
  final String revelationType; // مكية أو مدنية
  final String? content; // محتوى السورة (اختياري)

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.totalAyahs,
    required this.juz,
    required this.revelationType,
    this.content,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    // بناء محتوى السورة من قائمة الآيات إذا وجدت
    String? fullContent;
    if (json['verses'] != null) {
      final List<dynamic> versesList = json['verses'];
      fullContent = versesList.map((v) => v['text'] as String).join(' ');
    }

    return Surah(
      number: json['id'] as int,
      nameArabic: json['name'] as String? ?? '',
      nameEnglish: json['transliteration'] as String? ?? '',
      totalAyahs: json['total_verses'] as int? ?? 0,
      juz: json['juz'] as int? ?? 1, // سنعتمد على الترقيم الافتراضي إذا لم يوجد
      revelationType: json['type'] as String? ?? 'meccan',
      content: fullContent ?? json['content'],
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
      'content': content,
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
      surahs:
          (json['surahs'] as List).map((s) => SurahInJuz.fromJson(s)).toList(),
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
  static List<Surah> _surahs = [];

  static List<Surah> get surahs => _surahs;

  /// تحميل بيانات القرآن
  static Future<void> loadQuranData() async {
    if (_surahs.isNotEmpty) return;

    try {
      // استخدام القاعدة المضمّنة بدلاً من ملف JSON
      _surahs = QuranDataFull.allSurahs.map((info) {
        return Surah(
          number: info.number,
          nameArabic: info.nameArabic,
          nameEnglish: info.nameEnglish,
          totalAyahs: info.totalAyahs,
          juz: info.juz,
          revelationType: info.revelationType,
          content: null, // سيتم ملؤه عند الحاجة
        );
      }).toList();
    } catch (e) {
      print('خطأ في تحميل القرآن: $e');
      _surahs = [];
    }
  }

  static Surah? getSurahByNumber(int number) {
    try {
      return _surahs.firstWhere((s) => s.number == number);
    } catch (e) {
      return null;
    }
  }

  static List<Surah> getSurahsByJuz(int juz) {
    return _surahs.where((s) => s.juz == juz).toList();
  }

  static int getTotalAyahs() {
    return _surahs.fold(0, (sum, surah) => sum + surah.totalAyahs);
  }
}
