// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 6;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      name: fields[1] as String,
      category: fields[2] as GameCategory,
      rating: fields[3] as double,
      notes: fields[4] as String,
      totalPlayTime: fields[5] as int,
      isWishlist: fields[6] as bool,
      imageUrl: fields[7] as String?,
      releaseDate: fields[8] as DateTime?,
      developer: fields[9] as String?,
      platform: fields[10] as String?,
      id: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.totalPlayTime)
      ..writeByte(6)
      ..write(obj.isWishlist)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.releaseDate)
      ..writeByte(9)
      ..write(obj.developer)
      ..writeByte(10)
      ..write(obj.platform);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
