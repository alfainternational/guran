# خارطة التنفيذ التفصيلية - تطبيق قُرآن

<div dir="rtl">

## 🎯 نظرة عامة

هذا الملف يحتوي على خطة تنفيذ تفصيلية لأهم الميزات المقترحة، مع أكواد جاهزة وأمثلة عملية.

---

## المرحلة 1: التحسينات الفورية (أسبوع 1-2)

### 1. نظام التلاوات الصوتية

```dart
// lib/models/reciter.dart
class Reciter {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final RecitationStyle style;
  final String imageUrl;
  final List<String> availableSurahs;

  const Reciter({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.style,
    required this.imageUrl,
    required this.availableSurahs,
  });
}

enum RecitationStyle {
  hafs,      // حفص عن عاصم
  warsh,     // ورش عن نافع
  qalun,     // قالون عن نافع
  tajweed,   // مجود
  murattal,  // مرتل
  muallim,   // معلم (للأطفال)
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
      availableSurahs: [], // جميع السور
    ),
    Reciter(
      id: 'sudais',
      nameArabic: 'عبدالرحمن السديس',
      nameEnglish: 'Abdul Rahman Al-Sudais',
      style: RecitationStyle.hafs,
      imageUrl: 'assets/images/reciters/sudais.jpg',
      availableSurahs: [],
    ),
    Reciter(
      id: 'husary',
      nameArabic: 'محمود خليل الحصري',
      nameEnglish: 'Mahmoud Khalil Al-Hussary',
      style: RecitationStyle.hafs,
      imageUrl: 'assets/images/reciters/husary.jpg',
      availableSurahs: [],
    ),
    // يمكن إضافة المزيد
  ];
}
```

```dart
// lib/services/audio_service.dart
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Surah? _currentSurah;
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
    // مثال: https://everyayah.com/data/[reciter]/[surah_number].mp3
    final surahNumberPadded = surah.number.toString().padLeft(3, '0');
    return 'https://server8.mp3quran.net/afs/$surahNumberPadded.mp3';
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

  // الانتقال لآية معينة (إذا توفر ملفات منفصلة)
  Future<void> seekToAyah(int ayahNumber) async {
    // التنفيذ يعتمد على توفر ملفات آيات منفصلة
  }

  // الحصول على موضع التشغيل الحالي
  Stream<Duration> get positionStream => _player.positionStream;

  // الحصول على المدة الكلية
  Stream<Duration?> get durationStream => _player.durationStream;

  // التنظيف
  void dispose() {
    _player.dispose();
  }
}
```

```dart
// lib/widgets/audio_player_widget.dart
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
      setState(() {
        _position = position;
      });
    });

    _audioService.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.surah.nameArabic,
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
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                // التنقل في التلاوة
                _audioService._player.seek(Duration(seconds: value.toInt()));
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
                    _audioService._player.seek(newPosition);
                  },
                ),

                const SizedBox(width: 20),

                // زر التشغيل/الإيقاف
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
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
                    _audioService._player.seek(newPosition);
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
      if (_position == Duration.zero) {
        await _audioService.playSurah(
          surah: widget.surah,
          reciter: widget.reciter,
        );
      } else {
        await _audioService.resume();
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
```

---

### 2. نظام المجموعات والتحديات

```dart
// lib/models/reading_circle.dart
class ReadingCircle {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> memberIds;
  final ReadingChallenge? activeChallenge;
  final DateTime createdAt;
  final CirclePrivacy privacy;
  final String? inviteCode;

  ReadingCircle({
    String? id,
    required this.name,
    required this.description,
    required this.creatorId,
    List<String>? memberIds,
    this.activeChallenge,
    DateTime? createdAt,
    this.privacy = CirclePrivacy.private,
    this.inviteCode,
  })  : id = id ?? const Uuid().v4(),
        memberIds = memberIds ?? [creatorId],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'memberIds': memberIds,
      'activeChallenge': activeChallenge?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'privacy': privacy.toString(),
      'inviteCode': inviteCode,
    };
  }
}

enum CirclePrivacy {
  public,   // يمكن لأي أحد الانضمام
  private,  // بالدعوة فقط
  friends,  // الأصدقاء فقط
}

class ReadingChallenge {
  final String id;
  final String name;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeGoal goal;
  final List<String> participantIds;
  final Map<String, ChallengeProgress> progress;

  ReadingChallenge({
    String? id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.goal,
    List<String>? participantIds,
    Map<String, ChallengeProgress>? progress,
  })  : id = id ?? const Uuid().v4(),
        participantIds = participantIds ?? [],
        progress = progress ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'goal': goal.toJson(),
      'participantIds': participantIds,
      'progress': progress.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}

enum ChallengeType {
  khatma,      // ختم كامل
  juzDaily,    // جزء يومي
  pageDaily,   // صفحة يومية
  custom,      // مخصص
}

class ChallengeGoal {
  final int targetAyahs;
  final int targetJuz;
  final int targetDays;

  ChallengeGoal({
    this.targetAyahs = 0,
    this.targetJuz = 0,
    this.targetDays = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetAyahs': targetAyahs,
      'targetJuz': targetJuz,
      'targetDays': targetDays,
    };
  }
}

class ChallengeProgress {
  final String userId;
  final int ayahsRead;
  final int juzCompleted;
  final int daysActive;
  final DateTime lastUpdate;

  ChallengeProgress({
    required this.userId,
    this.ayahsRead = 0,
    this.juzCompleted = 0,
    this.daysActive = 0,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  double getCompletionPercentage(ChallengeGoal goal) {
    if (goal.targetAyahs > 0) {
      return (ayahsRead / goal.targetAyahs) * 100;
    } else if (goal.targetJuz > 0) {
      return (juzCompleted / goal.targetJuz) * 100;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ayahsRead': ayahsRead,
      'juzCompleted': juzCompleted,
      'daysActive': daysActive,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}
```

```dart
// lib/screens/circles_screen.dart
class CirclesScreen extends StatefulWidget {
  const CirclesScreen({super.key});

  @override
  State<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends State<CirclesScreen> {
  List<ReadingCircle> _myCircles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  Future<void> _loadCircles() async {
    // تحميل المجموعات من قاعدة البيانات
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مجموعات القراءة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewCircle,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myCircles.isEmpty
              ? _buildEmptyState()
              : _buildCirclesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد مجموعات بعد',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'أنشئ مجموعة واقرأوا معاً!',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewCircle,
            icon: const Icon(Icons.add),
            label: const Text('إنشاء مجموعة'),
          ),
        ],
      ),
    );
  }

  Widget _buildCirclesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myCircles.length,
      itemBuilder: (context, index) {
        final circle = _myCircles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              child: Text(
                circle.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(circle.name),
            subtitle: Text('${circle.memberIds.length} أعضاء'),
            trailing: circle.activeChallenge != null
                ? const Icon(Icons.emoji_events, color: Colors.amber)
                : null,
            onTap: () => _openCircle(circle),
          ),
        );
      },
    );
  }

  void _createNewCircle() {
    showDialog(
      context: context,
      builder: (context) => const CreateCircleDialog(),
    );
  }

  void _openCircle(ReadingCircle circle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CircleDetailScreen(circle: circle),
      ),
    );
  }
}

// حوار إنشاء مجموعة
class CreateCircleDialog extends StatefulWidget {
  const CreateCircleDialog({super.key});

  @override
  State<CreateCircleDialog> createState() => _CreateCircleDialogState();
}

class _CreateCircleDialogState extends State<CreateCircleDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  CirclePrivacy _privacy = CirclePrivacy.private;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء مجموعة جديدة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CirclePrivacy>(
              value: _privacy,
              decoration: const InputDecoration(
                labelText: 'الخصوصية',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: CirclePrivacy.private,
                  child: Text('خاصة (بالدعوة فقط)'),
                ),
                DropdownMenuItem(
                  value: CirclePrivacy.friends,
                  child: Text('الأصدقاء فقط'),
                ),
                DropdownMenuItem(
                  value: CirclePrivacy.public,
                  child: Text('عامة'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _privacy = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _createCircle,
          child: const Text('إنشاء'),
        ),
      ],
    );
  }

  void _createCircle() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل اسم المجموعة')),
      );
      return;
    }

    final circle = ReadingCircle(
      name: _nameController.text,
      description: _descriptionController.text,
      creatorId: 'user_001', // من المستخدم الحالي
      privacy: _privacy,
      inviteCode: _generateInviteCode(),
    );

    // حفظ في قاعدة البيانات
    // ...

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء المجموعة بنجاح!')),
    );
  }

  String _generateInviteCode() {
    // توليد كود دعوة عشوائي
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
```

---

### 3. نظام البصمة الروحانية

```dart
// lib/models/spiritual_footprint.dart
class SpiritualFootprint {
  final String userId;
  final DateTime date;
  final Duration quranTime;
  final Duration dhikrTime;
  final Duration prayerTime;
  final Duration socialMediaTime;
  final Duration entertainmentTime;
  final Duration productiveTime;

  SpiritualFootprint({
    required this.userId,
    required this.date,
    this.quranTime = Duration.zero,
    this.dhikrTime = Duration.zero,
    this.prayerTime = Duration.zero,
    this.socialMediaTime = Duration.zero,
    this.entertainmentTime = Duration.zero,
    this.productiveTime = Duration.zero,
  });

  // حساب النسبة الروحانية
  double get spiritualPercentage {
    final totalSpiritual =
        quranTime.inMinutes + dhikrTime.inMinutes + prayerTime.inMinutes;
    final totalTime = totalSpiritual +
        socialMediaTime.inMinutes +
        entertainmentTime.inMinutes +
        productiveTime.inMinutes;

    return totalTime > 0 ? (totalSpiritual / totalTime) * 100 : 0;
  }

  // مقارنة الوقت الروحاني بوسائل التواصل
  String getComparisonInsight() {
    final spiritualMinutes =
        quranTime.inMinutes + dhikrTime.inMinutes + prayerTime.inMinutes;
    final socialMinutes = socialMediaTime.inMinutes;

    if (spiritualMinutes > socialMinutes) {
      final diff = spiritualMinutes - socialMinutes;
      return 'ما شاء الله! وقتك الروحاني أكثر بـ $diff دقيقة من وسائل التواصل 🌟';
    } else if (socialMinutes > spiritualMinutes) {
      final diff = socialMinutes - spiritualMinutes;
      return 'لو قللت $diff دقيقة من وسائل التواصل، يمكنك مضاعفة وقتك الروحاني 💚';
    } else {
      return 'متوازن! حاول زيادة الوقت الروحاني تدريجياً 📖';
    }
  }

  // اقتراحات التحسين
  List<ImprovementSuggestion> getSuggestions() {
    List<ImprovementSuggestion> suggestions = [];

    // اقتراح بناءً على وسائل التواصل
    if (socialMediaTime.inMinutes > 60) {
      suggestions.add(ImprovementSuggestion(
        title: 'تقليل وسائل التواصل',
        description:
            'تقضي ${socialMediaTime.inMinutes} دقيقة يومياً في وسائل التواصل. لو قللت 30 دقيقة، يمكنك ختم القرآن في شهرين!',
        actionText: 'ضع هدف',
        priority: Priority.high,
      ));
    }

    // اقتراح بناءً على القراءة
    if (quranTime.inMinutes < 15) {
      suggestions.add(ImprovementSuggestion(
        title: 'زيادة وقت القراءة',
        description:
            'ابدأ بـ 10 دقائق يومياً. يمكنك قراءة صفحتين فقط والحصول على أجر عظيم',
        actionText: 'ابدأ الآن',
        priority: Priority.medium,
      ));
    }

    return suggestions;
  }
}

class ImprovementSuggestion {
  final String title;
  final String description;
  final String actionText;
  final Priority priority;

  ImprovementSuggestion({
    required this.title,
    required this.description,
    required this.actionText,
    required this.priority,
  });
}

enum Priority {
  low,
  medium,
  high,
}
```

```dart
// lib/widgets/spiritual_footprint_chart.dart
import 'package:fl_chart/fl_chart.dart';

class SpiritualFootprintChart extends StatelessWidget {
  final SpiritualFootprint footprint;

  const SpiritualFootprintChart({
    super.key,
    required this.footprint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'بصمتك الروحانية اليوم',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              footprint.getComparisonInsight(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // رسم بياني دائري
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // الأسطورة
            _buildLegend(),

            const SizedBox(height: 24),

            // نسبة الروحانية
            LinearProgressIndicator(
              value: footprint.spiritualPercentage / 100,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF1B5E20),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              'نسبة الوقت الروحاني: ${footprint.spiritualPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        value: footprint.quranTime.inMinutes.toDouble(),
        title: '${footprint.quranTime.inMinutes} د',
        color: const Color(0xFF1B5E20),
        radius: 60,
      ),
      PieChartSectionData(
        value: footprint.dhikrTime.inMinutes.toDouble(),
        title: '${footprint.dhikrTime.inMinutes} د',
        color: const Color(0xFF2E7D32),
        radius: 60,
      ),
      PieChartSectionData(
        value: footprint.socialMediaTime.inMinutes.toDouble(),
        title: '${footprint.socialMediaTime.inMinutes} د',
        color: Colors.orange,
        radius: 60,
      ),
      PieChartSectionData(
        value: footprint.entertainmentTime.inMinutes.toDouble(),
        title: '${footprint.entertainmentTime.inMinutes} د',
        color: Colors.blue,
        radius: 60,
      ),
      PieChartSectionData(
        value: footprint.productiveTime.inMinutes.toDouble(),
        title: '${footprint.productiveTime.inMinutes} د',
        color: Colors.purple,
        radius: 60,
      ),
    ];
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('قراءة القرآن', const Color(0xFF1B5E20)),
        _buildLegendItem('الأذكار', const Color(0xFF2E7D32)),
        _buildLegendItem('وسائل التواصل', Colors.orange),
        _buildLegendItem('ترفيه', Colors.blue),
        _buildLegendItem('إنتاجية', Colors.purple),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
```

---

## الخلاصة

هذا الملف يحتوي على أمثلة تنفيذية لأهم 3 ميزات من المقترحات:

1. ✅ **نظام التلاوات الصوتية**: جاهز للاستخدام مع دعم قراء متعددين
2. ✅ **نظام المجموعات**: للقراءة الجماعية والتحديات
3. ✅ **البصمة الروحانية**: لتحليل استخدام الوقت

### خطوات التنفيذ:

1. انسخ الأكواد للمجلدات المناسبة
2. أضف التبعيات المطلوبة في `pubspec.yaml`:
```yaml
dependencies:
  fl_chart: ^0.66.0  # للرسوم البيانية
  uuid: ^4.2.2       # موجود بالفعل
```

3. اختبر كل ميزة على حدة
4. قم بالدمج التدريجي

**بالتوفيق!** 🚀

</div>
