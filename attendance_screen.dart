import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance.dart';
import '../../../data/models/training.dart';
import '../../../data/models/match.dart';
import '../../../data/models/player.dart';
import '../../providers/team_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/common/custom_cards.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';
import 'event_attendance_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Tutti';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildQuickStats(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsTab(),
                _buildStatisticsTab(),
                _buildPlayersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Presenze',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
            Consumer<TeamProvider>(
              builder: (context, teamProvider, child) {
                return Text(
                  '${teamProvider.totalPlayers} giocatori attivi',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Consumer2<TeamProvider, CalendarProvider>(
        builder: (context, teamProvider, calendarProvider, child) {
          // Calcolo statistiche reali delle presenze
          final attendancePercentage = teamProvider.getTeamAttendancePercentage();
          final totalEvents = teamProvider.attendance
              .map((a) => a.eventId)
              .toSet()
              .length;
          final totalAttendances = teamProvider.attendance.length;
          final avgAttendance = totalEvents > 0 ? (totalAttendances / totalEvents).round() : 0;
          
          return Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Presenza',
                  value: '${attendancePercentage.toStringAsFixed(0)}%',
                  subtitle: 'Media',
                  icon: Icons.how_to_reg,
                  iconColor: attendancePercentage >= 80 
                      ? AppTheme.successColor 
                      : attendancePercentage >= 60 
                          ? AppTheme.warningColor 
                          : AppTheme.errorColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Eventi',
                  value: totalEvents.toString(),
                  subtitle: 'Totali',
                  icon: Icons.event,
                  iconColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Media',
                  value: avgAttendance.toString(),
                  subtitle: 'Partecip.',
                  icon: Icons.people,
                  iconColor: AppTheme.accentColor,
                ),
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: const [
          Tab(text: 'Eventi'),
          Tab(text: 'Statistiche'),
          Tab(text: 'Giocatori'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildEventsTab() {
    return Consumer2<CalendarProvider, MatchProvider>(
      builder: (context, calendarProvider, matchProvider, child) {
        final events = [
          ...calendarProvider.trainings,
          ...matchProvider.matches,
        ];
        
        events.sort((a, b) => _getEventDateTime(b).compareTo(_getEventDateTime(a)));
        
        if (events.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event);
          },
        );
      },
    );
  }

  Widget _buildEventCard(dynamic event) {
    final isTraining = event is Training;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final eventDateTime = _getEventDateTime(event);
    final isPast = eventDateTime.isBefore(DateTime.now());
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _navigateToEventAttendance(event),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isTraining ? AppTheme.accentColor : AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTraining ? Icons.fitness_center : Icons.sports_soccer,
              color: isTraining ? AppTheme.accentColor : AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTraining ? 'Allenamento ${event.type}' : 'Vs ${event.opponent}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPast ? Colors.grey.shade600 : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(eventDateTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            children: [
              if (isPast)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Completato',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Prossimo',
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final players = teamProvider.players;
        
        if (players.isEmpty) {
          return _buildEmptyState('Nessun giocatore trovato');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return _buildPlayerStatsCard(player);
          },
        );
      },
    );
  }

  Widget _buildPlayerStatsCard(Player player) {
    // Statistiche reali delle presenze per ogni giocatore
    final playerStats = context.read<TeamProvider>().getPlayerAttendanceStats(player.id);
    final attendanceRate = playerStats.attendancePercentage;
    final eventsAttended = playerStats.presentCount;
    final totalEvents = playerStats.totalEvents;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _getInitials(player.name),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  player.position,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$eventsAttended/$totalEvents eventi',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: attendanceRate >= 80 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : attendanceRate >= 60 
                          ? AppTheme.warningColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${attendanceRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: attendanceRate >= 80 
                        ? AppTheme.successColor
                        : attendanceRate >= 60 
                            ? AppTheme.warningColor
                            : AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final players = teamProvider.players;
        
        if (players.isEmpty) {
          return _buildEmptyState('Nessun giocatore trovato');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return _buildPlayerAttendanceCard(player);
          },
        );
      },
    );
  }

  Widget _buildPlayerAttendanceCard(Player player) {
    final recentAttendance = ['P', 'P', 'A', 'P', 'G']; // P=Presente, A=Assente, G=Giustificato
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _getInitials(player.name),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  player.position,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Ultimi eventi: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    ...recentAttendance.map((status) {
                      Color color;
                      switch (status) {
                        case 'P':
                          color = AppTheme.successColor;
                          break;
                        case 'A':
                          color = AppTheme.errorColor;
                          break;
                        case 'G':
                          color = AppTheme.warningColor;
                          break;
                        default:
                          color = Colors.grey;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            status,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onPressed: () => _showPlayerOptions(player),
          ),
        ],
      ),
    );
  }

  void _navigateToEventAttendance(dynamic event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventAttendanceScreen(event: event),
      ),
    );
  }

  void _showPlayerOptions(Player player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Statistiche Dettagliate'),
              onTap: () {
                Navigator.pop(context);
                _showDetailedStats(player);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica Presenze'),
              onTap: () {
                Navigator.pop(context);
                _showEditAttendance(player);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Aggiungi Nota'),
              onTap: () {
                Navigator.pop(context);
                _showAddNote(player);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  DateTime _getEventDateTime(dynamic event) {
    if (event is Training) {
      return event.dateTime;
    } else if (event is Match) {
      return event.dateTime;
    }
    throw ArgumentError('Unknown event type: ${event.runtimeType}');
  }

  Widget _buildEmptyState([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_reg_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Nessun Evento',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gli eventi con le presenze appariranno qui',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDetailedStats(Player player) {
    final playerStats = context.read<TeamProvider>().getPlayerAttendanceStats(player.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statistiche di ${player.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Eventi totali: ${playerStats.totalEvents}'),
              const SizedBox(height: 8),
              Text('Presenze: ${playerStats.presentCount}'),
              const SizedBox(height: 8),
              Text('Assenze: ${playerStats.absentCount}'),
              const SizedBox(height: 8),
              Text('Giustificati: ${playerStats.excusedCount}'),
              const SizedBox(height: 8),
              Text('Percentuale presenze: ${playerStats.attendancePercentage.toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              Text('Allenamenti: ${playerStats.trainingEvents}'),
              const SizedBox(height: 8),
              Text('Presenze allenamenti: ${playerStats.trainingPresent}'),
              const SizedBox(height: 8),
              Text('Percentuale allenamenti: ${playerStats.trainingAttendancePercentage.toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              Text('Partite: ${playerStats.matchEvents}'),
              const SizedBox(height: 8),
              Text('Presenze partite: ${playerStats.matchPresent}'),
              const SizedBox(height: 8),
              Text('Percentuale partite: ${playerStats.matchAttendancePercentage.toStringAsFixed(1)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showEditAttendance(Player player) {
    final playerAttendances = context.read<TeamProvider>().attendance
        .where((a) => a.playerId == player.id)
        .toList();
    
    if (playerAttendances.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Presenze di ${player.name}'),
          content: const Text('Nessuna presenza registrata per questo giocatore.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifica Presenze - ${player.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${playerAttendances.length} presenze registrate:', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...playerAttendances.map((attendance) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        'Evento: ${attendance.eventId.substring(0, 8)}...',
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data: ${attendance.eventDate.day}/${attendance.eventDate.month}/${attendance.eventDate.year}'),
                          Text('Tipo: ${attendance.eventType}'),
                          if (attendance.notes?.isNotEmpty == true)
                            Text('Note: ${attendance.notes}'),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(attendance.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(attendance.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          attendance.status,
                          style: TextStyle(
                            color: _getStatusColor(attendance.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () => _showEditSingleAttendance(attendance, player),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showAddNote(Player player) {
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aggiungi Nota - ${player.name}'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Inserisci una nota...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.trim().isNotEmpty) {
                // In una vera app, qui salveresti la nota
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota aggiunta (simulazione)')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _showEditSingleAttendance(Attendance attendance, Player player) {
    String newStatus = attendance.status;
    final noteController = TextEditingController(text: attendance.notes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Modifica Presenza - ${player.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Evento del ${attendance.eventDate.day}/${attendance.eventDate.month}/${attendance.eventDate.year}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: newStatus,
                decoration: const InputDecoration(labelText: 'Stato'),
                items: const [
                  DropdownMenuItem(value: 'presente', child: Text('Presente')),
                  DropdownMenuItem(value: 'assente', child: Text('Assente')),
                  DropdownMenuItem(value: 'giustificato', child: Text('Giustificato')),
                  DropdownMenuItem(value: 'infortunato', child: Text('Infortunato')),
                ],
                onChanged: (value) => setState(() => newStatus = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Aggiungi note opzionali...',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedAttendance = attendance.copyWith(
                    status: newStatus,
                    notes: noteController.text.trim().isNotEmpty 
                        ? noteController.text.trim() 
                        : null,
                    updatedAt: DateTime.now(),
                  );
                  
                  await context.read<TeamProvider>().updateAttendance(updatedAttendance);
                  Navigator.pop(context); // Chiudi il dialog di modifica singola
                  Navigator.pop(context); // Chiudi il dialog della lista
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Presenza aggiornata con successo')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: $e')),
                  );
                }
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'presente':
        return Colors.green;
      case 'assente':
        return Colors.red;
      case 'giustificato':
        return Colors.orange;
      case 'infortunato':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
