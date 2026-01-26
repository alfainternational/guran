import 'package:flutter/material.dart';
import '../models/quran_data.dart';
import '../models/reciter.dart';
import '../services/audio_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Surah surah;
  final Reciter reciter;

  const AudioPlayerWidget({
    super.key,
    required this.surah,
    required this.reciter,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _audioService = AudioService();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    // Listen to player state to update play button icon correctly
    _audioService.player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات السورة والقارئ
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(widget.reciter.imageUrl),
                  onBackgroundImageError: (_, __) =>
                      const Icon(Icons.person), // Fallback
                  child: widget.reciter.imageUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سورة ${widget.surah.nameArabic}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'بصوت ${widget.reciter.nameArabic}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // شريط التقدم
            Slider(
              value: _position.inSeconds
                  .toDouble()
                  .clamp(0, _duration.inSeconds.toDouble()),
              max: _duration.inSeconds.toDouble() > 0
                  ? _duration.inSeconds.toDouble()
                  : 1.0,
              onChanged: (value) {
                // التنقل في التلاوة
                _audioService.player.seek(Duration(seconds: value.toInt()));
              },
            ),

            // الوقت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),

            const SizedBox(height: 16),

            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر التراجع 10 ثواني
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () {
                    final newPosition = _position - const Duration(seconds: 10);
                    _audioService.player.seek(newPosition < Duration.zero
                        ? Duration.zero
                        : newPosition);
                  },
                ),

                const SizedBox(width: 20),

                // زر التشغيل/الإيقاف
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B5E20),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),

                const SizedBox(width: 20),

                // زر التقديم 10 ثواني
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () {
                    final newPosition = _position + const Duration(seconds: 10);
                    _audioService.player.seek(
                        newPosition > _duration ? _duration : newPosition);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      if (_position == Duration.zero && _duration == Duration.zero) {
        // Initial play
        await _audioService.playSurah(
          surah: widget.surah,
          reciter: widget.reciter,
        );
      } else {
        await _audioService.resume();
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
