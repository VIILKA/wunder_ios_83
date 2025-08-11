import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 5)
class UserSettings extends HiveObject {
  UserSettings({
    this.dailyGoalMinutes = 120,
    this.weeklyGoalMinutes = 840,
    this.breakReminderMinutes = 60,
    this.notificationsEnabled = true,
    this.darkMode = true,
    this.username = 'Player',
    this.favoriteCategories = const [],
  });

  @HiveField(0)
  int dailyGoalMinutes;

  @HiveField(1)
  int weeklyGoalMinutes;

  @HiveField(2)
  int breakReminderMinutes;

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  bool darkMode;

  @HiveField(5)
  String username;

  @HiveField(6)
  List<String> favoriteCategories;

  double get dailyGoalProgress => 0.0; // Будет вычисляться в провайдере
  double get weeklyGoalProgress => 0.0; // Будет вычисляться в провайдере
}
