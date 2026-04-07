import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../utils/quran_text_utils.dart';
import 'local_quran_service.dart';

typedef RecitationMatchCallback = void Function(int ayahIndex);

/// تتبع تقريبي للقراءة المسموعة ونقل التظليل بين الآيات.
class RecitationTrackingService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  bool _listening = false;
  int _currentIndex = 0;

  bool get isListening => _listening;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: (e) => debugPrint('speech error: ${e.errorMsg}'),
      onStatus: (s) {
        debugPrint('speech status: $s');
        if (s.toLowerCase().contains('notlistening') ||
            s.toLowerCase().contains('done')) {
          _listening = false;
        }
      },
    );
    return _initialized;
  }

  Future<bool> startTracking({
    required List<QuranAyah> ayahs,
    required int startIndex,
    required RecitationMatchCallback onMatch,
    double confidenceThreshold = 0.35,
  }) async {
    final ready = await initialize();
    if (!ready) return false;
    if (_listening) await stopTracking();
    _currentIndex = startIndex.clamp(0, ayahs.length - 1);

    _listening = true;
    await _speech.listen(
      localeId: 'ar_SA',
      listenMode: ListenMode.confirmation,
      partialResults: true,
      onResult: (result) {
        final transcript = result.recognizedWords;
        final confidence = result.confidence;
        if (confidence > 0 && confidence < confidenceThreshold) return;
        final matched = _findBestAyahIndex(
          ayahs: ayahs,
          transcript: transcript,
          startIndex: _currentIndex,
        );
        if (matched != null) {
          _currentIndex = matched;
          onMatch(matched);
        }
      },
    );
    return true;
  }

  Future<void> stopTracking() async {
    if (!_listening) return;
    await _speech.stop();
    _listening = false;
  }

  int? _findBestAyahIndex({
    required List<QuranAyah> ayahs,
    required String transcript,
    required int startIndex,
  }) {
    final normalized = QuranTextUtils.normalizeForMatch(transcript);
    if (normalized.length < 5) return null;

    final windowStart = startIndex.clamp(0, ayahs.length - 1);
    final windowEnd = (windowStart + 8).clamp(0, ayahs.length - 1);

    for (int i = windowStart; i <= windowEnd; i++) {
      final ayahText = QuranTextUtils.normalizeForMatch(ayahs[i].ayaText);
      if (ayahText.isEmpty) continue;

      final words = ayahText.split(' ');
      final probeSize = words.length >= 9 ? 7 : (words.length >= 5 ? 5 : 3);
      final probe = words.take(probeSize).join(' ');
      if (probe.isNotEmpty && normalized.contains(probe)) {
        return i;
      }
    }
    return null;
  }
}
