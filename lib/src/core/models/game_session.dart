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

@HiveType(typeId: 2)
class GameSession extends HiveObject {
  GameSession({
    required this.startedAt,
    required this.minutes,
    required this.mood,
    this.notes,
  });

  @HiveField(0)
  DateTime startedAt;

  @HiveField(1)
  int minutes;

  @HiveField(2)
  GameMood mood;

  @HiveField(3)
  String? notes;
}

abstract final class HiveBoxes {
  static const String sessions = 'game_sessions';
}
