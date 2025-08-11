import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../core/models/game_session.dart';
import '../../../core/models/user_settings.dart';
import '../../../core/models/game.dart';
import '../../../core/services/achievement_service.dart';
import '../../../core/services/settings_service.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider() {
    _box = Hive.box<GameSession>(HiveBoxes.sessions);
    _gamesBox = Hive.box<Game>(GameBoxes.games);
    _sessions = _box.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _games = _gamesBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _achievementService = AchievementService();
    _settingsService = SettingsService();
  }

  late final Box<GameSession> _box;
  late final Box<Game> _gamesBox;
  late List<GameSession> _sessions;
  late List<Game> _games;
  late final AchievementService _achievementService;
  late final SettingsService _settingsService;

  List<GameSession> get sessions => List.unmodifiable(_sessions);
  List<Game> get games => List.unmodifiable(_games);
  List<Achievement> get achievements => _achievementService.allAchievements;
  List<Achievement> get unlockedAchievements =>
      _achievementService.unlockedAchievements;
  UserSettings get settings => _settingsService.settings;

  Future<void> addSession(GameSession session) async {
    await _box.add(session);
    _sessions.insert(0, session);

    // Проверяем достижения
    await _achievementService.checkAndUnlockAchievements(_sessions);

    // Обновляем статистику
    _updateStreak(session);

    notifyListeners();
  }

  Future<void> deleteSession(int index) async {
    final GameSession session = _sessions.removeAt(index);
    await session.delete();
    notifyListeners();
  }

  Future<void> updateSession(GameSession session) async {
    await session.save();
    _sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
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

  int totalMinutesToday() {
    return _sessions
        .where((s) => s.isToday)
        .fold<int>(0, (sum, s) => sum + s.minutes);
  }

  int totalMinutesThisWeek() {
    final DateTime weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    return _sessions
        .where((s) => s.startedAt.isAfter(weekStart))
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

  Map<GameCategory, int> minutesPerCategory() {
    final Map<GameCategory, int> result = {};
    for (final session in _sessions) {
      result[session.gameCategory] =
          (result[session.gameCategory] ?? 0) + session.minutes;
    }
    return result;
  }

  Map<GameMood, int> sessionsPerMood() {
    final Map<GameMood, int> result = {};
    for (final session in _sessions) {
      result[session.mood] = (result[session.mood] ?? 0) + 1;
    }
    return result;
  }

  double get dailyGoalProgress {
    final todayMinutes = totalMinutesToday();
    final goal = settings.dailyGoalMinutes;
    return goal > 0 ? (todayMinutes / goal).clamp(0.0, 1.0) : 0.0;
  }

  double get weeklyGoalProgress {
    final weekMinutes = totalMinutesThisWeek();
    final goal = settings.weeklyGoalMinutes;
    return goal > 0 ? (weekMinutes / goal).clamp(0.0, 1.0) : 0.0;
  }

  int get streakDays => _settingsService.streakDays;

  List<GameSession> getSessionsByCategory(GameCategory category) {
    return _sessions.where((s) => s.gameCategory == category).toList();
  }

  List<GameSession> getSessionsByMood(GameMood mood) {
    return _sessions.where((s) => s.mood == mood).toList();
  }

  GameSession? getLongestSession() {
    if (_sessions.isEmpty) return null;
    return _sessions.reduce((a, b) => a.minutes > b.minutes ? a : b);
  }

  GameSession? getMostRecentSession() {
    return _sessions.isNotEmpty ? _sessions.first : null;
  }

  double getAverageSessionLength() {
    if (_sessions.isEmpty) return 0.0;
    final totalMinutes = _sessions.fold<int>(0, (sum, s) => sum + s.minutes);
    return totalMinutes / _sessions.length;
  }

  void _updateStreak(GameSession session) {
    final lastSessionDate = _settingsService.lastSessionDate;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (lastSessionDate != null) {
      final lastDate = DateTime(
        lastSessionDate.year,
        lastSessionDate.month,
        lastSessionDate.day,
      );
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        // Продолжаем серию
        _settingsService.setStreakDays(_settingsService.streakDays + 1);
      } else if (difference > 1) {
        // Сбрасываем серию
        _settingsService.setStreakDays(1);
      }
    } else {
      // Первая сессия
      _settingsService.setStreakDays(1);
    }

    _settingsService.setLastSessionDate(today);
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    await _settingsService.updateSettings(newSettings);
    notifyListeners();
  }

  // Game management methods
  Future<void> addGame(Game game) async {
    await _gamesBox.add(game);
    _games.add(game);
    _games.sort((a, b) => a.name.compareTo(b.name));

    // Check game-related achievements
    await _checkGameAchievements();

    notifyListeners();
  }

  Future<void> updateGame(Game game) async {
    await game.save();
    _games.sort((a, b) => a.name.compareTo(b.name));

    // Check game-related achievements
    await _checkGameAchievements();

    notifyListeners();
  }

  Future<void> deleteGame(Game game) async {
    await game.delete();
    _games.remove(game);
    notifyListeners();
  }

  List<Game> get libraryGames => _games.where((g) => !g.isWishlist).toList();
  List<Game> get wishlistGames => _games.where((g) => g.isWishlist).toList();

  Game? getGameById(String id) {
    try {
      return _games.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _checkGameAchievements() async {
    final now = DateTime.now();

    // Game Collector
    final libraryCount = libraryGames.length;
    if (libraryCount >= 25) {
      await _achievementService.unlockAchievement('collector', now);
    }

    // Wishlist Master
    final wishlistCount = wishlistGames.length;
    if (wishlistCount >= 15) {
      await _achievementService.unlockAchievement('wishlist_master', now);
    }

    // Perfectionist
    final perfectGames = libraryGames.where((g) => g.rating == 10.0).length;
    if (perfectGames >= 5) {
      await _achievementService.unlockAchievement('perfectionist', now);
    }
  }
}
