/// أدوات تنظيف وعرض نصوص القرآن الكريم.
class QuranTextUtils {
  /// يزيل العلامات الزخرفية/علامات الوقف التي قد تظهر كحروف غريبة
  /// في بعض الخطوط (مثل: صح، صم، طح ...).
  ///
  /// ملاحظة: لا نحذف التشكيل الأساسي (الفتحة/الضمة/الكسرة...) للحفاظ
  /// على القراءة الصحيحة.
  static String sanitizeAyahText(String text) {
    return text
        .replaceAll(
          RegExp(r'[\u06DD\uFD3E\uFD3F\uFDF0-\uFDFF\uFC00-\uFC1F﴾﴿]'),
          '',
        )
        // نطاق علامات الوقف والرموز القرآنية الصغيرة
        .replaceAll(RegExp(r'[\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// تهيئة نص مبسّط للمطابقة الصوتية (بدون تشكيل/رموز).
  static String normalizeForMatch(String text) {
    return sanitizeAyahText(text)
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[^\u0621-\u064A0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
