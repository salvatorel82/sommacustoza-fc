import 'package:flutter/material.dart';
import '../../data/models/match.dart';
import '../../data/models/player.dart';
import '../../data/services/database_service.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';

class MatchProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Match> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filters
  String? _selectedCompetition;
  String? _selectedResult;
  bool _showUpcomingOnly = false;
  bool _showHomeOnly = false;
  bool _showAwayOnly = false;

  // Getters
  List<Match> get matches => _filteredMatches();
  List<Match> get upcomingMatches => _getUpcomingMatches();
  List<Match> get completedMatches => _getCompletedMatches();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCompetition => _selectedCompetition;
  String? get selectedResult => _selectedResult;
  bool get showUpcomingOnly => _showUpcomingOnly;
  bool get showHomeOnly => _showHomeOnly;
  bool get showAwayOnly => _showAwayOnly;

  // Statistics
  int get totalMatches => _matches.length;
  int get completedMatchesCount => _getCompletedMatches().length;
  int get upcomingMatchesCount => _getUpcomingMatches().length;
  
  Map<String, int> get matchStatistics {
    final completed = _getCompletedMatches();
    int wins = 0;
    int draws = 0;
    int losses = 0;
    
    for (final match in completed) {
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
      'total': completed.length,
    };
  }

  Map<String, int> get homeAwayStats {
    final completed = _getCompletedMatches();
    int homeWins = 0;
    int awayWins = 0;
    int homeDraws = 0;
    int awayDraws = 0;
    int homeLosses = 0;
    int awayLosses = 0;
    
    for (final match in completed) {
      final result = match.result?.toLowerCase();
      if (match.isHome) {
        switch (result) {
          case 'vittoria':
            homeWins++;
            break;
          case 'pareggio':
            homeDraws++;
            break;
          case 'sconfitta':
            homeLosses++;
            break;
        }
      } else {
        switch (result) {
          case 'vittoria':
            awayWins++;
            break;
          case 'pareggio':
            awayDraws++;
            break;
          case 'sconfitta':
            awayLosses++;
            break;
        }
      }
    }
    
    return {
      'homeWins': homeWins,
      'homeDraws': homeDraws,
      'homeLosses': homeLosses,
      'awayWins': awayWins,
      'awayDraws': awayDraws,
      'awayLosses': awayLosses,
    };
  }

  int get goalsScored {
    return _getCompletedMatches()
        .where((m) => m.goalsFor != null)
        .fold<int>(0, (sum, m) => sum + m.goalsFor!);
  }

  int get goalsConceded {
    return _getCompletedMatches()
        .where((m) => m.goalsAgainst != null)
        .fold<int>(0, (sum, m) => sum + m.goalsAgainst!);
  }

  double get averageGoalsScored {
    final completed = _getCompletedMatches().where((m) => m.goalsFor != null);
    if (completed.isEmpty) return 0.0;
    return goalsScored / completed.length;
  }

  double get averageGoalsConceded {
    final completed = _getCompletedMatches().where((m) => m.goalsAgainst != null);
    if (completed.isEmpty) return 0.0;
    return goalsConceded / completed.length;
  }

  // Initialize
  Future<void> initialize() async {
    await loadMatches();
  }

  // Match management
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

  Future<void> addMatch(Match match) async {
    try {
      _setLoading(true);
      await _databaseService.addMatch(match);
      _matches.add(match);
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiunta della partita: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMatch(Match match) async {
    try {
      _setLoading(true);
      await _databaseService.updateMatch(match);
      final index = _matches.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        _matches[index] = match;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento della partita: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeMatch(String matchId) async {
    try {
      _setLoading(true);
      await _databaseService.deleteMatch(matchId);
      _matches.removeWhere((m) => m.id == matchId);
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nella rimozione della partita: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Match result management
  Future<void> updateMatchResult({
    required String matchId,
    required String result,
    required int goalsFor,
    required int goalsAgainst,
    String? notes,
  }) async {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      final updatedMatch = match.copyWith(
        result: result,
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
        notes: notes,
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      
      await updateMatch(updatedMatch);
      
    } catch (e) {
      _setError('Errore nell\'aggiornamento del risultato: $e');
      rethrow;
    }
  }

  // Match events management
  Future<void> addMatchEvent(String matchId, MatchEvent event) async {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      final events = List<MatchEvent>.from(match.events ?? []);
      events.add(event);
      
      final updatedMatch = match.copyWith(
        events: events,
        updatedAt: DateTime.now(),
      );
      
      await updateMatch(updatedMatch);
    } catch (e) {
      _setError('Errore nell\'aggiunta dell\'evento: $e');
      rethrow;
    }
  }

  Future<void> removeMatchEvent(String matchId, String eventId) async {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      final events = List<MatchEvent>.from(match.events ?? []);
      events.removeWhere((e) => e.id == eventId);
      
      final updatedMatch = match.copyWith(
        events: events,
        updatedAt: DateTime.now(),
      );
      
      await updateMatch(updatedMatch);
    } catch (e) {
      _setError('Errore nella rimozione dell\'evento: $e');
      rethrow;
    }
  }

  // Lineup management
  Future<void> updateMatchLineup(String matchId, List<String> lineup, List<String> substitutes) async {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      final updatedMatch = match.copyWith(
        lineup: lineup,
        substitutes: substitutes,
        updatedAt: DateTime.now(),
      );
      
      await updateMatch(updatedMatch);
    } catch (e) {
      _setError('Errore nell\'aggiornamento della formazione: $e');
      rethrow;
    }
  }

  // Player ratings
  Future<void> updatePlayerRatings(String matchId, Map<String, double> ratings) async {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      final updatedMatch = match.copyWith(
        playerRatings: ratings,
        updatedAt: DateTime.now(),
      );
      
      await updateMatch(updatedMatch);
    } catch (e) {
      _setError('Errore nell\'aggiornamento delle valutazioni: $e');
      rethrow;
    }
  }

  // Filters
  void setCompetitionFilter(String? competition) {
    _selectedCompetition = competition;
    notifyListeners();
  }

  void setResultFilter(String? result) {
    _selectedResult = result;
    notifyListeners();
  }

  void toggleShowUpcomingOnly() {
    _showUpcomingOnly = !_showUpcomingOnly;
    if (_showUpcomingOnly) {
      _showHomeOnly = false;
      _showAwayOnly = false;
    }
    notifyListeners();
  }

  void toggleShowHomeOnly() {
    _showHomeOnly = !_showHomeOnly;
    if (_showHomeOnly) {
      _showAwayOnly = false;
      _showUpcomingOnly = false;
    }
    notifyListeners();
  }

  void toggleShowAwayOnly() {
    _showAwayOnly = !_showAwayOnly;
    if (_showAwayOnly) {
      _showHomeOnly = false;
      _showUpcomingOnly = false;
    }
    notifyListeners();
  }

  void clearFilters() {
    _selectedCompetition = null;
    _selectedResult = null;
    _showUpcomingOnly = false;
    _showHomeOnly = false;
    _showAwayOnly = false;
    notifyListeners();
  }

  // Analytics
  Map<String, dynamic> getMatchAnalytics() {
    final stats = matchStatistics;
    final homeAway = homeAwayStats;
    
    double winPercentage = 0.0;
    if (stats['total']! > 0) {
      winPercentage = (stats['wins']! / stats['total']!) * 100;
    }

    return {
      'matchStatistics': stats,
      'homeAwayStats': homeAway,
      'goalsScored': goalsScored,
      'goalsConceded': goalsConceded,
      'averageGoalsScored': averageGoalsScored,
      'averageGoalsConceded': averageGoalsConceded,
      'winPercentage': winPercentage,
      'goalDifference': goalsScored - goalsConceded,
    };
  }

  List<Match> getRecentMatches({int limit = 5}) {
    return _getCompletedMatches().take(limit).toList();
  }

  List<Match> getNextMatches({int limit = 5}) {
    return _getUpcomingMatches().take(limit).toList();
  }

  // Opponent analysis
  Map<String, dynamic> getOpponentStats(String opponent) {
    final opponentMatches = _getCompletedMatches()
        .where((m) => m.opponent.toLowerCase() == opponent.toLowerCase())
        .toList();
    
    if (opponentMatches.isEmpty) {
      return {
        'totalMatches': 0,
        'wins': 0,
        'draws': 0,
        'losses': 0,
        'goalsFor': 0,
        'goalsAgainst': 0,
      };
    }

    int wins = 0;
    int draws = 0;
    int losses = 0;
    int goalsFor = 0;
    int goalsAgainst = 0;

    for (final match in opponentMatches) {
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
      
      if (match.goalsFor != null) goalsFor += match.goalsFor!;
      if (match.goalsAgainst != null) goalsAgainst += match.goalsAgainst!;
    }

    return {
      'totalMatches': opponentMatches.length,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'lastMatch': opponentMatches.first,
    };
  }

  // Quick actions
  Future<void> createQuickMatch({
    required String opponent,
    required DateTime dateTime,
    required String location,
    required bool isHome,
    String competitionType = 'Campionato',
  }) async {
    final match = Match(
      id: AppUtils.generateId(),
      opponent: opponent,
      dateTime: dateTime,
      location: location,
      isHome: isHome,
      competitionType: competitionType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await addMatch(match);
  }

  Future<void> rescheduleMatch(String matchId, DateTime newDateTime) async {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      final updatedMatch = match.copyWith(
        dateTime: newDateTime,
        updatedAt: DateTime.now(),
      );
      await updateMatch(updatedMatch);
    } catch (e) {
      _setError('Errore nel riprogrammare la partita: $e');
    }
  }

  // Helper methods
  List<Match> _filteredMatches() {
    var filtered = _matches.toList();

    if (_selectedCompetition != null) {
      filtered = filtered.where((m) => 
          m.competitionType == _selectedCompetition).toList();
    }

    if (_selectedResult != null) {
      filtered = filtered.where((m) => 
          m.result == _selectedResult).toList();
    }

    if (_showUpcomingOnly) {
      final now = DateTime.now();
      filtered = filtered.where((m) => 
          m.dateTime.isAfter(now) && !m.isCompleted).toList();
    }

    if (_showHomeOnly) {
      filtered = filtered.where((m) => m.isHome).toList();
    }

    if (_showAwayOnly) {
      filtered = filtered.where((m) => !m.isHome).toList();
    }

    return filtered..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<Match> _getUpcomingMatches() {
    final now = DateTime.now();
    return _matches
        .where((m) => m.dateTime.isAfter(now) && !m.isCompleted)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Match> _getCompletedMatches() {
    return _matches
        .where((m) => m.isCompleted)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
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

  // Utility methods
  Match? getMatchById(String matchId) {
    try {
      return _matches.firstWhere((m) => m.id == matchId);
    } catch (e) {
      return null;
    }
  }

  List<String> getAllOpponents() {
    return _matches.map((m) => m.opponent).toSet().toList()..sort();
  }

  List<String> getAllCompetitions() {
    return _matches
        .where((m) => m.competitionType != null)
        .map((m) => m.competitionType!)
        .toSet()
        .toList()..sort();
  }

  Match? getNextMatch() {
    final upcoming = _getUpcomingMatches();
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  Match? getLastMatch() {
    final completed = _getCompletedMatches();
    return completed.isNotEmpty ? completed.first : null;
  }
}
