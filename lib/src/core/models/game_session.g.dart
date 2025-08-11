// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 4;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      unlockedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.unlockedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameSessionAdapter extends TypeAdapter<GameSession> {
  @override
  final int typeId = 2;

  @override
  GameSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameSession(
      startedAt: fields[1] as DateTime,
      minutes: fields[2] as int,
      mood: fields[3] as GameMood,
      notes: fields[4] as String?,
      gameCategory: fields[5] as GameCategory,
      achievements: (fields[6] as List).cast<Achievement>(),
    )..id = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, GameSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startedAt)
      ..writeByte(2)
      ..write(obj.minutes)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.gameCategory)
      ..writeByte(6)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameMoodAdapter extends TypeAdapter<GameMood> {
  @override
  final int typeId = 1;

  @override
  GameMood read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameMood.great;
      case 1:
        return GameMood.good;
      case 2:
        return GameMood.neutral;
      case 3:
        return GameMood.tired;
      case 4:
        return GameMood.stressed;
      default:
        return GameMood.great;
    }
  }

  @override
  void write(BinaryWriter writer, GameMood obj) {
    switch (obj) {
      case GameMood.great:
        writer.writeByte(0);
        break;
      case GameMood.good:
        writer.writeByte(1);
        break;
      case GameMood.neutral:
        writer.writeByte(2);
        break;
      case GameMood.tired:
        writer.writeByte(3);
        break;
      case GameMood.stressed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameCategoryAdapter extends TypeAdapter<GameCategory> {
  @override
  final int typeId = 3;

  @override
  GameCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameCategory.action;
      case 1:
        return GameCategory.adventure;
      case 2:
        return GameCategory.strategy;
      case 3:
        return GameCategory.rpg;
      case 4:
        return GameCategory.sports;
      case 5:
        return GameCategory.puzzle;
      case 6:
        return GameCategory.simulation;
      case 7:
        return GameCategory.other;
      default:
        return GameCategory.action;
    }
  }

  @override
  void write(BinaryWriter writer, GameCategory obj) {
    switch (obj) {
      case GameCategory.action:
        writer.writeByte(0);
        break;
      case GameCategory.adventure:
        writer.writeByte(1);
        break;
      case GameCategory.strategy:
        writer.writeByte(2);
        break;
      case GameCategory.rpg:
        writer.writeByte(3);
        break;
      case GameCategory.sports:
        writer.writeByte(4);
        break;
      case GameCategory.puzzle:
        writer.writeByte(5);
        break;
      case GameCategory.simulation:
        writer.writeByte(6);
        break;
      case GameCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
