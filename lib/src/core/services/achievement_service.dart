import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_session.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  late Box<Achievement> _achievementsBox;

  Future<void> initialize() async {
    _achievementsBox = await Hive.openBox<Achievement>(HiveBoxes.achievements);
    await _initializeDefaultAchievements();
  }

  Future<void> _initializeDefaultAchievements() async {
    if (_achievementsBox.isEmpty) {
      final defaultAchievements = [
        Achievement(
          id: 'first_session',
          title: 'Getting Started',
          description: 'Complete your first gaming session',
          icon: '🎮',
        ),
        Achievement(
          id: 'week_warrior',
          title: 'Weekly Warrior',
          description: 'Play games for 7 consecutive days',
          icon: '⚔️',
        ),
        Achievement(
          id: 'time_master',
          title: 'Time Master',
          description: 'Spend 10 hours gaming in a week',
          icon: '⏰',
        ),
        Achievement(
          id: 'mood_tracker',
          title: 'Mood Tracker',
          description: 'Record your mood in 10 sessions',
          icon: '😊',
        ),
        Achievement(
          id: 'category_explorer',
          title: 'Genre Explorer',
          description: 'Try games from 5 different categories',
          icon: '🗺️',
        ),
        Achievement(
          id: 'consistency_king',
          title: 'Consistency Champion',
          description: 'Reach your daily goal for 5 consecutive days',
          icon: '👑',
        ),
        Achievement(
          id: 'break_taker',
          title: 'Balanced Gamer',
          description: 'Take healthy breaks between gaming sessions',
          icon: '☕',
        ),
        Achievement(
          id: 'note_taker',
          title: 'Gaming Journal',
          description: 'Add thoughtful notes to 5 sessions',
          icon: '📝',
        ),
        Achievement(
          id: 'marathon_gamer',
          title: 'Marathon Gamer',
          description: 'Play for more than 4 hours in a single session',
          icon: '🏃‍♂️',
        ),
        Achievement(
          id: 'speed_runner',
          title: 'Speed Runner',
          description: 'Complete 10 short sessions under 30 minutes',
          icon: '⚡',
        ),
        Achievement(
          id: 'weekend_warrior',
          title: 'Weekend Warrior',
          description: 'Play more on weekends than weekdays',
          icon: '🎯',
        ),
        Achievement(
          id: 'perfectionist',
          title: 'Perfectionist',
          description: 'Rate 5 games with a perfect 10/10 score',
          icon: '⭐',
        ),
        Achievement(
          id: 'social_gamer',
          title: 'Social Gamer',
          description: 'Add 10 multiplayer or co-op games to library',
          icon: '👥',
        ),
        Achievement(
          id: 'collector',
          title: 'Game Collector',
          description: 'Add 25 games to your library',
          icon: '📚',
        ),
        Achievement(
          id: 'wishlist_master',
          title: 'Wishlist Master',
          description: 'Add 15 games to your wishlist',
          icon: '💫',
        ),
        Achievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Start gaming sessions before 10 AM for 3 days',
          icon: '🌅',
        ),
      ];

      for (final achievement in defaultAchievements) {
        await _achievementsBox.put(achievement.id, achievement);
      }
    }
  }

  List<Achievement> get allAchievements => _achievementsBox.values.toList();

  List<Achievement> get unlockedAchievements =>
      _achievementsBox.values.where((a) => a.unlockedAt != null).toList();

  List<Achievement> get lockedAchievements =>
      _achievementsBox.values.where((a) => a.unlockedAt == null).toList();

  Future<void> checkAndUnlockAchievements(List<GameSession> sessions) async {
    final now = DateTime.now();

    // Первая сессия
    if (sessions.isNotEmpty) {
      await unlockAchievement('first_session', now);
    }

    // Воин недели
    if (_hasConsecutiveDays(sessions, 7)) {
      await unlockAchievement('week_warrior', now);
    }

    // Мастер времени
    final weeklyMinutes = _getWeeklyMinutes(sessions);
    if (weeklyMinutes >= 600) {
      // 10 часов = 600 минут
      await unlockAchievement('time_master', now);
    }

    // Отслеживатель настроения
    final sessionsWithMood = sessions
        .where((s) => s.mood != GameMood.neutral)
        .length;
    if (sessionsWithMood >= 10) {
      await unlockAchievement('mood_tracker', now);
    }

    // Исследователь жанров
    final uniqueCategories = sessions.map((s) => s.gameCategory).toSet().length;
    if (uniqueCategories >= 5) {
      await unlockAchievement('category_explorer', now);
    }

    // Король постоянства
    if (_hasConsecutiveGoalDays(sessions, 5)) {
      await unlockAchievement('consistency_king', now);
    }

    // Записыватель
    final sessionsWithNotes = sessions
        .where((s) => s.notes?.isNotEmpty == true)
        .length;
    if (sessionsWithNotes >= 5) {
      await unlockAchievement('note_taker', now);
    }

    // Marathon Gamer
    final hasMarathonSession = sessions.any(
      (s) => s.minutes >= 240,
    ); // 4 hours = 240 minutes
    if (hasMarathonSession) {
      await unlockAchievement('marathon_gamer', now);
    }

    // Speed Runner
    final shortSessions = sessions.where((s) => s.minutes <= 30).length;
    if (shortSessions >= 10) {
      await unlockAchievement('speed_runner', now);
    }

    // Weekend Warrior
    if (_isWeekendWarrior(sessions)) {
      await unlockAchievement('weekend_warrior', now);
    }

    // Early Bird
    if (_isEarlyBird(sessions)) {
      await unlockAchievement('early_bird', now);
    }
  }

  Future<void> unlockAchievement(String id, DateTime unlockedAt) async {
    final achievement = _achievementsBox.get(id);
    if (achievement != null && achievement.unlockedAt == null) {
      achievement.unlockedAt = unlockedAt;
      await _achievementsBox.put(id, achievement);
    }
  }

  bool _hasConsecutiveDays(List<GameSession> sessions, int days) {
    if (sessions.length < days) return false;

    final sortedSessions =
        sessions
            .map(
              (s) => DateTime(
                s.startedAt.year,
                s.startedAt.month,
                s.startedAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();

    for (int i = 0; i <= sortedSessions.length - days; i++) {
      bool consecutive = true;
      for (int j = 0; j < days - 1; j++) {
        final current = sortedSessions[i + j];
        final next = sortedSessions[i + j + 1];
        if (next.difference(current).inDays != 1) {
          consecutive = false;
          break;
        }
      }
      if (consecutive) return true;
    }
    return false;
  }

  int _getWeeklyMinutes(List<GameSession> sessions) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return sessions
        .where((s) => s.startedAt.isAfter(weekAgo))
        .fold(0, (sum, session) => sum + session.minutes);
  }

  bool _hasConsecutiveGoalDays(List<GameSession> sessions, int days) {
    // Упрощенная логика - проверяем, что есть сессии в течение N дней подряд
    return _hasConsecutiveDays(sessions, days);
  }

  bool _isWeekendWarrior(List<GameSession> sessions) {
    if (sessions.length < 10) return false; // Need enough data

    int weekendMinutes = 0;
    int weekdayMinutes = 0;

    for (final session in sessions) {
      final weekday = session.startedAt.weekday;
      if (weekday == 6 || weekday == 7) {
        // Saturday or Sunday
        weekendMinutes += session.minutes;
      } else {
        weekdayMinutes += session.minutes;
      }
    }

    // Weekend gaming should be significantly more than weekday gaming
    return weekendMinutes > weekdayMinutes * 1.5;
  }

  bool _isEarlyBird(List<GameSession> sessions) {
    final earlyMorningSessions = sessions.where((session) {
      final hour = session.startedAt.hour;
      return hour >= 6 && hour < 10; // Between 6 AM and 10 AM
    }).toList();

    if (earlyMorningSessions.length < 3) return false;

    // Check if there are early sessions on 3 different days
    final earlyDays = earlyMorningSessions
        .map(
          (s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day),
        )
        .toSet();

    return earlyDays.length >= 3;
  }
}
