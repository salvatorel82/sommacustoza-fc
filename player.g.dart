// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      id: fields[0] as String,
      name: fields[1] as String,
      number: fields[2] as int?,
      position: fields[3] as String,
      birthDate: fields[4] as DateTime?,
      phone: fields[5] as String?,
      email: fields[6] as String?,
      photo: fields[7] as String?,
      isActive: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      notes: fields[11] as String?,
      height: fields[12] as double?,
      weight: fields[13] as double?,
      emergencyContact: fields[14] as String?,
      emergencyPhone: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.birthDate)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.photo)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.height)
      ..writeByte(13)
      ..write(obj.weight)
      ..writeByte(14)
      ..write(obj.emergencyContact)
      ..writeByte(15)
      ..write(obj.emergencyPhone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerStatsAdapter extends TypeAdapter<PlayerStats> {
  @override
  final int typeId = 1;

  @override
  PlayerStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStats(
      playerId: fields[0] as String,
      matchesPlayed: fields[1] as int,
      goals: fields[2] as int,
      assists: fields[3] as int,
      yellowCards: fields[4] as int,
      redCards: fields[5] as int,
      trainingsAttended: fields[6] as int,
      totalTrainings: fields[7] as int,
      averageRating: fields[8] as double,
      lastUpdated: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStats obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.matchesPlayed)
      ..writeByte(2)
      ..write(obj.goals)
      ..writeByte(3)
      ..write(obj.assists)
      ..writeByte(4)
      ..write(obj.yellowCards)
      ..writeByte(5)
      ..write(obj.redCards)
      ..writeByte(6)
      ..write(obj.trainingsAttended)
      ..writeByte(7)
      ..write(obj.totalTrainings)
      ..writeByte(8)
      ..write(obj.averageRating)
      ..writeByte(9)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
