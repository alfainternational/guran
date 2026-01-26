import 'package:flutter/material.dart';

/// Widget لعرض رقم الآية في دائرة زخرفية
class AyahNumber extends StatelessWidget {
  final int number;
  final double size;
  final Color? color;

  const AyahNumber({
    super.key,
    required this.number,
    this.size = 28,
    this.color,
  });

  /// تحويل الأرقام العربية إلى أرقام هندية
  String _toArabicIndic(int number) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      if (digit.contains(RegExp(r'[0-9]'))) {
        return arabicIndic[int.parse(digit)];
      }
      return digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color ?? const Color(0xFF1B5E20),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          _toArabicIndic(number),
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1B5E20),
            fontFamily: 'Amiri',
          ),
        ),
      ),
    );
  }
}
