import 'package:flutter/material.dart';
import '../models/quran_data.dart';
import '../services/local_quran_service.dart';
import '../services/tafseer_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSurahData();
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
    setState(() {
      _selectedAyahNumber = ayah.ayaNo;
    });

    // عرض التفسير
    _showTafseer(ayah);
  }

  void _onAyahLongPress(QuranAyah ayah) {
    setState(() {
      if (_bookmarkedAyahs.contains(ayah.ayaNo)) {
        _bookmarkedAyahs.remove(ayah.ayaNo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إزالة العلامة المرجعية')),
        );
      } else {
        _bookmarkedAyahs.add(ayah.ayaNo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الآية ${ayah.ayaNo} كعلامة مرجعية'),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                setState(() {
                  _bookmarkedAyahs.remove(ayah.ayaNo);
                });
              },
            ),
          ),
        );
      }
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.nameArabic),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurahData,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () {
              // TODO: عرض قائمة العلامات المرجعية
            },
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
    return text
        .replaceAll(
            RegExp(r'[\u06DD\uFD3E\uFD3F\uFDF0-\uFDFF\uFC00-\uFC1F﴾﴿]'), '')
        .trim();
  }
}
