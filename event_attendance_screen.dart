import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance.dart';
import '../../../data/models/training.dart';
import '../../../data/models/match.dart';
import '../../../data/models/player.dart';
import '../../providers/team_provider.dart';
import '../../widgets/common/custom_cards.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';

class EventAttendanceScreen extends StatefulWidget {
  final dynamic event; // Training or Match

  const EventAttendanceScreen({super.key, required this.event});

  @override
  State<EventAttendanceScreen> createState() => _EventAttendanceScreenState();
}

class _EventAttendanceScreenState extends State<EventAttendanceScreen> {
  final Map<String, String> _attendanceStatus = {};
  final Map<String, bool> _isLate = {};
  final Map<String, int> _minutesLate = {};
  final Map<String, String> _notes = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingAttendance();
  }

  void _loadExistingAttendance() {
    final teamProvider = context.read<TeamProvider>();
    final eventAttendance = teamProvider.attendance
        .where((a) => a.eventId == widget.event.id)
        .toList();

    for (final attendance in eventAttendance) {
      _attendanceStatus[attendance.playerId] = attendance.status;
      _isLate[attendance.playerId] = attendance.isLate;
      _minutesLate[attendance.playerId] = attendance.minutesLate ?? 0;
      _notes[attendance.playerId] = attendance.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTraining = widget.event is Training;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isTraining 
              ? 'Presenze Allenamento' 
              : 'Presenze Partita',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildEventHeader(),
          _buildQuickActions(),
          Expanded(
            child: _buildPlayersList(),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildEventHeader() {
    final isTraining = widget.event is Training;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isTraining ? AppTheme.accentGradient : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTraining ? Icons.fitness_center : Icons.sports_soccer,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTraining 
                          ? 'Allenamento ${widget.event.type}'
                          : 'Partita vs ${widget.event.opponent}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event.location,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                '${widget.event.dateTime.day}/${widget.event.dateTime.month}/${widget.event.dateTime.year} • '
                '${widget.event.dateTime.hour.toString().padLeft(2, '0')}:${widget.event.dateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Presenti',
              onPressed: () => _setAllStatus('presente'),
              backgroundColor: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomButton(
              text: 'Assenti',
              onPressed: () => _setAllStatus('assente'),
              backgroundColor: AppTheme.errorColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomButton(
              text: 'Reset',
              onPressed: _resetAll,
              backgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPlayersList() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final players = teamProvider.players;
        
        if (players.isEmpty) {
          return const Center(
            child: Text('Nessun giocatore disponibile'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return _buildPlayerCard(player, index);
          },
        );
      },
    );
  }

  Widget _buildPlayerCard(Player player, int index) {
    final status = _attendanceStatus[player.id] ?? '';
    final isLate = _isLate[player.id] ?? false;
    final minutesLate = _minutesLate[player.id] ?? 0;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _getStatusColor(status).withOpacity(0.1),
                child: Text(
                  player.initials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            player.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (player.number != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#${player.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.position,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _getStatusEmoji(status),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusButtons(player.id),
          if (status == 'presente' && isLate) ...[
            const SizedBox(height: 12),
            _buildLateSection(player.id),
          ],
          if (status == 'giustificato' || status == 'assente') ...[
            const SizedBox(height: 12),
            _buildNotesSection(player.id),
          ],
        ],
      ),
    ).animate()
        .fadeIn(delay: (index * 50).ms)
        .slideX(begin: 0.3);
  }

  Widget _buildStatusButtons(String playerId) {
    final currentStatus = _attendanceStatus[playerId] ?? '';
    
    return Row(
      children: [
        Expanded(
          child: _buildStatusButton(
            playerId,
            'presente',
            '✅ Presente',
            AppTheme.successColor,
            currentStatus == 'presente',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusButton(
            playerId,
            'assente',
            '❌ Assente',
            AppTheme.errorColor,
            currentStatus == 'assente',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    String playerId,
    String status,
    String label,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _setPlayerStatus(playerId, status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLateSection(String playerId) {
    final minutesLate = _minutesLate[playerId] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isLate[playerId] ?? false,
              onChanged: (value) {
                setState(() {
                  _isLate[playerId] = value ?? false;
                  if (!(_isLate[playerId] ?? false)) {
                    _minutesLate[playerId] = 0;
                  }
                });
              },
            ),
            const Text('In ritardo'),
          ],
        ),
        if (_isLate[playerId] ?? false) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Minuti di ritardo: '),
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  onChanged: (value) {
                    _minutesLate[playerId] = int.tryParse(value) ?? 0;
                  },
                  controller: TextEditingController(text: minutesLate.toString()),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection(String playerId) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Note o motivo...',
        isDense: true,
        contentPadding: EdgeInsets.all(12),
      ),
      maxLines: 2,
      onChanged: (value) {
        _notes[playerId] = value;
      },
      controller: TextEditingController(text: _notes[playerId] ?? ''),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: 'Salva Presenze',
          onPressed: _isLoading ? null : _saveAttendance,
          isLoading: _isLoading,
        ),
      ),
    );
  }

  // Helper methods
  void _setPlayerStatus(String playerId, String status) {
    setState(() {
      _attendanceStatus[playerId] = status;
      if (status != 'presente') {
        _isLate[playerId] = false;
        _minutesLate[playerId] = 0;
      }
    });
  }

  void _setAllStatus(String status) {
    final teamProvider = context.read<TeamProvider>();
    setState(() {
      for (final player in teamProvider.players) {
        _attendanceStatus[player.id] = status;
        if (status != 'presente') {
          _isLate[player.id] = false;
          _minutesLate[player.id] = 0;
        }
      }
    });
  }

  void _resetAll() {
    setState(() {
      _attendanceStatus.clear();
      _isLate.clear();
      _minutesLate.clear();
      _notes.clear();
    });
  }

  String _getStatusEmoji(String status) {
    switch (status) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'presente':
        return AppTheme.successColor;
      case 'assente':
        return AppTheme.errorColor;
      case 'giustificato':
        return AppTheme.warningColor;
      case 'infortunato':
        return Colors.purple;
      default:
        return AppTheme.textSecondary;
    }
  }

  Future<void> _saveAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final teamProvider = context.read<TeamProvider>();
      final isTraining = widget.event is Training;
      
      print('=== SALVATAGGIO PRESENZE ==='); // Debug
      print('EventId: ${widget.event.id}'); // Debug
      print('Presenze da salvare: ${_attendanceStatus.length}'); // Debug
      
      // 🚀 CORREZIONE: Elimina prima le presenze esistenti per questo evento
      final existingAttendance = teamProvider.attendance
          .where((a) => a.eventId == widget.event.id)
          .toList();
      
      print('Presenze esistenti da eliminare: ${existingAttendance.length}'); // Debug
      
      for (final attendance in existingAttendance) {
        await teamProvider.removeAttendanceRecord(attendance.id);
        print('Eliminata presenza: ${attendance.id}'); // Debug
      }

      // 🚀 CORREZIONE: Crea nuovi record di presenza
      for (final entry in _attendanceStatus.entries) {
        final playerId = entry.key;
        final status = entry.value;
        
        if (status.isNotEmpty) {
          final attendance = Attendance(
            id: AppUtils.generateId(),
            playerId: playerId,
            eventId: widget.event.id,
            eventType: isTraining ? 'training' : 'match',
            status: status,
            eventDate: widget.event.dateTime,
            notes: _notes[playerId]?.isNotEmpty == true ? _notes[playerId] : null,
            isLate: _isLate[playerId] ?? false,
            minutesLate: (_isLate[playerId] ?? false) ? _minutesLate[playerId] : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          print('Salvando presenza: Player=${playerId}, Status=${status}'); // Debug
          await teamProvider.recordAttendance(attendance); // 🚀 USA recordAttendance invece di updateAttendance
        }
      }

      print('=== PRESENZE SALVATE CON SUCCESSO ==='); // Debug
      AppUtils.showSuccessSnackBar(context, 'Presenze salvate con successo');
      Navigator.of(context).pop();
      
    } catch (e) {
      print('=== ERRORE NEL SALVATAGGIO ==='); // Debug
      print('Errore: $e'); // Debug
      AppUtils.showErrorSnackBar(context, 'Errore nel salvare le presenze: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
