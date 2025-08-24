import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int? number;
  
  @HiveField(3)
  final String position;
  
  @HiveField(4)
  final DateTime? birthDate;
  
  @HiveField(5)
  final String? phone;
  
  @HiveField(6)
  final String? email;
  
  @HiveField(7)
  final String? photo;
  
  @HiveField(8)
  final bool isActive;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;
  
  @HiveField(11)
  final String? notes;
  
  @HiveField(12)
  final double? height;
  
  @HiveField(13)
  final double? weight;
  
  @HiveField(14)
  final String? emergencyContact;
  
  @HiveField(15)
  final String? emergencyPhone;

  Player({
    required this.id,
    required this.name,
    this.number,
    required this.position,
    this.birthDate,
    this.phone,
    this.email,
    this.photo,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.height,
    this.weight,
    this.emergencyContact,
    this.emergencyPhone,
  });

  // Calculate age
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Get initials
  String get initials {
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  // Compatibility getter for older code
  String? get photoUrl => photo;

  // Copy with method for immutability
  Player copyWith({
    String? id,
    String? name,
    int? number,
    String? position,
    DateTime? birthDate,
    String? phone,
    String? email,
    String? photo,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    double? height,
    double? weight,
    String? emergencyContact,
    String? emergencyPhone,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      position: position ?? this.position,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'position': position,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'phone': phone,
      'email': email,
      'photo': photo,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'notes': notes,
      'height': height,
      'weight': weight,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
    };
  }

  // From JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      number: json['number'],
      position: json['position'],
      birthDate: json['birthDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['birthDate']) : null,
      phone: json['phone'],
      email: json['email'],
      photo: json['photo'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      notes: json['notes'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Player(id: $id, name: $name, number: ${number ?? 'N/A'}, position: $position)';
  }
}

// Player statistics model
@HiveType(typeId: 1)
class PlayerStats {
  @HiveField(0)
  final String playerId;
  
  @HiveField(1)
  final int matchesPlayed;
  
  @HiveField(2)
  final int goals;
  
  @HiveField(3)
  final int assists;
  
  @HiveField(4)
  final int yellowCards;
  
  @HiveField(5)
  final int redCards;
  
  @HiveField(6)
  final int trainingsAttended;
  
  @HiveField(7)
  final int totalTrainings;
  
  @HiveField(8)
  final double averageRating;
  
  @HiveField(9)
  final DateTime lastUpdated;

  PlayerStats({
    required this.playerId,
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.trainingsAttended = 0,
    this.totalTrainings = 0,
    this.averageRating = 0.0,
    required this.lastUpdated,
  });

  double get attendancePercentage {
    if (totalTrainings == 0) return 0.0;
    return (trainingsAttended / totalTrainings) * 100;
  }

  PlayerStats copyWith({
    String? playerId,
    int? matchesPlayed,
    int? goals,
    int? assists,
    int? yellowCards,
    int? redCards,
    int? trainingsAttended,
    int? totalTrainings,
    double? averageRating,
    DateTime? lastUpdated,
  }) {
    return PlayerStats(
      playerId: playerId ?? this.playerId,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      trainingsAttended: trainingsAttended ?? this.trainingsAttended,
      totalTrainings: totalTrainings ?? this.totalTrainings,
      averageRating: averageRating ?? this.averageRating,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'matchesPlayed': matchesPlayed,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'trainingsAttended': trainingsAttended,
      'totalTrainings': totalTrainings,
      'averageRating': averageRating,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerId: json['playerId'],
      matchesPlayed: json['matchesPlayed'] ?? 0,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      yellowCards: json['yellowCards'] ?? 0,
      redCards: json['redCards'] ?? 0,
      trainingsAttended: json['trainingsAttended'] ?? 0,
      totalTrainings: json['totalTrainings'] ?? 0,
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
    );
  }
}
