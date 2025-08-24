import 'package:hive/hive.dart';

part 'match.g.dart';

@HiveType(typeId: 3)
class Match {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String opponent;
  
  @HiveField(2)
  final DateTime dateTime;
  
  @HiveField(3)
  final String location;
  
  @HiveField(4)
  final bool isHome;
  
  @HiveField(5)
  final String? result; // 'Vittoria', 'Pareggio', 'Sconfitta'
  
  @HiveField(6)
  final int? goalsFor;
  
  @HiveField(7)
  final int? goalsAgainst;
  
  @HiveField(8)
  final String? notes;
  
  @HiveField(9)
  final String? opponentStrengths;
  
  @HiveField(10)
  final String? opponentWeaknesses;
  
  @HiveField(11)
  final String? formation;
  
  @HiveField(12)
  final List<String>? lineup; // Player IDs
  
  @HiveField(13)
  final List<String>? substitutes; // Player IDs
  
  @HiveField(14)
  final List<MatchEvent>? events;
  
  @HiveField(15)
  final bool isCompleted;
  
  @HiveField(16)
  final DateTime createdAt;
  
  @HiveField(17)
  final DateTime updatedAt;
  
  @HiveField(18)
  final String? competitionType; // 'Campionato', 'Coppa', 'Amichevole'
  
  @HiveField(19)
  final String? referee;
  
  @HiveField(20)
  final Map<String, double>? playerRatings; // Player ID -> Rating

  Match({
    required this.id,
    required this.opponent,
    required this.dateTime,
    required this.location,
    required this.isHome,
    this.result,
    this.goalsFor,
    this.goalsAgainst,
    this.notes,
    this.opponentStrengths,
    this.opponentWeaknesses,
    this.formation,
    this.lineup,
    this.substitutes,
    this.events,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.competitionType,
    this.referee,
    this.playerRatings,
  });

  // Get match status
  String get status {
    if (isCompleted) return 'Completata';
    final now = DateTime.now();
    if (dateTime.isAfter(now)) return 'Programmata';
    return 'In corso';
  }

  // Get match result display
  String get resultDisplay {
    if (goalsFor != null && goalsAgainst != null) {
      return '$goalsFor - $goalsAgainst';
    }
    return result ?? 'N/A';
  }

  // Get competition emoji
  String get competitionEmoji {
    switch (competitionType?.toLowerCase()) {
      case 'campionato':
        return '🏆';
      case 'coppa':
        return '🥇';
      case 'amichevole':
        return '⚽';
      default:
        return '⚽';
    }
  }

  // Get venue display
  String get venueDisplay {
    return isHome ? '$location (Casa)' : '$location (Trasferta)';
  }

  // Copy with method for immutability
  Match copyWith({
    String? id,
    String? opponent,
    DateTime? dateTime,
    String? location,
    bool? isHome,
    String? result,
    int? goalsFor,
    int? goalsAgainst,
    String? notes,
    String? opponentStrengths,
    String? opponentWeaknesses,
    String? formation,
    List<String>? lineup,
    List<String>? substitutes,
    List<MatchEvent>? events,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? competitionType,
    String? referee,
    Map<String, double>? playerRatings,
  }) {
    return Match(
      id: id ?? this.id,
      opponent: opponent ?? this.opponent,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      isHome: isHome ?? this.isHome,
      result: result ?? this.result,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      notes: notes ?? this.notes,
      opponentStrengths: opponentStrengths ?? this.opponentStrengths,
      opponentWeaknesses: opponentWeaknesses ?? this.opponentWeaknesses,
      formation: formation ?? this.formation,
      lineup: lineup ?? this.lineup,
      substitutes: substitutes ?? this.substitutes,
      events: events ?? this.events,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      competitionType: competitionType ?? this.competitionType,
      referee: referee ?? this.referee,
      playerRatings: playerRatings ?? this.playerRatings,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opponent': opponent,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'location': location,
      'isHome': isHome,
      'result': result,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'notes': notes,
      'opponentStrengths': opponentStrengths,
      'opponentWeaknesses': opponentWeaknesses,
      'formation': formation,
      'lineup': lineup,
      'substitutes': substitutes,
      'events': events?.map((e) => e.toJson()).toList(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'competitionType': competitionType,
      'referee': referee,
      'playerRatings': playerRatings,
    };
  }

  // From JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      opponent: json['opponent'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
      location: json['location'],
      isHome: json['isHome'],
      result: json['result'],
      goalsFor: json['goalsFor'],
      goalsAgainst: json['goalsAgainst'],
      notes: json['notes'],
      opponentStrengths: json['opponentStrengths'],
      opponentWeaknesses: json['opponentWeaknesses'],
      formation: json['formation'],
      lineup: json['lineup'] != null 
          ? List<String>.from(json['lineup'])
          : null,
      substitutes: json['substitutes'] != null 
          ? List<String>.from(json['substitutes'])
          : null,
      events: json['events'] != null 
          ? (json['events'] as List)
              .map((e) => MatchEvent.fromJson(e))
              .toList()
          : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      competitionType: json['competitionType'],
      referee: json['referee'],
      playerRatings: json['playerRatings'] != null 
          ? Map<String, double>.from(json['playerRatings'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Match && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Match(id: $id, opponent: $opponent, dateTime: $dateTime, result: $result)';
  }
}

@HiveType(typeId: 4)
class MatchEvent {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type; // 'goal', 'yellowCard', 'redCard', 'substitution'
  
  @HiveField(2)
  final int minute;
  
  @HiveField(3)
  final String playerId;
  
  @HiveField(4)
  final String? assistPlayerId;
  
  @HiveField(5)
  final String? notes;
  
  @HiveField(6)
  final String? substitutedPlayerId; // For substitutions

  MatchEvent({
    required this.id,
    required this.type,
    required this.minute,
    required this.playerId,
    this.assistPlayerId,
    this.notes,
    this.substitutedPlayerId,
  });

  // Get event icon
  String get icon {
    switch (type.toLowerCase()) {
      case 'goal':
        return '⚽';
      case 'yellowcard':
        return '🟨';
      case 'redcard':
        return '🟥';
      case 'substitution':
        return '🔄';
      default:
        return '📝';
    }
  }

  MatchEvent copyWith({
    String? id,
    String? type,
    int? minute,
    String? playerId,
    String? assistPlayerId,
    String? notes,
    String? substitutedPlayerId,
  }) {
    return MatchEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      minute: minute ?? this.minute,
      playerId: playerId ?? this.playerId,
      assistPlayerId: assistPlayerId ?? this.assistPlayerId,
      notes: notes ?? this.notes,
      substitutedPlayerId: substitutedPlayerId ?? this.substitutedPlayerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'minute': minute,
      'playerId': playerId,
      'assistPlayerId': assistPlayerId,
      'notes': notes,
      'substitutedPlayerId': substitutedPlayerId,
    };
  }

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    return MatchEvent(
      id: json['id'],
      type: json['type'],
      minute: json['minute'],
      playerId: json['playerId'],
      assistPlayerId: json['assistPlayerId'],
      notes: json['notes'],
      substitutedPlayerId: json['substitutedPlayerId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MatchEvent(id: $id, type: $type, minute: $minute, playerId: $playerId)';
  }
}
