import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quran_data.dart';
import '../services/local_quran_service.dart';
import '../services/recitation_tracking_service.dart';
import '../services/tafseer_service.dart';
import '../providers/reading_provider.dart';
import '../utils/quran_text_utils.dart';
import '../widgets/ayah_widget.dart';

/// شاشة قراءة السورة المتقدمة مع التحديد والتفسير
class SurahReaderScreen extends StatefulWidget {
  final Surah surah;

  const SurahReaderScreen({super.key, required this.surah});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  List<QuranAyah>? _ayahs;
  bool _isLoading = true;
  int? _selectedAyahNumber;
  Set<int> _bookmarkedAyahs = {};
  Set<int> _readAyahs = {};
  DateTime? _lastAyahTapAt;
  final RecitationTrackingService _recitationTrackingService =
      RecitationTrackingService();
  int _autoTrackStartIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  @override
  void dispose() {
    _recitationTrackingService.stopTracking();
    super.dispose();
  }

  Future<void> _loadSurahData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // التأكد من تحميل البيانات
      if (!LocalQuranService.isLoaded) {
        await LocalQuranService.loadQuranData();
      }
      if (!TafseerService.isLoaded) {
        await TafseerService.loadTafseer();
      }

      final ayahs = LocalQuranService.getSurahAyahs(widget.surah.number);
      setState(() {
        _ayahs = ayahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ayahs = null;
        _isLoading = false;
      });
      debugPrint('خطأ في تحميل السورة: $e');
    }
  }

  void _onAyahTap(QuranAyah ayah) {
    final now = DateTime.now();
    final dwellSeconds =
        _lastAyahTapAt == null ? 6 : now.difference(_lastAyahTapAt!).inSeconds;
    _lastAyahTapAt = now;

    context.read<ReadingProvider>().recordValidatedAyahRead(
          surahNumber: widget.surah.number,
          ayahNumber: ayah.ayaNo,
          dwellSeconds: dwellSeconds,
        );
    context.read<ReadingProvider>().setTemporaryStopMarker(
          surahNumber: widget.surah.number,
          ayahNumber: ayah.ayaNo,
        );

    if (dwellSeconds < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الانتقال كان سريعًا جدًا، لن تُحتسب هذه الآية بعد.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _selectedAyahNumber = ayah.ayaNo;
      _readAyahs.add(ayah.ayaNo);
      _autoTrackStartIndex = (_ayahs ?? []).indexWhere((a) => a.ayaNo == ayah.ayaNo);
      if (_autoTrackStartIndex < 0) _autoTrackStartIndex = 0;
    });

    // عرض التفسير
    _showTafseer(ayah);
  }

  void _onAyahLongPress(QuranAyah ayah) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _bookmarkedAyahs.contains(ayah.ayaNo)
                      ? Icons.bookmark_remove_rounded
                      : Icons.bookmark_add_rounded,
                ),
                title: Text(_bookmarkedAyahs.contains(ayah.ayaNo)
                    ? 'إزالة العلامة المرجعية'
                    : 'إضافة علامة مرجعية'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    if (_bookmarkedAyahs.contains(ayah.ayaNo)) {
                      _bookmarkedAyahs.remove(ayah.ayaNo);
                    } else {
                      _bookmarkedAyahs.add(ayah.ayaNo);
                    }
                  });
                },
              ),
              Consumer<ReadingProvider>(
                builder: (context, provider, _) {
                  final hasMarker = provider.isManualStopMarker(
                    surahNumber: widget.surah.number,
                    ayahNumber: ayah.ayaNo,
                  );
                  return ListTile(
                    leading: Icon(hasMarker
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded),
                    title:
                        Text(hasMarker ? 'إزالة علامة التوقف' : 'وضع علامة توقف'),
                    onTap: () {
                      Navigator.pop(context);
                      provider.toggleManualStopMarker(
                        surahNumber: widget.surah.number,
                        ayahNumber: ayah.ayaNo,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTafseer(QuranAyah ayah) {
    final tafseer = TafseerService.getTafseer(widget.surah.number, ayah.ayaNo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // رأس Bottom Sheet
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التفسير الميسر',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        Text(
                          '${widget.surah.nameArabic} - الآية ${ayah.ayaNo}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(height: 32),

              // نص الآية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _cleanText(ayah.ayaText),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 24,
                    height: 1.8,
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // التفسير
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: tafseer != null && tafseer.tafseer.isNotEmpty
                      ? Text(
                          _cleanText(tafseer.tafseer),
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.8,
                            color: Colors.black87,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'التفسير غير متوفر لهذه الآية',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readingProvider = context.watch<ReadingProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.nameArabic),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          Consumer<ReadingProvider>(
            builder: (context, readingProvider, _) {
              if (!readingProvider.isReading) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'المحتسب: ${readingProvider.validatedAyahReadsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _recitationTrackingService.isListening
                  ? Icons.mic_rounded
                  : Icons.mic_none_rounded,
            ),
            tooltip: _recitationTrackingService.isListening
                ? 'إيقاف التتبع الصوتي'
                : 'بدء التتبع الصوتي',
            onPressed: _toggleVoiceTracking,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurahData,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: _showBookmarksSheet,
            tooltip: 'العلامات المرجعية',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1B5E20),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل النص والتفسير...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : _ayahs == null || _ayahs!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لم يتم العثور على نص السورة',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadSurahData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // رأس السورة
                    _buildSurahHeader(),

                    // البسملة
                    if (widget.surah.number != 9 && widget.surah.number != 1)
                      _buildBasmallah(),

                    // قائمة الآيات
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _ayahs!.length,
                        itemBuilder: (context, index) {
                          final ayah = _ayahs![index];
                          return AyahWidget(
                            ayah: ayah,
                            isSelected: _selectedAyahNumber == ayah.ayaNo,
                            isBookmarked: _bookmarkedAyahs.contains(ayah.ayaNo),
                            isRead: _readAyahs.contains(ayah.ayaNo),
                            isPauseMarked:
                                readingProvider.temporaryStopSurah ==
                                        widget.surah.number &&
                                    readingProvider.temporaryStopAyah ==
                                        ayah.ayaNo,
                            isManualStop: readingProvider.isManualStopMarker(
                              surahNumber: widget.surah.number,
                              ayahNumber: ayah.ayaNo,
                            ),
                            onTap: () => _onAyahTap(ayah),
                            onLongPress: () => _onAyahLongPress(ayah),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            widget.surah.nameArabic,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Amiri',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.surah.nameEnglish,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(widget.surah.revelationType),
              const SizedBox(width: 12),
              _buildInfoChip('${widget.surah.totalAyahs} آية'),
              const SizedBox(width: 12),
              _buildInfoChip('الجزء ${widget.surah.juz}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBasmallah() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  /// تنظيف النص من الرموز الخاصة
  String _cleanText(String text) {
    return QuranTextUtils.sanitizeAyahText(text);
  }

  Future<void> _toggleVoiceTracking() async {
    if (_ayahs == null || _ayahs!.isEmpty) return;

    if (_recitationTrackingService.isListening) {
      await _recitationTrackingService.stopTracking();
      if (!mounted) return;
      setState(() {});
      return;
    }

    final started = await _recitationTrackingService.startTracking(
      ayahs: _ayahs!,
      startIndex: _autoTrackStartIndex,
      onMatch: (index) {
        if (!mounted || _ayahs == null) return;
        final ayah = _ayahs![index];
        _onAutoTrackAyah(ayah, index);
      },
    );

    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر بدء التتبع الصوتي. تأكد من إذن الميكروفون.'),
        ),
      );
    }
    setState(() {});
  }

  void _onAutoTrackAyah(QuranAyah ayah, int index) {
    context.read<ReadingProvider>().recordValidatedAyahRead(
          surahNumber: widget.surah.number,
          ayahNumber: ayah.ayaNo,
          dwellSeconds: 6,
        );
    context.read<ReadingProvider>().setTemporaryStopMarker(
          surahNumber: widget.surah.number,
          ayahNumber: ayah.ayaNo,
        );

    setState(() {
      _selectedAyahNumber = ayah.ayaNo;
      _readAyahs.add(ayah.ayaNo);
      _autoTrackStartIndex = index;
    });
  }

  void _showBookmarksSheet() {
    if (_bookmarkedAyahs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد علامات مرجعية بعد')),
      );
      return;
    }

    final sorted = _bookmarkedAyahs.toList()..sort();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ayahNo = sorted[index];
              final ayah = _ayahs?.firstWhere(
                (a) => a.ayaNo == ayahNo,
                orElse: () => QuranAyah(
                  id: 0,
                  jozz: 0,
                  page: 0,
                  suraNo: widget.surah.number,
                  suraNameEn: '',
                  suraNameAr: widget.surah.nameArabic,
                  ayaNo: ayahNo,
                  ayaText: '',
                  ayaTextEmlaey: '',
                ),
              );

              return ListTile(
                leading: const Icon(Icons.bookmark, color: Color(0xFFF57C00)),
                title: Text('الآية $ayahNo'),
                subtitle: Text(
                  ayah != null
                      ? QuranTextUtils.sanitizeAyahText(ayah.ayaText)
                          .split(' ')
                          .take(10)
                          .join(' ')
                      : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (ayah != null) {
                    _onAyahTap(ayah);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
