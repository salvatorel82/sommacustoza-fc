import 'package:flutter/material.dart';
import '../../data/models/player.dart';
import '../../data/models/staff.dart';
import '../../data/models/attendance.dart';
import '../../data/services/database_service.dart';
import '../../core/utils/app_utils.dart';

class TeamProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Player> _players = [];
  List<Staff> _staff = [];
  List<Attendance> _attendance = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filters and search
  String _searchQuery = '';
  String? _selectedPosition;
  String? _selectedRole;
  bool _showActiveOnly = true;

  // Getters
  List<Player> get players => _filteredPlayers();
  List<Player> get filteredPlayers => _filteredPlayers();
  List<Staff> get staff => _filteredStaff();
  List<Staff> get filteredStaff => _filteredStaff();
  List<Attendance> get attendance => _attendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedPosition => _selectedPosition;
  String? get selectedRole => _selectedRole;
  bool get showActiveOnly => _showActiveOnly;

  // Statistics
  int get totalPlayers => _players.where((p) => p.isActive).length;
  int get totalStaff => _staff.where((s) => s.isActive).length;
  int get activePlayers => _players.where((p) => p.isActive).length;
  
  double get averageAge {
    final playersWithAge = _players.where((p) => p.isActive && p.age != null).toList();
    if (playersWithAge.isEmpty) return 0.0;
    final totalAge = playersWithAge.fold<int>(0, (sum, p) => sum + p.age!);
    return totalAge / playersWithAge.length;
  }
  
  Map<String, int> get playersByPosition {
    final result = <String, int>{};
    for (final player in _players.where((p) => p.isActive)) {
      result[player.position] = (result[player.position] ?? 0) + 1;
    }
    return result;
  }

  Map<String, int> get staffByRole {
    final result = <String, int>{};
    for (final staff in _staff.where((s) => s.isActive)) {
      result[staff.role] = (result[staff.role] ?? 0) + 1;
    }
    return result;
  }

  // Initialize
  Future<void> initialize() async {
    await loadPlayers();
    await loadStaff();
    await loadAttendance();
  }

  // Players management
  Future<void> loadPlayers() async {
    try {
      _setLoading(true);
      _players = _databaseService.getAllPlayers();
      print('Caricati ${_players.length} giocatori dal database'); // Debug
      notifyListeners();
    } catch (e) {
      print('Errore caricamento giocatori: $e'); // Debug
      _setError('Errore nel caricamento dei giocatori: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPlayer(Player player) async {
    try {
      _setLoading(true);
      
      print('TeamProvider: Aggiungendo giocatore ${player.name}'); // Debug
      
      // Check if player number is already taken (only if number is assigned)
      if (player.number != null && _isPlayerNumberTaken(player.number!, player.id)) {
        throw Exception('Il numero ${player.number} è già assegnato');
      }
      
      await _databaseService.addPlayer(player);
      _players.add(player);
      print('TeamProvider: Giocatore aggiunto. Lista aggiornata con ${_players.length} giocatori'); // Debug
      notifyListeners();
    } catch (e) {
      print('TeamProvider: Errore aggiunta giocatore: $e'); // Debug
      _setError('Errore nell\'aggiunta del giocatore: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePlayer(Player player) async {
    try {
      _setLoading(true);
      
      // Check if player number is already taken (only if number is assigned)
      if (player.number != null && _isPlayerNumberTaken(player.number!, player.id)) {
        throw Exception('Il numero ${player.number} è già assegnato');
      }
      
      await _databaseService.updatePlayer(player);
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index != -1) {
        _players[index] = player;
      }
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento del giocatore: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removePlayer(String playerId) async {
    try {
      _setLoading(true);
      await _databaseService.deletePlayer(playerId);
      _players.removeWhere((p) => p.id == playerId);
      
      // Also remove related attendance records
      _attendance.removeWhere((a) => a.playerId == playerId);
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nella rimozione del giocatore: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> togglePlayerStatus(String playerId) async {
    try {
      final player = _players.firstWhere((p) => p.id == playerId);
      final updatedPlayer = player.copyWith(
        isActive: !player.isActive,
        updatedAt: DateTime.now(),
      );
      await updatePlayer(updatedPlayer);
    } catch (e) {
      _setError('Errore nel cambio stato del giocatore: $e');
    }
  }

  // Staff management
  Future<void> loadStaff() async {
    try {
      _setLoading(true);
      _staff = _databaseService.getAllStaff();
      print('Caricati ${_staff.length} membri dello staff dal database'); // Debug
      notifyListeners();
    } catch (e) {
      print('Errore caricamento staff: $e'); // Debug
      _setError('Errore nel caricamento dello staff: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addStaff(Staff staff) async {
    try {
      _setLoading(true);
      await _databaseService.addStaff(staff);
      _staff.add(staff);
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiunta del membro staff: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStaff(Staff staff) async {
    try {
      _setLoading(true);
      await _databaseService.updateStaff(staff);
      final index = _staff.indexWhere((s) => s.id == staff.id);
      if (index != -1) {
        _staff[index] = staff;
      }
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento del membro staff: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeStaff(String staffId) async {
    try {
      _setLoading(true);
      await _databaseService.deleteStaff(staffId);
      _staff.removeWhere((s) => s.id == staffId);
      notifyListeners();
    } catch (e) {
      _setError('Errore nella rimozione del membro staff: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Attendance management
  Future<void> loadAttendance() async {
    try {
      _setLoading(true);
      _attendance = _databaseService.getAllAttendance();
      print('TeamProvider: Caricate ${_attendance.length} presenze dal database'); // Debug
      for (final attendance in _attendance) {
        print('  - Player: ${attendance.playerId}, Status: ${attendance.status}, Event: ${attendance.eventId}'); // Debug
      }
      notifyListeners();
    } catch (e) {
      print('TeamProvider: Errore caricamento presenze: $e'); // Debug
      _setError('Errore nel caricamento delle presenze: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> recordAttendance(Attendance attendance) async {
    try {
      _setLoading(true);
      print('TeamProvider: Salvando presenza - PlayerId: ${attendance.playerId}, Status: ${attendance.status}, EventId: ${attendance.eventId}'); // Debug
      await _databaseService.addAttendance(attendance);
      _attendance.add(attendance);
      print('TeamProvider: Presenza salvata. Lista aggiornata con ${_attendance.length} presenze'); // Debug
      notifyListeners();
    } catch (e) {
      print('TeamProvider: Errore nel salvataggio presenza: $e'); // Debug
      _setError('Errore nella registrazione delle presenze: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAttendance(Attendance attendance) async {
    try {
      _setLoading(true);
      await _databaseService.updateAttendance(attendance);
      final index = _attendance.indexWhere((a) => a.id == attendance.id);
      if (index != -1) {
        _attendance[index] = attendance;
      }
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento delle presenze: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeAttendanceRecord(String attendanceId) async {
    try {
      _setLoading(true);
      await _databaseService.deleteAttendance(attendanceId);
      _attendance.removeWhere((a) => a.id == attendanceId);
      print('Presenza rimossa dal provider: $attendanceId. Rimanenti: ${_attendance.length}'); // Debug
      notifyListeners();
    } catch (e) {
      _setError('Errore nella rimozione delle presenze: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPositionFilter(String? position) {
    _selectedPosition = position;
    notifyListeners();
  }

  void setRoleFilter(String? role) {
    _selectedRole = role;
    notifyListeners();
  }

  void toggleShowActiveOnly() {
    _showActiveOnly = !_showActiveOnly;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedPosition = null;
    _selectedRole = null;
    _showActiveOnly = true;
    notifyListeners();
  }

  // Statistics methods
  AttendanceStats getPlayerAttendanceStats(String playerId) {
    final playerAttendance = _attendance.where((a) => a.playerId == playerId).toList();
    return AttendanceStats.fromAttendanceList(playerId, playerAttendance);
  }

  Map<String, AttendanceStats> getAllPlayerAttendanceStats() {
    final stats = <String, AttendanceStats>{};
    for (final player in _players.where((p) => p.isActive)) {
      stats[player.id] = getPlayerAttendanceStats(player.id);
    }
    return stats;
  }

  double getTeamAttendancePercentage() {
    if (_attendance.isEmpty) return 0.0;
    final presentCount = _attendance
        .where((a) => a.status.toLowerCase() == 'presente')
        .length;
    return (presentCount / _attendance.length) * 100;
  }

  List<Player> getTopAttendancePlayers({int limit = 5}) {
    final stats = getAllPlayerAttendanceStats();
    final sortedPlayers = _players.where((p) => p.isActive).toList();
    
    sortedPlayers.sort((a, b) {
      final aStats = stats[a.id];
      final bStats = stats[b.id];
      if (aStats == null && bStats == null) return 0;
      if (aStats == null) return 1;
      if (bStats == null) return -1;
      return bStats.attendancePercentage.compareTo(aStats.attendancePercentage);
    });
    
    return sortedPlayers.take(limit).toList();
  }

  // Helper methods
  List<Player> _filteredPlayers() {
    var filtered = _showActiveOnly 
        ? _players.where((p) => p.isActive).toList()
        : _players;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.number?.toString().contains(_searchQuery) ?? false) ||
          p.position.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedPosition != null) {
      filtered = filtered.where((p) => p.position == _selectedPosition).toList();
    }

    return filtered..sort((a, b) {
      // Sort by number, but put players without numbers at the end
      if (a.number == null && b.number == null) return a.name.compareTo(b.name);
      if (a.number == null) return 1;
      if (b.number == null) return -1;
      return a.number!.compareTo(b.number!);
    });
  }

  List<Staff> _filteredStaff() {
    var filtered = _showActiveOnly 
        ? _staff.where((s) => s.isActive).toList()
        : _staff;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) => 
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.role.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedRole != null) {
      filtered = filtered.where((s) => s.role == _selectedRole).toList();
    }

    return filtered..sort((a, b) => a.name.compareTo(b.name));
  }

  bool _isPlayerNumberTaken(int number, String excludePlayerId) {
    return _players.any((p) => 
        p.number == number && 
        p.id != excludePlayerId && 
        p.isActive
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Player utility methods
  Player? getPlayerById(String playerId) {
    try {
      return _players.firstWhere((p) => p.id == playerId);
    } catch (e) {
      return null;
    }
  }

  Staff? getStaffById(String staffId) {
    try {
      return _staff.firstWhere((s) => s.id == staffId);
    } catch (e) {
      return null;
    }
  }

  List<int> getAvailablePlayerNumbers() {
    final takenNumbers = _players
        .where((p) => p.isActive && p.number != null)
        .map((p) => p.number!)
        .toSet();
    
    final availableNumbers = <int>[];
    for (int i = 1; i <= 99; i++) {
      if (!takenNumbers.contains(i)) {
        availableNumbers.add(i);
      }
    }
    return availableNumbers;
  }

  int getNextAvailablePlayerNumber() {
    final availableNumbers = getAvailablePlayerNumbers();
    return availableNumbers.isNotEmpty ? availableNumbers.first : 1;
  }
}
