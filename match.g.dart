// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchAdapter extends TypeAdapter<Match> {
  @override
  final int typeId = 3;

  @override
  Match read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Match(
      id: fields[0] as String,
      opponent: fields[1] as String,
      dateTime: fields[2] as DateTime,
      location: fields[3] as String,
      isHome: fields[4] as bool,
      result: fields[5] as String?,
      goalsFor: fields[6] as int?,
      goalsAgainst: fields[7] as int?,
      notes: fields[8] as String?,
      opponentStrengths: fields[9] as String?,
      opponentWeaknesses: fields[10] as String?,
      formation: fields[11] as String?,
      lineup: (fields[12] as List?)?.cast<String>(),
      substitutes: (fields[13] as List?)?.cast<String>(),
      events: (fields[14] as List?)?.cast<MatchEvent>(),
      isCompleted: fields[15] as bool,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime,
      competitionType: fields[18] as String?,
      referee: fields[19] as String?,
      playerRatings: (fields[20] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, Match obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.opponent)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.isHome)
      ..writeByte(5)
      ..write(obj.result)
      ..writeByte(6)
      ..write(obj.goalsFor)
      ..writeByte(7)
      ..write(obj.goalsAgainst)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.opponentStrengths)
      ..writeByte(10)
      ..write(obj.opponentWeaknesses)
      ..writeByte(11)
      ..write(obj.formation)
      ..writeByte(12)
      ..write(obj.lineup)
      ..writeByte(13)
      ..write(obj.substitutes)
      ..writeByte(14)
      ..write(obj.events)
      ..writeByte(15)
      ..write(obj.isCompleted)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt)
      ..writeByte(18)
      ..write(obj.competitionType)
      ..writeByte(19)
      ..write(obj.referee)
      ..writeByte(20)
      ..write(obj.playerRatings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatchEventAdapter extends TypeAdapter<MatchEvent> {
  @override
  final int typeId = 4;

  @override
  MatchEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchEvent(
      id: fields[0] as String,
      type: fields[1] as String,
      minute: fields[2] as int,
      playerId: fields[3] as String,
      assistPlayerId: fields[4] as String?,
      notes: fields[5] as String?,
      substitutedPlayerId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MatchEvent obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.playerId)
      ..writeByte(4)
      ..write(obj.assistPlayerId)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.substitutedPlayerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
