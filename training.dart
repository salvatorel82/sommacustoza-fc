import 'package:hive/hive.dart';

part 'training.g.dart';

@HiveType(typeId: 5)
class Training {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type;
  
  @HiveField(2)
  final DateTime dateTime;
  
  @HiveField(3)
  final String location;
  
  @HiveField(4)
  final int durationMinutes;
  
  @HiveField(5)
  final String? description;
  
  @HiveField(6)
  final String? notes;
  
  @HiveField(7)
  final List<String>? exercises;
  
  @HiveField(8)
  final String? focusArea;
  
  @HiveField(9)
  final int? intensity; // 1-10 scale
  
  @HiveField(10)
  final List<String>? requiredEquipment;
  
  @HiveField(11)
  final bool isCompleted;
  
  @HiveField(12)
  final DateTime createdAt;
  
  @HiveField(13)
  final DateTime updatedAt;
  
  @HiveField(14)
  final String? weather;
  
  @HiveField(15)
  final double? temperature;
  
  @HiveField(16)
  final List<TrainingObjective>? objectives;
  
  @HiveField(17)
  final String? coachId; // Staff ID of the coach

  Training({
    required this.id,
    required this.type,
    required this.dateTime,
    required this.location,
    required this.durationMinutes,
    this.description,
    this.notes,
    this.exercises,
    this.focusArea,
    this.intensity,
    this.requiredEquipment,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.weather,
    this.temperature,
    this.objectives,
    this.coachId,
  });

  // Get training status
  String get status {
    if (isCompleted) return 'Completato';
    final now = DateTime.now();
    if (dateTime.isAfter(now)) return 'Programmato';
    if (dateTime.isBefore(now) && !isCompleted) return 'In ritardo';
    return 'In corso';
  }

  // Get training emoji based on type
  String get typeEmoji {
    switch (type.toLowerCase()) {
      case 'tecnico':
        return '⚽';
      case 'tattico':
        return '📋';
      case 'fisico':
        return '💪';
      case 'portieri':
        return '🥅';
      case 'palle inattive':
        return '🎯';
      case 'partitella':
        return '🏃';
      case 'resistenza':
        return '🏃‍♂️';
      case 'velocità':
        return '⚡';
      case 'forza':
        return '🏋️';
      case 'recupero attivo':
        return '🧘';
      default:
        return '⚽';
    }
  }

  // Get intensity color
  String get intensityColor {
    if (intensity == null) return 'grey';
    if (intensity! <= 3) return 'green';
    if (intensity! <= 6) return 'orange';
    return 'red';
  }

  // Get duration display
  String get durationDisplay {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  // Copy with method for immutability
  Training copyWith({
    String? id,
    String? type,
    DateTime? dateTime,
    String? location,
    int? durationMinutes,
    String? description,
    String? notes,
    List<String>? exercises,
    String? focusArea,
    int? intensity,
    List<String>? requiredEquipment,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? weather,
    double? temperature,
    List<TrainingObjective>? objectives,
    String? coachId,
  }) {
    return Training(
      id: id ?? this.id,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      focusArea: focusArea ?? this.focusArea,
      intensity: intensity ?? this.intensity,
      requiredEquipment: requiredEquipment ?? this.requiredEquipment,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      objectives: objectives ?? this.objectives,
      coachId: coachId ?? this.coachId,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'location': location,
      'durationMinutes': durationMinutes,
      'description': description,
      'notes': notes,
      'exercises': exercises,
      'focusArea': focusArea,
      'intensity': intensity,
      'requiredEquipment': requiredEquipment,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'weather': weather,
      'temperature': temperature,
      'objectives': objectives?.map((e) => e.toJson()).toList(),
      'coachId': coachId,
    };
  }

  // From JSON
  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'],
      type: json['type'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
      location: json['location'],
      durationMinutes: json['durationMinutes'],
      description: json['description'],
      notes: json['notes'],
      exercises: json['exercises'] != null 
          ? List<String>.from(json['exercises'])
          : null,
      focusArea: json['focusArea'],
      intensity: json['intensity'],
      requiredEquipment: json['requiredEquipment'] != null 
          ? List<String>.from(json['requiredEquipment'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      weather: json['weather'],
      temperature: json['temperature']?.toDouble(),
      objectives: json['objectives'] != null 
          ? (json['objectives'] as List)
              .map((e) => TrainingObjective.fromJson(e))
              .toList()
          : null,
      coachId: json['coachId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Training && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Training(id: $id, type: $type, dateTime: $dateTime, location: $location)';
  }
}

@HiveType(typeId: 6)
class TrainingObjective {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final bool isCompleted;
  
  @HiveField(4)
  final int? priority; // 1-5 scale

  TrainingObjective({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority,
  });

  String get priorityText {
    switch (priority) {
      case 1:
        return 'Molto Bassa';
      case 2:
        return 'Bassa';
      case 3:
        return 'Media';
      case 4:
        return 'Alta';
      case 5:
        return 'Molto Alta';
      default:
        return 'Non definita';
    }
  }

  TrainingObjective copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? priority,
  }) {
    return TrainingObjective(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  factory TrainingObjective.fromJson(Map<String, dynamic> json) {
    return TrainingObjective(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingObjective && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TrainingObjective(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
