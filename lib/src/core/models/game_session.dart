import 'package:hive/hive.dart';
part 'game_session.g.dart';

@HiveType(typeId: 1)
enum GameMood {
  @HiveField(0)
  great,
  @HiveField(1)
  good,
  @HiveField(2)
  neutral,
  @HiveField(3)
  tired,
  @HiveField(4)
  stressed,
}

@HiveType(typeId: 3)
enum GameCategory {
  @HiveField(0)
  action,
  @HiveField(1)
  adventure,
  @HiveField(2)
  strategy,
  @HiveField(3)
  rpg,
  @HiveField(4)
  sports,
  @HiveField(5)
  puzzle,
  @HiveField(6)
  simulation,
  @HiveField(7)
  other,
}

@HiveType(typeId: 4)
class Achievement {
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String icon;

  @HiveField(4)
  DateTime? unlockedAt;
}

@HiveType(typeId: 2)
class GameSession extends HiveObject {
  GameSession({
    required this.startedAt,
    required this.minutes,
    required this.mood,
    this.notes,
    this.gameCategory = GameCategory.other,
    this.achievements = const [],
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startedAt;

  @HiveField(2)
  int minutes;

  @HiveField(3)
  GameMood mood;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  GameCategory gameCategory;

  @HiveField(6)
  List<Achievement> achievements;

  DateTime get endedAt => startedAt.add(Duration(minutes: minutes));
  
  bool get isToday => DateTime.now().difference(startedAt).inDays == 0;
  
  bool get isThisWeek => DateTime.now().difference(startedAt).inDays <= 7;
}

abstract final class HiveBoxes {
  static const String sessions = 'game_sessions';
  static const String achievements = 'achievements';
  static const String settings = 'settings';
}
