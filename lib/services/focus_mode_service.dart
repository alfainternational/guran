import 'dart:async';
import 'notification_service.dart';

/// وضع تركيز مبسط أثناء جلسة القراءة.
/// ملاحظة: الحظر الإجباري للتطبيقات يتطلب تكاملات Native متقدمة تختلف حسب المنصة.
class FocusModeService {
  static final FocusModeService _instance = FocusModeService._internal();
  factory FocusModeService() => _instance;
  FocusModeService._internal();

  final _notification = NotificationService();

  Timer? _timer;
  DateTime? _endsAt;
  bool _active = false;

  bool get isActive => _active;
  DateTime? get endsAt => _endsAt;

  Future<void> startFocusMode({required int durationMinutes}) async {
    await stopFocusMode();
    _active = true;
    _endsAt = DateTime.now().add(Duration(minutes: durationMinutes));

    await _notification.showNotification(
      id: 9001,
      title: '🎯 وضع التركيز',
      body: 'بدأت جلسة تركيز لمدة $durationMinutes دقيقة.',
    );

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_endsAt == null) return;
      if (DateTime.now().isAfter(_endsAt!)) {
        await _notification.showNotification(
          id: 9002,
          title: '✅ انتهت جلسة التركيز',
          body: 'أحسنت! يمكنك مراجعة تقدمك الآن.',
        );
        await stopFocusMode();
      }
    });
  }

  Future<void> stopFocusMode() async {
    _timer?.cancel();
    _timer = null;
    _endsAt = null;
    _active = false;
  }
}
