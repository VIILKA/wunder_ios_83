// Manual Hive adapters to avoid code generation
// ignore_for_file: constant_identifier_names

part of 'game_session.dart';

class GameMoodAdapter extends TypeAdapter<GameMood> {
  @override
  final int typeId = 1;

  @override
  GameMood read(BinaryReader reader) {
    final int value = reader.readInt();
    switch (value) {
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
        return GameMood.neutral;
    }
  }

  @override
  void write(BinaryWriter writer, GameMood obj) {
    int value = 2;
    switch (obj) {
      case GameMood.great:
        value = 0;
        break;
      case GameMood.good:
        value = 1;
        break;
      case GameMood.neutral:
        value = 2;
        break;
      case GameMood.tired:
        value = 3;
        break;
      case GameMood.stressed:
        value = 4;
        break;
    }
    writer.writeInt(value);
  }
}

class GameSessionAdapter extends TypeAdapter<GameSession> {
  @override
  final int typeId = 2;

  @override
  GameSession read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return GameSession(
      startedAt: fields[0] as DateTime,
      minutes: fields[1] as int,
      mood: fields[2] as GameMood,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GameSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startedAt)
      ..writeByte(1)
      ..write(obj.minutes)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.notes);
  }
}
