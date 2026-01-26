import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// نموذج التفسير
class TafseerEntry {
  final int id;
  final int jozz;
  final int page;
  final int suraNo;
  final String suraNameEn;
  final String suraNameAr;
  final int ayaNo;
  final String ayaText;
  final String ayaTextEmlaey;
  final String tafseer;

  TafseerEntry({
    required this.id,
    required this.jozz,
    required this.page,
    required this.suraNo,
    required this.suraNameEn,
    required this.suraNameAr,
    required this.ayaNo,
    required this.ayaText,
    required this.ayaTextEmlaey,
    required this.tafseer,
  });

  factory TafseerEntry.fromLine(String line) {
    final parts = line.split('\t');
    if (parts.length < 11) {
      throw FormatException('Invalid tafseer line format');
    }

    return TafseerEntry(
      id: int.parse(parts[0]),
      jozz: int.parse(parts[1]),
      page: int.parse(parts[2]),
      suraNo: int.parse(parts[3]),
      suraNameEn: parts[4],
      suraNameAr: parts[5],
      ayaNo: int.parse(parts[8]),
      ayaText: parts[9],
      ayaTextEmlaey: parts[10],
      tafseer: parts.length > 11 ? parts[11] : '',
    );
  }
}

/// خدمة التفسير الميسر
class TafseerService {
  static Map<String, TafseerEntry>? _tafseerMap;
  static bool _isLoaded = false;

  /// تحميل جميع التفاسير من الملف
  static Future<void> loadTafseer() async {
    if (_isLoaded) return;

    try {
      debugPrint('بدء تحميل التفسير الميسر...');
      final String fileContent =
          await rootBundle.loadString('assets/data/tafseer.txt');

      final lines = const LineSplitter().convert(fileContent);
      _tafseerMap = {};

      for (var line in lines) {
        if (line.trim().isEmpty) continue;

        try {
          final entry = TafseerEntry.fromLine(line);
          final key = '${entry.suraNo}_${entry.ayaNo}';
          _tafseerMap![key] = entry;
        } catch (e) {
          debugPrint('خطأ في معالجة سطر: $e');
        }
      }

      _isLoaded = true;
      debugPrint('تم تحميل ${_tafseerMap!.length} تفسير');
    } catch (e) {
      debugPrint('خطأ في تحميل التفسير: $e');
      _tafseerMap = {};
    }
  }

  /// الحصول على تفسير آية محددة
  static TafseerEntry? getTafseer(int surahNumber, int ayahNumber) {
    if (_tafseerMap == null) return null;

    final key = '${surahNumber}_$ayahNumber';
    return _tafseerMap![key];
  }

  /// الحصول على نص التفسير فقط
  static String? getTafseerText(int surahNumber, int ayahNumber) {
    final entry = getTafseer(surahNumber, ayahNumber);
    return entry?.tafseer;
  }

  /// تحقق من أن التفسير محمّل
  static bool get isLoaded => _isLoaded;

  /// الحصول على جميع تفاسير سورة
  static List<TafseerEntry> getSurahTafseer(int surahNumber) {
    if (_tafseerMap == null) return [];

    return _tafseerMap!.values
        .where((entry) => entry.suraNo == surahNumber)
        .toList()
      ..sort((a, b) => a.ayaNo.compareTo(b.ayaNo));
  }
}
