import 'package:flutter_test/flutter_test.dart';
import 'package:interviewai/core/services/streak_service.dart';

void main() {
  group('StreakData.isActiveToday', () {
    test('should_return_false_when_lastDate_is_null', () {
      const data = StreakData(current: 0, longest: 0, lastDate: null);
      expect(data.isActiveToday, isFalse);
    });

    test('should_return_true_when_lastDate_is_today', () {
      final today = DateTime.now();
      final data = StreakData(
        current: 3,
        longest: 5,
        lastDate: DateTime(today.year, today.month, today.day),
      );
      expect(data.isActiveToday, isTrue);
    });

    test('should_return_false_when_lastDate_is_yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final data = StreakData(
        current: 3,
        longest: 5,
        lastDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
      );
      expect(data.isActiveToday, isFalse);
    });

    test('should_return_false_when_lastDate_is_old', () {
      final data = StreakData(current: 10, longest: 10, lastDate: DateTime(2020, 1, 1));
      expect(data.isActiveToday, isFalse);
    });
  });

  group('StreakData fields', () {
    test('should_store_current_and_longest_correctly', () {
      const data = StreakData(current: 7, longest: 14);
      expect(data.current, 7);
      expect(data.longest, 14);
    });

    test('should_allow_current_greater_than_longest_when_constructed', () {
      const data = StreakData(current: 20, longest: 10);
      expect(data.current, 20);
      expect(data.longest, 10);
    });
  });
}
