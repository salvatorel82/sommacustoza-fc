import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 7)
class Attendance {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String playerId;
  
  @HiveField(2)
  final String eventId; // Training or Match ID
  
  @HiveField(3)
  final String eventType; // 'training' or 'match'
  
  @HiveField(4)
  final String status; // 'presente', 'assente', 'giustificato', 'infortunato'
  
  @HiveField(5)
  final DateTime eventDate;
  
  @HiveField(6)
  final String? notes;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime updatedAt;
  
  @HiveField(9)
  final String? excuseReason;
  
  @HiveField(10)
  final bool isLate;
  
  @HiveField(11)
  final int? minutesLate;
  
  @HiveField(12)
  final String? reportedBy; // Staff ID who reported the attendance

  Attendance({
    required this.id,
    required this.playerId,
    required this.eventId,
    required this.eventType,
    required this.status,
    required this.eventDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.excuseReason,
    this.isLate = false,
    this.minutesLate,
    this.reportedBy,
  });

  // Get status emoji
  String get statusEmoji {
    switch (status.toLowerCase()) {
      case 'presente':
        return '✅';
      case 'assente':
        return '❌';
      case 'giustificato':
        return '📝';
      case 'infortunato':
        return '🏥';
      default:
        return '❓';
    }
  }

  // Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'presente':
        return 'green';
      case 'assente':
        return 'red';
      case 'giustificato':
        return 'orange';
      case 'infortunato':
        return 'purple';
      default:
        return 'grey';
    }
  }

  // Get display text for status
  String get statusDisplay {
    String display = status;
    if (isLate && minutesLate != null) {
      display += ' (in ritardo di ${minutesLate}m)';
    }
    return display;
  }

  // Check if attendance is positive (present or excused)
  bool get isPositive {
    return status.toLowerCase() == 'presente' || 
           status.toLowerCase() == 'giustificato';
  }

  // Copy with method for immutability
  Attendance copyWith({
    String? id,
    String? playerId,
    String? eventId,
    String? eventType,
    String? status,
    DateTime? eventDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? excuseReason,
    bool? isLate,
    int? minutesLate,
    String? reportedBy,
  }) {
    return Attendance(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      eventDate: eventDate ?? this.eventDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      excuseReason: excuseReason ?? this.excuseReason,
      isLate: isLate ?? this.isLate,
      minutesLate: minutesLate ?? this.minutesLate,
      reportedBy: reportedBy ?? this.reportedBy,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'eventId': eventId,
      'eventType': eventType,
      'status': status,
      'eventDate': eventDate.millisecondsSinceEpoch,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'excuseReason': excuseReason,
      'isLate': isLate,
      'minutesLate': minutesLate,
      'reportedBy': reportedBy,
    };
  }

  // From JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      playerId: json['playerId'],
      eventId: json['eventId'],
      eventType: json['eventType'],
      status: json['status'],
      eventDate: DateTime.fromMillisecondsSinceEpoch(json['eventDate']),
      notes: json['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      excuseReason: json['excuseReason'],
      isLate: json['isLate'] ?? false,
      minutesLate: json['minutesLate'],
      reportedBy: json['reportedBy'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Attendance(id: $id, playerId: $playerId, eventId: $eventId, status: $status)';
  }
}

// Attendance statistics model
class AttendanceStats {
  final String playerId;
  final int totalEvents;
  final int presentCount;
  final int absentCount;
  final int excusedCount;
  final int injuredCount;
  final double attendancePercentage;
  final int trainingEvents;
  final int matchEvents;
  final int trainingPresent;
  final int matchPresent;

  AttendanceStats({
    required this.playerId,
    required this.totalEvents,
    required this.presentCount,
    required this.absentCount,
    required this.excusedCount,
    required this.injuredCount,
    required this.attendancePercentage,
    required this.trainingEvents,
    required this.matchEvents,
    required this.trainingPresent,
    required this.matchPresent,
  });

  double get trainingAttendancePercentage {
    if (trainingEvents == 0) return 0.0;
    return (trainingPresent / trainingEvents) * 100;
  }

  double get matchAttendancePercentage {
    if (matchEvents == 0) return 0.0;
    return (matchPresent / matchEvents) * 100;
  }

  // Calculate stats from attendance list
  factory AttendanceStats.fromAttendanceList(
    String playerId,
    List<Attendance> attendances,
  ) {
    final totalEvents = attendances.length;
    int presentCount = 0;
    int absentCount = 0;
    int excusedCount = 0;
    int injuredCount = 0;
    int trainingEvents = 0;
    int matchEvents = 0;
    int trainingPresent = 0;
    int matchPresent = 0;

    for (final attendance in attendances) {
      switch (attendance.status.toLowerCase()) {
        case 'presente':
          presentCount++;
          break;
        case 'assente':
          absentCount++;
          break;
        case 'giustificato':
          excusedCount++;
          break;
        case 'infortunato':
          injuredCount++;
          break;
      }

      if (attendance.eventType == 'training') {
        trainingEvents++;
        if (attendance.status.toLowerCase() == 'presente') {
          trainingPresent++;
        }
      } else if (attendance.eventType == 'match') {
        matchEvents++;
        if (attendance.status.toLowerCase() == 'presente') {
          matchPresent++;
        }
      }
    }

    final attendancePercentage = totalEvents > 0 
        ? (presentCount / totalEvents) * 100
        : 0.0;

    return AttendanceStats(
      playerId: playerId,
      totalEvents: totalEvents,
      presentCount: presentCount,
      absentCount: absentCount,
      excusedCount: excusedCount,
      injuredCount: injuredCount,
      attendancePercentage: attendancePercentage,
      trainingEvents: trainingEvents,
      matchEvents: matchEvents,
      trainingPresent: trainingPresent,
      matchPresent: matchPresent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'totalEvents': totalEvents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'excusedCount': excusedCount,
      'injuredCount': injuredCount,
      'attendancePercentage': attendancePercentage,
      'trainingEvents': trainingEvents,
      'matchEvents': matchEvents,
      'trainingPresent': trainingPresent,
      'matchPresent': matchPresent,
    };
  }

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      playerId: json['playerId'],
      totalEvents: json['totalEvents'],
      presentCount: json['presentCount'],
      absentCount: json['absentCount'],
      excusedCount: json['excusedCount'],
      injuredCount: json['injuredCount'],
      attendancePercentage: json['attendancePercentage'].toDouble(),
      trainingEvents: json['trainingEvents'],
      matchEvents: json['matchEvents'],
      trainingPresent: json['trainingPresent'],
      matchPresent: json['matchPresent'],
    );
  }
}
