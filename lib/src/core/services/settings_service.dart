import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../models/game_session.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late Box<UserSettings> _settingsBox;
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _settingsBox = await Hive.openBox<UserSettings>(HiveBoxes.settings);
    _prefs = await SharedPreferences.getInstance();
    
    // Инициализируем настройки по умолчанию, если их нет
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('user_settings', UserSettings());
    }
  }

  UserSettings get settings => _settingsBox.get('user_settings') ?? UserSettings();

  Future<void> updateSettings(UserSettings newSettings) async {
    await _settingsBox.put('user_settings', newSettings);
  }

  Future<void> updateDailyGoal(int minutes) async {
    final currentSettings = settings;
    currentSettings.dailyGoalMinutes = minutes;
    await updateSettings(currentSettings);
  }

  Future<void> updateWeeklyGoal(int minutes) async {
    final currentSettings = settings;
    currentSettings.weeklyGoalMinutes = minutes;
    await updateSettings(currentSettings);
  }

  Future<void> updateBreakReminder(int minutes) async {
    final currentSettings = settings;
    currentSettings.breakReminderMinutes = minutes;
    await updateSettings(currentSettings);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final currentSettings = settings;
    currentSettings.notificationsEnabled = enabled;
    await updateSettings(currentSettings);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final currentSettings = settings;
    currentSettings.darkMode = enabled;
    await updateSettings(currentSettings);
  }

  Future<void> updateUsername(String username) async {
    final currentSettings = settings;
    currentSettings.username = username;
    await updateSettings(currentSettings);
  }

  Future<void> updateFavoriteCategories(List<String> categories) async {
    final currentSettings = settings;
    currentSettings.favoriteCategories = categories;
    await updateSettings(currentSettings);
  }

  // Дополнительные настройки через SharedPreferences
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs.setBool('is_first_launch', isFirst);
  }

  bool get isFirstLaunch => _prefs.getBool('is_first_launch') ?? true;

  Future<void> setLastBreakReminder(DateTime time) async {
    await _prefs.setInt('last_break_reminder', time.millisecondsSinceEpoch);
  }

  DateTime? get lastBreakReminder {
    final timestamp = _prefs.getInt('last_break_reminder');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> setStreakDays(int days) async {
    await _prefs.setInt('streak_days', days);
  }

  int get streakDays => _prefs.getInt('streak_days') ?? 0;

  Future<void> setLastSessionDate(DateTime date) async {
    await _prefs.setInt('last_session_date', date.millisecondsSinceEpoch);
  }

  DateTime? get lastSessionDate {
    final timestamp = _prefs.getInt('last_session_date');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
}
