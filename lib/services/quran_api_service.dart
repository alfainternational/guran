import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// خدمة API للقرآن الكريم
/// تستخدم API المفتوح من Al-Quran Cloud للحصول على النص الكامل
class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  /// النسخة العربية البسيطة
  static const String editionArabic = 'quran-simple-clean';

  /// الحصول على سورة كاملة بالنص العربي
  static Future<Map<String, dynamic>?> getSurah(int surahNumber) async {
    try {
      final url = '$baseUrl/surah/$surahNumber/$editionArabic';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['code'] == 200 && data['status'] == 'OK') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في جلب السورة: $e');
      return null;
    }
  }

  /// الحصول على جزء كامل
  static Future<Map<String, dynamic>?> getJuz(int juzNumber) async {
    try {
      final url = '$baseUrl/juz/$juzNumber/$editionArabic';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['code'] == 200 && data['status'] == 'OK') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في جلب الجزء: $e');
      return null;
    }
  }

  /// الحصول على آية محددة
  static Future<String?> getAyah(int surahNumber, int ayahNumber) async {
    try {
      final url = '$baseUrl/ayah/$surahNumber:$ayahNumber/$editionArabic';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['code'] == 200 && data['status'] == 'OK') {
          return data['data']['text'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في جلب الآية: $e');
      return null;
    }
  }

  /// تنسيق نص السورة من استجابة API
  static String formatSurahText(Map<String, dynamic> surahData) {
    try {
      final ayahs = surahData['ayahs'] as List;
      final StringBuffer text = StringBuffer();

      for (var i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        text.write(ayah['text']);
        text.write(' ﴿${ayah['numberInSurah']}﴾ ');

        // إضافة سطر جديد بعد كل آية
        if ((i + 1) % 1 == 0) {
          text.write('\n');
        }
      }

      return text.toString().trim();
    } catch (e) {
      debugPrint('خطأ في تنسيق نص السورة: $e');
      return '';
    }
  }

  /// تنسيق نص الجزء من استجابة API
  static Map<int, String> formatJuzText(Map<String, dynamic> juzData) {
    try {
      final ayahs = juzData['ayahs'] as List;
      final Map<int, String> surahTexts = {};

      int? currentSurah;
      StringBuffer currentText = StringBuffer();

      for (var ayah in ayahs) {
        final surahNumber = ayah['surah']['number'];

        if (currentSurah != surahNumber) {
          // حفظ السورة السابقة
          if (currentSurah != null) {
            surahTexts[currentSurah] = currentText.toString().trim();
          }

          // بدء سورة جديدة
          currentSurah = surahNumber;
          currentText = StringBuffer();
        }

        currentText.write(ayah['text']);
        currentText.write(' ﴿${ayah['numberInSurah']}﴾ ');
        currentText.write('\n');
      }

      // حفظ السورة الأخيرة
      if (currentSurah != null) {
        surahTexts[currentSurah] = currentText.toString().trim();
      }

      return surahTexts;
    } catch (e) {
      debugPrint('خطأ في تنسيق نص الجزء: $e');
      return {};
    }
  }
}
