// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 5;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      dailyGoalMinutes: fields[0] as int,
      weeklyGoalMinutes: fields[1] as int,
      breakReminderMinutes: fields[2] as int,
      notificationsEnabled: fields[3] as bool,
      darkMode: fields[4] as bool,
      username: fields[5] as String,
      favoriteCategories: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.dailyGoalMinutes)
      ..writeByte(1)
      ..write(obj.weeklyGoalMinutes)
      ..writeByte(2)
      ..write(obj.breakReminderMinutes)
      ..writeByte(3)
      ..write(obj.notificationsEnabled)
      ..writeByte(4)
      ..write(obj.darkMode)
      ..writeByte(5)
      ..write(obj.username)
      ..writeByte(6)
      ..write(obj.favoriteCategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
