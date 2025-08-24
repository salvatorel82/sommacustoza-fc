import 'package:flutter/material.dart';
import '../../data/models/training.dart';
import '../../data/models/match.dart';
import '../../data/services/database_service.dart';
import '../../core/utils/app_utils.dart';

class CalendarProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Training> _trainings = [];
  List<Match> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Calendar state
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  
  // Filters
  List<String> _selectedTrainingTypes = [];
  bool _showCompletedEvents = true;
  bool _showUpcomingOnly = false;

  // Getters
  List<Training> get trainings => _filteredTrainings();
  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  List<String> get selectedTrainingTypes => _selectedTrainingTypes;
  bool get showCompletedEvents => _showCompletedEvents;
  bool get showUpcomingOnly => _showUpcomingOnly;

  // Statistics
  int get totalTrainings => _trainings.length;
  int get completedTrainings => _trainings.where((t) => t.isCompleted).length;
  int get upcomingTrainings => _trainings.where((t) => 
      t.dateTime.isAfter(DateTime.now()) && !t.isCompleted).length;

  Map<String, int> get trainingsByType {
    final result = <String, int>{};
    for (final training in _trainings) {
      result[training.type] = (result[training.type] ?? 0) + 1;
    }
    return result;
  }

  // Initialize
  Future<void> initialize() async {
    await loadTrainings();
    await loadMatches();
  }

  // Calendar management
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  // Get events for a specific date
  List<dynamic> getEventsForDate(DateTime date) {
    final events = <dynamic>[];
    
    // Add trainings
    events.addAll(_trainings.where((training) => 
        training.dateTime.year == date.year &&
        training.dateTime.month == date.month &&
        training.dateTime.day == date.day
    ));
    
    // Add matches
    events.addAll(_matches.where((match) => 
        match.dateTime.year == date.year &&
        match.dateTime.month == date.month &&
        match.dateTime.day == date.day
    ));
    
    // Sort by time
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return events;
  }

  // Get upcoming events
  List<dynamic> getUpcomingEvents({int limit = 5}) {
    final now = DateTime.now();
    final events = <dynamic>[];
    
    // Add upcoming trainings
    events.addAll(_trainings.where((t) => 
        t.dateTime.isAfter(now) && !t.isCompleted));
    
    // Add upcoming matches
    events.addAll(_matches.where((m) => 
        m.dateTime.isAfter(now) && !m.isCompleted));
    
    // Sort by date and take limit
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return events.take(limit).toList();
  }

  // Training management
  Future<void> loadTrainings() async {
    try {
      _setLoading(true);
      _trainings = _databaseService.getAllTrainings();
      print('Caricati ${_trainings.length} allenamenti dal database'); // Debug
      notifyListeners();
    } catch (e) {
      print('Errore caricamento allenamenti: $e'); // Debug
      _setError('Errore nel caricamento degli allenamenti: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTraining(Training training) async {
    try {
      _setLoading(true);
      print('Salvando allenamento: ${training.type} del ${training.dateTime}'); // Debug
      await _databaseService.addTraining(training);
      _trainings.add(training);
      print('Allenamento salvato con successo. Totale allenamenti: ${_trainings.length}'); // Debug
      
      notifyListeners();
    } catch (e) {
      print('Errore salvataggio allenamento: $e'); // Debug
      _setError('Errore nell\'aggiunta dell\'allenamento: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTraining(Training training) async {
    try {
      _setLoading(true);
      await _databaseService.updateTraining(training);
      final index = _trainings.indexWhere((t) => t.id == training.id);
      if (index != -1) {
        _trainings[index] = training;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento dell\'allenamento: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeTraining(String trainingId) async {
    try {
      _setLoading(true);
      await _databaseService.deleteTraining(trainingId);
      _trainings.removeWhere((t) => t.id == trainingId);
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nella rimozione dell\'allenamento: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTrainingCompletion(String trainingId) async {
    try {
      final training = _trainings.firstWhere((t) => t.id == trainingId);
      final updatedTraining = training.copyWith(
        isCompleted: !training.isCompleted,
        updatedAt: DateTime.now(),
      );
      await updateTraining(updatedTraining);
    } catch (e) {
      _setError('Errore nel cambio stato dell\'allenamento: $e');
    }
  }

  // Match management (for calendar integration)
  Future<void> loadMatches() async {
    try {
      _setLoading(true);
      _matches = _databaseService.getAllMatches();
      notifyListeners();
    } catch (e) {
      _setError('Errore nel caricamento delle partite: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filters
  void toggleTrainingTypeFilter(String type) {
    if (_selectedTrainingTypes.contains(type)) {
      _selectedTrainingTypes.remove(type);
    } else {
      _selectedTrainingTypes.add(type);
    }
    notifyListeners();
  }

  void clearTrainingTypeFilters() {
    _selectedTrainingTypes.clear();
    notifyListeners();
  }

  void toggleShowCompletedEvents() {
    _showCompletedEvents = !_showCompletedEvents;
    notifyListeners();
  }

  void toggleShowUpcomingOnly() {
    _showUpcomingOnly = !_showUpcomingOnly;
    notifyListeners();
  }

  void clearFilters() {
    _selectedTrainingTypes.clear();
    _showCompletedEvents = true;
    _showUpcomingOnly = false;
    notifyListeners();
  }

  // Training statistics
  Map<String, dynamic> getTrainingStatistics() {
    final totalMinutes = _trainings
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.durationMinutes);
    
    final avgIntensity = _trainings
        .where((t) => t.intensity != null)
        .map((t) => t.intensity!)
        .fold<double>(0, (sum, intensity) => sum + intensity) / 
        _trainings.where((t) => t.intensity != null).length;

    final completionRate = totalTrainings > 0 
        ? (completedTrainings / totalTrainings) * 100 
        : 0.0;

    return {
      'totalTrainings': totalTrainings,
      'completedTrainings': completedTrainings,
      'upcomingTrainings': upcomingTrainings,
      'totalMinutes': totalMinutes,
      'totalHours': (totalMinutes / 60).toStringAsFixed(1),
      'averageIntensity': avgIntensity.isNaN ? 0.0 : avgIntensity,
      'completionRate': completionRate,
      'trainingsByType': trainingsByType,
    };
  }

  // Get trainings for a specific week
  List<Training> getTrainingsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _trainings.where((training) => 
        training.dateTime.isAfter(weekStart) &&
        training.dateTime.isBefore(weekEnd)
    ).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Get trainings for a specific month
  List<Training> getTrainingsForMonth(DateTime month) {
    return _trainings.where((training) => 
        training.dateTime.year == month.year &&
        training.dateTime.month == month.month
    ).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Quick actions
  Future<void> createQuickTraining({
    required String type,
    required DateTime dateTime,
    required String location,
    int durationMinutes = 90,
  }) async {
    final training = Training(
      id: AppUtils.generateId(),
      type: type,
      dateTime: dateTime,
      location: location,
      durationMinutes: durationMinutes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await addTraining(training);
  }

  Future<void> rescheduleTraining(String trainingId, DateTime newDateTime) async {
    try {
      final training = _trainings.firstWhere((t) => t.id == trainingId);
      final updatedTraining = training.copyWith(
        dateTime: newDateTime,
        updatedAt: DateTime.now(),
      );
      await updateTraining(updatedTraining);
    } catch (e) {
      _setError('Errore nel riprogrammare l\'allenamento: $e');
    }
  }

  // Helper methods
  List<Training> _filteredTrainings() {
    var filtered = _trainings.toList();

    if (_selectedTrainingTypes.isNotEmpty) {
      filtered = filtered.where((t) => 
          _selectedTrainingTypes.contains(t.type)).toList();
    }

    if (!_showCompletedEvents) {
      filtered = filtered.where((t) => !t.isCompleted).toList();
    }

    if (_showUpcomingOnly) {
      final now = DateTime.now();
      filtered = filtered.where((t) => 
          t.dateTime.isAfter(now)).toList();
    }

    return filtered..sort((a, b) => b.dateTime.compareTo(a.dateTime));
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

  // Calendar navigation helpers
  void goToToday() {
    final today = DateTime.now();
    setSelectedDate(today);
    setFocusedDate(today);
  }

  void goToNextMonth() {
    final nextMonth = DateTime(_focusedDate.year, _focusedDate.month + 1);
    setFocusedDate(nextMonth);
  }

  void goToPreviousMonth() {
    final previousMonth = DateTime(_focusedDate.year, _focusedDate.month - 1);
    setFocusedDate(previousMonth);
  }

  // Utility methods
  Training? getTrainingById(String trainingId) {
    try {
      return _trainings.firstWhere((t) => t.id == trainingId);
    } catch (e) {
      return null;
    }
  }

  bool hasEventsOnDate(DateTime date) {
    return getEventsForDate(date).isNotEmpty;
  }

  int getEventsCountForDate(DateTime date) {
    return getEventsForDate(date).length;
  }
}
