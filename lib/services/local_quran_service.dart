import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// نموذج الآية من بيانات حفص
class QuranAyah {
  final int id;
  final int jozz;
  final int page;
  final int suraNo;
  final String suraNameEn;
  final String suraNameAr;
  final int ayaNo;
  final String ayaText;
  final String ayaTextEmlaey;

  QuranAyah({
    required this.id,
    required this.jozz,
    required this.page,
    required this.suraNo,
    required this.suraNameEn,
    required this.suraNameAr,
    required this.ayaNo,
    required this.ayaText,
    required this.ayaTextEmlaey,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      id: json['id'] ?? 0,
      jozz: json['jozz'] ?? 0,
      page: json['page'] ?? 0,
      suraNo: json['sura_no'] ?? 0,
      suraNameEn: json['sura_name_en'] ?? '',
      suraNameAr: json['sura_name_ar'] ?? '',
      ayaNo: json['aya_no'] ?? 0,
      ayaText: json['aya_text'] ?? '',
      ayaTextEmlaey: json['aya_text_emlaey'] ?? '',
    );
  }
}

/// خدمة القرآن المحلية من ملف Uthmanic Hafs
class LocalQuranService {
  static List<QuranAyah>? _allAyahs;
  static bool _isLoaded = false;

  /// تحميل جميع الآيات من الملف المحلي
  static Future<void> loadQuranData() async {
    if (_isLoaded) return;

    try {
      debugPrint('بدء تحميل بيانات القرآن المحلية...');
      final String jsonString =
          await rootBundle.loadString('assets/data/quran_hafs.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _allAyahs = jsonList.map((json) => QuranAyah.fromJson(json)).toList();
      _isLoaded = true;
      debugPrint('تم تحميل ${_allAyahs!.length} آية من القرآن الكريم');
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات القرآن: $e');
      _allAyahs = [];
    }
  }

  /// الحصول على جميع آيات سورة معينة
  static List<QuranAyah> getSurahAyahs(int surahNumber) {
    if (_allAyahs == null) return [];
    return _allAyahs!.where((ayah) => ayah.suraNo == surahNumber).toList();
  }

  /// الحصول على جميع آيات جزء معين
  static List<QuranAyah> getJuzAyahs(int juzNumber) {
    if (_allAyahs == null) return [];
    return _allAyahs!.where((ayah) => ayah.jozz == juzNumber).toList();
  }

  /// الحصول على آية محددة
  static QuranAyah? getAyah(int surahNumber, int ayahNumber) {
    if (_allAyahs == null) return null;
    try {
      return _allAyahs!.firstWhere(
        (ayah) => ayah.suraNo == surahNumber && ayah.ayaNo == ayahNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// تنسيق نص السورة كاملاً
  static String formatSurahText(int surahNumber) {
    final ayahs = getSurahAyahs(surahNumber);
    if (ayahs.isEmpty) return '';

    final StringBuffer text = StringBuffer();
    for (var ayah in ayahs) {
      text.write(ayah.ayaText);
      text.write(' ');

      // إضافة سطر جديد بعد كل آية لسهولة القراءة
      if (ayah.ayaNo % 1 == 0) {
        text.write('\n');
      }
    }

    return text.toString().trim();
  }

  /// تنسيق نص الجزء مع فصل السور
  static Map<int, String> formatJuzText(int juzNumber) {
    final ayahs = getJuzAyahs(juzNumber);
    if (ayahs.isEmpty) return {};

    final Map<int, String> surahTexts = {};
    int? currentSurah;
    StringBuffer currentText = StringBuffer();

    for (var ayah in ayahs) {
      if (currentSurah != ayah.suraNo) {
        // حفظ السورة السابقة
        if (currentSurah != null) {
          surahTexts[currentSurah] = currentText.toString().trim();
        }

        // بدء سورة جديدة
        currentSurah = ayah.suraNo;
        currentText = StringBuffer();
      }

      currentText.write(ayah.ayaText);
      currentText.write(' ');
      currentText.write('\n');
    }

    // حفظ السورة الأخيرة
    if (currentSurah != null) {
      surahTexts[currentSurah] = currentText.toString().trim();
    }

    return surahTexts;
  }

  /// الحصول على أرقام السور في جزء معين
  static List<int> getSurahsInJuz(int juzNumber) {
    final ayahs = getJuzAyahs(juzNumber);
    final surahNumbers = <int>{};

    for (var ayah in ayahs) {
      surahNumbers.add(ayah.suraNo);
    }

    return surahNumbers.toList()..sort();
  }

  /// الحصول على عدد الآيات في سورة
  static int getSurahAyahCount(int surahNumber) {
    return getSurahAyahs(surahNumber).length;
  }

  /// تحقق من أن البيانات محملة
  static bool get isLoaded => _isLoaded;
}
