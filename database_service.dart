import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/staff.dart';
import '../models/match.dart';
import '../models/training.dart';
import '../models/attendance.dart';
import '../../core/constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  static DatabaseService get instance => _instance;

  // Boxes
  late Box<Player> _playersBox;
  late Box<Staff> _staffBox;
  late Box<Match> _matchesBox;
  late Box<Training> _trainingsBox;
  late Box<Attendance> _attendanceBox;
  late Box _settingsBox;

  // Initialize database
  Future<void> initDatabase() async {
    try {
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PlayerAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PlayerStatsAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(StaffAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(MatchAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(MatchEventAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(TrainingAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(TrainingObjectiveAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(AttendanceAdapter());
      }

      // Open boxes
      _playersBox = await Hive.openBox<Player>(AppConstants.playersBox);
      _staffBox = await Hive.openBox<Staff>(AppConstants.staffBox);
      _matchesBox = await Hive.openBox<Match>(AppConstants.matchesBox);
      _trainingsBox = await Hive.openBox<Training>(AppConstants.trainingsBox);
      _attendanceBox = await Hive.openBox<Attendance>(AppConstants.attendanceBox);
      _settingsBox = await Hive.openBox(AppConstants.settingsBox);

      print('Database inizializzato. Giocatori: ${_playersBox.length}, Staff: ${_staffBox.length}'); // Debug
      
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }



  // Players CRUD operations
  Future<void> addPlayer(Player player) async {
    await _playersBox.put(player.id, player);
    print('Giocatore salvato: ${player.name} (ID: ${player.id}). Totale giocatori: ${_playersBox.length}'); // Debug
  }

  Future<void> updatePlayer(Player player) async {
    await _playersBox.put(player.id, player);
  }

  Future<void> deletePlayer(String playerId) async {
    await _playersBox.delete(playerId);
    // Also delete related attendance records
    await _deletePlayerAttendance(playerId);
  }

  Player? getPlayer(String playerId) {
    return _playersBox.get(playerId);
  }

  List<Player> getAllPlayers() {
    final players = _playersBox.values.toList();
    print('Caricati ${players.length} giocatori dal database Hive'); // Debug
    for (final player in players) {
      print('  - ${player.name} (${player.position}) [${player.isActive ? "Attivo" : "Disattivo"}]');
    }
    return players;
  }

  List<Player> getPlayersByPosition(String position) {
    return _playersBox.values
        .where((player) => player.isActive && player.position == position)
        .toList();
  }

  // Staff CRUD operations
  Future<void> addStaff(Staff staff) async {
    await _staffBox.put(staff.id, staff);
    print('Staff salvato: ${staff.name} (ID: ${staff.id}). Totale staff: ${_staffBox.length}'); // Debug
  }

  Future<void> updateStaff(Staff staff) async {
    await _staffBox.put(staff.id, staff);
  }

  Future<void> deleteStaff(String staffId) async {
    await _staffBox.delete(staffId);
  }

  Staff? getStaff(String staffId) {
    return _staffBox.get(staffId);
  }

  List<Staff> getAllStaff() {
    final staff = _staffBox.values.toList();
    print('Caricati ${staff.length} membri staff dal database Hive'); // Debug
    for (final member in staff) {
      print('  - ${member.name} (${member.role}) [${member.isActive ? "Attivo" : "Disattivo"}]');
    }
    return staff;
  }

  List<Staff> getStaffByRole(String role) {
    return _staffBox.values
        .where((staff) => staff.isActive && staff.role == role)
        .toList();
  }

  // Matches CRUD operations
  Future<void> addMatch(Match match) async {
    await _matchesBox.put(match.id, match);
  }

  Future<void> updateMatch(Match match) async {
    await _matchesBox.put(match.id, match);
  }

  Future<void> deleteMatch(String matchId) async {
    await _matchesBox.delete(matchId);
    // Also delete related attendance records
    await _deleteEventAttendance(matchId);
  }

  Match? getMatch(String matchId) {
    return _matchesBox.get(matchId);
  }

  List<Match> getAllMatches() {
    return _matchesBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<Match> getUpcomingMatches() {
    final now = DateTime.now();
    return _matchesBox.values
        .where((match) => match.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Match> getCompletedMatches() {
    return _matchesBox.values
        .where((match) => match.isCompleted)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Trainings CRUD operations
  Future<void> addTraining(Training training) async {
    await _trainingsBox.put(training.id, training);
    print('Allenamento salvato nel DB: ${training.type} del ${training.dateTime} (ID: ${training.id}). Totale: ${_trainingsBox.length}'); // Debug
  }

  Future<void> updateTraining(Training training) async {
    await _trainingsBox.put(training.id, training);
  }

  Future<void> deleteTraining(String trainingId) async {
    await _trainingsBox.delete(trainingId);
    // Also delete related attendance records
    await _deleteEventAttendance(trainingId);
  }

  Training? getTraining(String trainingId) {
    return _trainingsBox.get(trainingId);
  }

  List<Training> getAllTrainings() {
    final trainings = _trainingsBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    print('Caricati ${trainings.length} allenamenti dal database Hive'); // Debug
    for (final training in trainings) {
      print('  - ${training.type} del ${training.dateTime.day}/${training.dateTime.month}/${training.dateTime.year}');
    }
    return trainings;
  }

  List<Training> getUpcomingTrainings() {
    final now = DateTime.now();
    return _trainingsBox.values
        .where((training) => training.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Training> getTrainingsByType(String type) {
    return _trainingsBox.values
        .where((training) => training.type == type)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Attendance CRUD operations
  Future<void> addAttendance(Attendance attendance) async {
    await _attendanceBox.put(attendance.id, attendance);
    print('DatabaseService: Presenza salvata - ID: ${attendance.id}, Player: ${attendance.playerId}, Status: ${attendance.status}'); // Debug
    print('DatabaseService: Totale presenze nel DB: ${_attendanceBox.length}'); // Debug
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _attendanceBox.put(attendance.id, attendance);
    print('DatabaseService: Presenza aggiornata - ID: ${attendance.id}, Nuovo status: ${attendance.status}'); // Debug
  }

  Future<void> deleteAttendance(String attendanceId) async {
    await _attendanceBox.delete(attendanceId);
    print('DatabaseService: Presenza eliminata - ID: $attendanceId. Rimanenti: ${_attendanceBox.length}'); // Debug
  }

  Attendance? getAttendance(String attendanceId) {
    return _attendanceBox.get(attendanceId);
  }

  List<Attendance> getAllAttendance() {
    final attendances = _attendanceBox.values.toList();
    print('DatabaseService: Caricate ${attendances.length} presenze dal DB Hive'); // Debug
    return attendances;
  }

  List<Attendance> getPlayerAttendance(String playerId) {
    return _attendanceBox.values
        .where((attendance) => attendance.playerId == playerId)
        .toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
  }

  List<Attendance> getEventAttendance(String eventId) {
    return _attendanceBox.values
        .where((attendance) => attendance.eventId == eventId)
        .toList();
  }

  Future<void> _deletePlayerAttendance(String playerId) async {
    final playerAttendance = getPlayerAttendance(playerId);
    for (final attendance in playerAttendance) {
      await _attendanceBox.delete(attendance.id);
    }
  }

  Future<void> _deleteEventAttendance(String eventId) async {
    final eventAttendance = getEventAttendance(eventId);
    for (final attendance in eventAttendance) {
      await _attendanceBox.delete(attendance.id);
    }
  }

  // Settings operations
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  Map<String, dynamic> getAllSettings() {
    final settings = <String, dynamic>{};
    for (final key in _settingsBox.keys) {
      settings[key.toString()] = _settingsBox.get(key);
    }
    return settings;
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportData() async {
    return {
      'players': _playersBox.values.map((p) => p.toJson()).toList(),
      'staff': _staffBox.values.map((s) => s.toJson()).toList(),
      'matches': _matchesBox.values.map((m) => m.toJson()).toList(),
      'trainings': _trainingsBox.values.map((t) => t.toJson()).toList(),
      'attendance': _attendanceBox.values.map((a) => a.toJson()).toList(),
      'settings': getAllSettings(),
      'exportDate': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await _playersBox.clear();
      await _staffBox.clear();
      await _matchesBox.clear();
      await _trainingsBox.clear();
      await _attendanceBox.clear();
      await _settingsBox.clear();

      // Import players
      if (data['players'] != null) {
        for (final playerJson in data['players']) {
          final player = Player.fromJson(playerJson);
          await _playersBox.put(player.id, player);
        }
      }

      // Import staff
      if (data['staff'] != null) {
        for (final staffJson in data['staff']) {
          final staff = Staff.fromJson(staffJson);
          await _staffBox.put(staff.id, staff);
        }
      }

      // Import matches
      if (data['matches'] != null) {
        for (final matchJson in data['matches']) {
          final match = Match.fromJson(matchJson);
          await _matchesBox.put(match.id, match);
        }
      }

      // Import trainings
      if (data['trainings'] != null) {
        for (final trainingJson in data['trainings']) {
          final training = Training.fromJson(trainingJson);
          await _trainingsBox.put(training.id, training);
        }
      }

      // Import attendance
      if (data['attendance'] != null) {
        for (final attendanceJson in data['attendance']) {
          final attendance = Attendance.fromJson(attendanceJson);
          await _attendanceBox.put(attendance.id, attendance);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          await _settingsBox.put(entry.key, entry.value);
        }
      }
    } catch (e) {
      print('Error importing data: $e');
      rethrow;
    }
  }

  // Statistics helpers
  Map<String, int> getMatchStatistics() {
    final matches = getCompletedMatches();
    int wins = 0;
    int draws = 0;
    int losses = 0;

    for (final match in matches) {
      switch (match.result?.toLowerCase()) {
        case 'vittoria':
          wins++;
          break;
        case 'pareggio':
          draws++;
          break;
        case 'sconfitta':
          losses++;
          break;
      }
    }

    return {
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'total': matches.length,
    };
  }

  double getTeamAttendancePercentage() {
    final allAttendance = getAllAttendance();
    if (allAttendance.isEmpty) return 0.0;

    final presentCount = allAttendance
        .where((a) => a.status.toLowerCase() == 'presente')
        .length;

    return (presentCount / allAttendance.length) * 100;
  }

  // Close database
  Future<void> closeDatabase() async {
    await _playersBox.close();
    await _staffBox.close();
    await _matchesBox.close();
    await _trainingsBox.close();
    await _attendanceBox.close();
    await _settingsBox.close();
  }
}
