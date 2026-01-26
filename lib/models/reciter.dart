enum RecitationStyle {
  hafs, // حفص عن عاصم
  warsh, // ورش عن نافع
  qalun, // قالون عن نافع
  tajweed, // مجود
  murattal, // مرتل
  muallim, // معلم (للأطفال)
}

class Reciter {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final RecitationStyle style;
  final String imageUrl;

  const Reciter({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.style,
    required this.imageUrl,
  });
}

// قائمة القراء المشهورين
class RecitersData {
  static const List<Reciter> reciters = [
    Reciter(
      id: 'mishary',
      nameArabic: 'مشاري بن راشد العفاسي',
      nameEnglish: 'Mishary Alafasy',
      style: RecitationStyle.hafs,
      imageUrl: 'assets/images/reciters/mishary.jpg',
    ),
    Reciter(
      id: 'sudais',
      nameArabic: 'عبدالرحمن السديس',
      nameEnglish: 'Abdul Rahman Al-Sudais',
      style: RecitationStyle.hafs,
      imageUrl: 'assets/images/reciters/sudais.jpg',
    ),
    Reciter(
      id: 'husary',
      nameArabic: 'محمود خليل الحصري',
      nameEnglish: 'Mahmoud Khalil Al-Hussary',
      style: RecitationStyle.hafs,
      imageUrl: 'assets/images/reciters/husary.jpg',
    ),
  ];
}
