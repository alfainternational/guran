import 'package:flutter_test/flutter_test.dart';
import 'package:guran/models/reading_plan.dart';

void main() {
  group('ReadingPlan', () {
    test('creates custom plan with valid total days and portions', () {
      final start = DateTime(2026, 1, 1);
      final plan = ReadingPlan.create(
        startDate: start,
        numberOfDays: 40,
        planType: PlanType.custom,
        targetDailyMinutes: 25,
        sessionsPerDay: 3,
      );

      expect(plan.totalDays, 40);
      expect(plan.dailyPortions, isNotEmpty);
      expect(plan.dailyPortions.first.sessionMinutes.length, 3);
    });

    test('session minute splits are balanced', () {
      final plan = ReadingPlan.create(
        startDate: DateTime(2026, 1, 1),
        numberOfDays: 30,
        planType: PlanType.byJuz,
        targetDailyMinutes: 20,
        sessionsPerDay: 4,
      );

      final sessions = plan.dailyPortions.first.sessionMinutes;
      expect(sessions.length, 4);
      final maxValue = sessions.reduce((a, b) => a > b ? a : b);
      final minValue = sessions.reduce((a, b) => a < b ? a : b);
      expect(maxValue - minValue <= 1, true);
    });
  });
}
