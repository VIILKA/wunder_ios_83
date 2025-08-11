import 'package:hive/hive.dart';
import 'game_session.dart';
part 'game.g.dart';

@HiveType(typeId: 6)
class Game extends HiveObject {
  Game({
    required this.name,
    required this.category,
    this.rating = 0.0,
    this.notes = '',
    this.totalPlayTime = 0,
    this.isWishlist = false,
    this.imageUrl,
    this.releaseDate,
    this.developer,
    this.platform,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  GameCategory category;

  @HiveField(3)
  double rating; // 0-10

  @HiveField(4)
  String notes;

  @HiveField(5)
  int totalPlayTime; // в минутах

  @HiveField(6)
  bool isWishlist;

  @HiveField(7)
  String? imageUrl;

  @HiveField(8)
  DateTime? releaseDate;

  @HiveField(9)
  String? developer;

  @HiveField(10)
  String? platform;

  // Getters
  String get formattedPlayTime {
    if (totalPlayTime < 60) {
      return '$totalPlayTime min';
    } else {
      final hours = totalPlayTime ~/ 60;
      final minutes = totalPlayTime % 60;
      return minutes > 0 ? '$hours h $minutes min' : '$hours h';
    }
  }

  bool get hasRating => rating > 0;
}

abstract final class GameBoxes {
  static const String games = 'games';
}
