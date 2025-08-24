// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingAdapter extends TypeAdapter<Training> {
  @override
  final int typeId = 5;

  @override
  Training read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Training(
      id: fields[0] as String,
      type: fields[1] as String,
      dateTime: fields[2] as DateTime,
      location: fields[3] as String,
      durationMinutes: fields[4] as int,
      description: fields[5] as String?,
      notes: fields[6] as String?,
      exercises: (fields[7] as List?)?.cast<String>(),
      focusArea: fields[8] as String?,
      intensity: fields[9] as int?,
      requiredEquipment: (fields[10] as List?)?.cast<String>(),
      isCompleted: fields[11] as bool,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      weather: fields[14] as String?,
      temperature: fields[15] as double?,
      objectives: (fields[16] as List?)?.cast<TrainingObjective>(),
      coachId: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Training obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.exercises)
      ..writeByte(8)
      ..write(obj.focusArea)
      ..writeByte(9)
      ..write(obj.intensity)
      ..writeByte(10)
      ..write(obj.requiredEquipment)
      ..writeByte(11)
      ..write(obj.isCompleted)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.weather)
      ..writeByte(15)
      ..write(obj.temperature)
      ..writeByte(16)
      ..write(obj.objectives)
      ..writeByte(17)
      ..write(obj.coachId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrainingObjectiveAdapter extends TypeAdapter<TrainingObjective> {
  @override
  final int typeId = 6;

  @override
  TrainingObjective read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingObjective(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      priority: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingObjective obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingObjectiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
