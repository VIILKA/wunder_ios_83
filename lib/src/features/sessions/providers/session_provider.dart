import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../core/models/game_session.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider() {
    _box = Hive.box<GameSession>(HiveBoxes.sessions);
    _sessions = _box.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  late final Box<GameSession> _box;
  late List<GameSession> _sessions;

  List<GameSession> get sessions => List.unmodifiable(_sessions);

  Future<void> addSession(GameSession session) async {
    await _box.add(session);
    _sessions.insert(0, session);
    notifyListeners();
  }

  Future<void> deleteSession(int index) async {
    final GameSession session = _sessions.removeAt(index);
    await session.delete();
    notifyListeners();
  }

  int totalMinutesLast7Days() {
    final DateTime threshold = DateTime.now().subtract(const Duration(days: 6));
    return _sessions
        .where(
          (s) => s.startedAt.isAfter(
            DateTime(threshold.year, threshold.month, threshold.day),
          ),
        )
        .fold<int>(0, (sum, s) => sum + s.minutes);
  }

  Map<DateTime, int> minutesPerDayLast14Days() {
    final DateTime today = DateTime.now();
    final Map<DateTime, int> result = {};
    for (int i = 13; i >= 0; i--) {
      final DateTime day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));
      result[day] = 0;
    }
    for (final s in _sessions) {
      final DateTime key = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      if (result.containsKey(key)) {
        result[key] = (result[key] ?? 0) + s.minutes;
      }
    }
    return result;
  }
}
