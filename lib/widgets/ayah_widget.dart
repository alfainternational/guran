import 'package:flutter/material.dart';
import '../services/local_quran_service.dart';
import '../widgets/ayah_number_widget.dart';

/// Widget لعرض آية واحدة قابلة للتحديد والنقر
class AyahWidget extends StatelessWidget {
  final QuranAyah ayah;
  final bool isSelected;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AyahWidget({
    super.key,
    required this.ayah,
    this.isSelected = false,
    this.isBookmarked = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F5E9)
              : (isBookmarked ? const Color(0xFFFFF9C4) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF1B5E20), width: 2)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نص الآية (يأتي أولاً)
            Expanded(
              child: RichText(
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _cleanAyahText(ayah.ayaText),
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        height: 1.8,
                        color: isSelected
                            ? const Color(0xFF1B5E20)
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const TextSpan(text: ' '), // مسافة
                    // رقم الآية (يأتي بعد النص)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: AyahNumber(
                          number: ayah.ayaNo,
                          size: 28,
                          color: isSelected ? const Color(0xFF1B5E20) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // أيقونة العلامة المرجعية
            if (isBookmarked)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.bookmark,
                  color: Color(0xFFF57C00),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// إزالة رموز ترقيم الآيات الخاصة من النص
  String _cleanAyahText(String text) {
    // إزالة جميع الرموز Unicode الخاصة بترقيم الآيات والزخارف
    // النطاق ﰀ-ﰟ (U+FC00 - U+FC1F) ورموز أخرى
    return text
        .replaceAll(
            RegExp(r'[\u06DD\uFD3E\uFD3F\uFDF0-\uFDFF\uFC00-\uFC1F﴾﴿]'), '')
        .trim();
  }
}
