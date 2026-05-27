import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const _keyLastDate = 'streak_last_date';
  static const _keyCount = 'streak_count';
  static const _keyLongest = 'streak_longest';

  Future<StreakData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_keyLastDate);
    final count = prefs.getInt(_keyCount) ?? 0;
    final longest = prefs.getInt(_keyLongest) ?? 0;
    return StreakData(
      current: count,
      longest: longest,
      lastDate: lastStr != null ? DateTime.parse(lastStr) : null,
    );
  }

  // 세션 완료 시 호출 — 오늘 이미 기록한 경우엔 무시
  Future<StreakData> recordToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _toDay(DateTime.now());
    final lastStr = prefs.getString(_keyLastDate);
    final lastDay = lastStr != null ? _toDay(DateTime.parse(lastStr)) : null;

    if (lastDay == today) {
      return load();
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final prev = prefs.getInt(_keyCount) ?? 0;
    final newCount = (lastDay == yesterday) ? prev + 1 : 1;
    final longest = (prefs.getInt(_keyLongest) ?? 0).clamp(newCount, 9999);

    await prefs.setString(_keyLastDate, today.toIso8601String());
    await prefs.setInt(_keyCount, newCount);
    await prefs.setInt(_keyLongest, longest);

    return StreakData(current: newCount, longest: longest, lastDate: today);
  }

  DateTime _toDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

class StreakData {
  final int current;
  final int longest;
  final DateTime? lastDate;

  const StreakData({
    required this.current,
    required this.longest,
    this.lastDate,
  });

  bool get isActiveToday {
    if (lastDate == null) return false;
    final today = DateTime.now();
    return lastDate!.year == today.year &&
        lastDate!.month == today.month &&
        lastDate!.day == today.day;
  }
}
