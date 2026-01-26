import 'package:flutter/foundation.dart';
import '../models/dhikr.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// موفر حالة الأذكار
class DhikrProvider with ChangeNotifier {
  final _db = DatabaseService();
  final _notificationService = NotificationService();

  DhikrProgress? _progress;
  List<Dhikr> _currentDhikrList = [];
  int _currentRepetition = 0;

  DhikrProgress? get progress => _progress;
  List<Dhikr> get currentDhikrList => _currentDhikrList;
  int get currentRepetition => _currentRepetition;

  /// تحميل تقدم الأذكار
  Future<void> loadProgress(String userId) async {
    _progress = await _db.getDhikrProgress(userId);
    if (_progress == null) {
      _progress = DhikrProgress(userId: userId);
      await _db.saveDhikrProgress(_progress!);
    }
    notifyListeners();
  }

  /// تحميل أذكار حسب الفئة
  void loadDhikrByCategory(DhikrCategory category) {
    _currentDhikrList = DhikrData.getAdhkarByCategory(category);
    notifyListeners();
  }

  /// تحميل أذكار حسب الوقت
  void loadDhikrByTime(DhikrTime time) {
    _currentDhikrList = DhikrData.getAdhkarByTime(time);
    notifyListeners();
  }

  /// تحميل أذكار الصباح
  void loadMorningAdhkar() {
    _currentDhikrList = DhikrData.morningAdhkar;
    notifyListeners();
  }

  /// تحميل أذكار المساء
  void loadEveningAdhkar() {
    _currentDhikrList = DhikrData.eveningAdhkar;
    notifyListeners();
  }

  /// تحميل الأذكار المخصصة
  Future<void> loadCustomDhikr() async {
    final customAdhkar = await _db.getCustomAdhkar();
    _currentDhikrList = customAdhkar;
    notifyListeners();
  }

  /// إضافة ذكر مخصص
  Future<void> addCustomDhikr(Dhikr dhikr) async {
    await _db.saveCustomDhikr(dhikr);
    // إذا كنا في صفحة الأذكار المخصصة، نعيد التحميل
    if (_currentDhikrList.isNotEmpty && _currentDhikrList.first.isCustom) {
      await loadCustomDhikr();
    }
  }

  /// حذف ذكر مخصص
  Future<void> deleteCustomDhikr(String id) async {
    await _db.deleteCustomDhikr(id);
    if (_currentDhikrList.isNotEmpty && _currentDhikrList.first.isCustom) {
      await loadCustomDhikr();
    }
  }

  /// تحميل أذكار عامة
  void loadGeneralAdhkar() {
    _currentDhikrList = DhikrData.generalAdhkar;
    notifyListeners();
  }

  /// بدء ذكر جديد
  void startDhikr(String dhikrId) {
    _currentRepetition = 0;
    notifyListeners();
  }

  /// زيادة العدد
  void incrementRepetition() {
    _currentRepetition++;
    notifyListeners();
  }

  /// إكمال ذكر
  Future<void> completeDhikr(String dhikrId, int repetitions) async {
    if (_progress == null) return;

    final completion = DhikrCompletion(
      dhikrId: dhikrId,
      completedAt: DateTime.now(),
      repetitionsCompleted: repetitions,
    );

    _progress!.completions[dhikrId] = completion;
    await _db.saveDhikrProgress(_progress!);

    _currentRepetition = 0;

    notifyListeners();

    // إرسال تشجيع
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'بارك الله فيك',
      body: 'أكملت الذكر بنجاح ✨',
    );
  }

  /// التحقق من إكمال ذكر معين اليوم
  bool isDhikrCompletedToday(String dhikrId) {
    if (_progress == null) return false;

    final completion = _progress!.completions[dhikrId];
    if (completion == null) return false;

    final now = DateTime.now();
    final completedDate = completion.completedAt;

    return now.year == completedDate.year &&
        now.month == completedDate.month &&
        now.day == completedDate.day;
  }

  /// الحصول على عدد الأذكار المكتملة اليوم
  int getTodayCompletedCount() {
    if (_progress == null) return 0;

    final now = DateTime.now();
    return _progress!.completions.values.where((completion) {
      return now.year == completion.completedAt.year &&
          now.month == completion.completedAt.month &&
          now.day == completion.completedAt.day;
    }).length;
  }

  /// الحصول على نسبة إكمال أذكار الصباح
  double getMorningAdhkarProgress() {
    final total = DhikrData.morningAdhkar.length;
    final completed = DhikrData.morningAdhkar
        .where((d) => isDhikrCompletedToday(d.id))
        .length;

    return total > 0 ? completed / total : 0.0;
  }

  /// الحصول على نسبة إكمال أذكار المساء
  double getEveningAdhkarProgress() {
    final total = DhikrData.eveningAdhkar.length;
    final completed = DhikrData.eveningAdhkar
        .where((d) => isDhikrCompletedToday(d.id))
        .length;

    return total > 0 ? completed / total : 0.0;
  }

  /// إعادة تعيين الذكر الحالي
  void resetCurrent() {
    _currentRepetition = 0;
    notifyListeners();
  }
}
