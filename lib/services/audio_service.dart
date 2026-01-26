import 'package:just_audio/just_audio.dart';
import '../models/quran_data.dart';
import '../models/reciter.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  // ignore: unused_field
  bool _isPlaying = false;
  // ignore: unused_field
  Surah? _currentSurah;
  // ignore: unused_field
  Reciter? _currentReciter;

  // تشغيل سورة
  Future<void> playSurah({
    required Surah surah,
    required Reciter reciter,
  }) async {
    try {
      _currentSurah = surah;
      _currentReciter = reciter;

      // رابط التلاوة (يمكن استخدام API مثل everyayah.com)
      final url = _buildAudioUrl(surah, reciter);

      await _player.setUrl(url);
      await _player.play();

      _isPlaying = true;
    } catch (e) {
      print('خطأ في تشغيل التلاوة: $e');
      rethrow;
    }
  }

  // بناء رابط الصوت
  String _buildAudioUrl(Surah surah, Reciter reciter) {
    // مثال: https://server8.mp3quran.net/afs/[surah_number].mp3
    // Using a default server for now, logic can be expanded based on reciter.id
    final surahNumberPadded = surah.number.toString().padLeft(3, '0');

    // Mapping some simplified logic for demonstration
    String serverUrl = 'https://server8.mp3quran.net/afs';
    if (reciter.id == 'sudais') {
      serverUrl = 'https://server11.mp3quran.net/sds';
    } else if (reciter.id == 'husary') {
      serverUrl = 'https://server13.mp3quran.net/husr';
    }

    return '$serverUrl/$surahNumberPadded.mp3';
  }

  // إيقاف مؤقت
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  // استئناف
  Future<void> resume() async {
    await _player.play();
    _isPlaying = true;
  }

  // إيقاف
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  // الوصول للمشغل مباشرة
  AudioPlayer get player => _player;

  // الحصول على موضع التشغيل الحالي
  Stream<Duration> get positionStream => _player.positionStream;

  // الحصول على المدة الكلية
  Stream<Duration?> get durationStream => _player.durationStream;

  // التنظيف
  void dispose() {
    _player.dispose();
  }
}
