import 'package:flutter_test/flutter_test.dart';
import 'package:guran/utils/quran_text_utils.dart';

void main() {
  group('QuranTextUtils', () {
    test('sanitizeAyahText removes decorative glyphs and preserves words', () {
      const input = 'ٱلْحَمْدُ ۖ لِلَّٰهِ ﴿١﴾';
      final output = QuranTextUtils.sanitizeAyahText(input);
      expect(output, contains('ٱلْحَمْدُ'));
      expect(output, isNot(contains('﴿')));
      expect(output, isNot(contains('ۖ')));
    });

    test('normalizeForMatch removes diacritics and punctuation noise', () {
      const input = 'الرَّحْمَٰنُ، الرَّحِيمُ!';
      final output = QuranTextUtils.normalizeForMatch(input);
      expect(output, isNot(contains('َ')));
      expect(output, isNot(contains('!')));
      expect(output.replaceAll(' ', ''), isNotEmpty);
    });
  });
}
