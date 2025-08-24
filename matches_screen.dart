import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/match.dart';
import '../../providers/match_provider.dart';
import '../../widgets/common/custom_cards.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
                _buildAllMatchesTab(),
                _buildUpcomingMatchesTab(),
                _buildCompletedMatchesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMatch,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
                  'Partite',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
            Consumer<MatchProvider>(
              builder: (context, matchProvider, child) {
                return Text(
                  '${matchProvider.totalMatches} partite • ${matchProvider.upcomingMatchesCount} future',
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
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final stats = matchProvider.matchStatistics;
        final winPercentage = (stats['total'] ?? 0) > 0 
            ? (stats['wins']! / stats['total']!) * 100 
            : 0.0;

        return Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Vittorie',
                  value: stats['wins'].toString(),
                  subtitle: '${winPercentage.toStringAsFixed(0)}%',
                  icon: Icons.emoji_events,
                  iconColor: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Gol',
                  value: matchProvider.goalsScored.toString(),
                  subtitle: 'Fatti',
                  icon: Icons.sports_soccer,
                  iconColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Pareggi',
                  value: stats['draws'].toString(),
                  subtitle: 'Totali',
                  icon: Icons.handshake,
                  iconColor: AppTheme.warningColor,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms);
      },
    );
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
          Tab(text: 'Tutte'),
          Tab(text: 'Future'),
          Tab(text: 'Passate'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildAllMatchesTab() {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final matches = matchProvider.matches;
        
        if (matches.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _buildMatchCard(match);
          },
        );
      },
    );
  }

  Widget _buildUpcomingMatchesTab() {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final matches = matchProvider.upcomingMatches;
        
        if (matches.isEmpty) {
          return _buildEmptyState('Nessuna partita in programma');
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _buildMatchCard(match);
          },
        );
      },
    );
  }

  Widget _buildCompletedMatchesTab() {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final matches = matchProvider.completedMatches;
        
        if (matches.isEmpty) {
          return _buildEmptyState('Nessuna partita completata');
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _buildMatchCard(match);
          },
        );
      },
    );
  }

  Widget _buildMatchCard(Match match) {
    final dateFormat = DateFormat('dd/MM HH:mm');
    Color? resultColor;
    
    if (match.result != null && match.isCompleted) {
      switch (match.result!.toLowerCase()) {
        case 'vittoria':
          resultColor = Colors.green;
          break;
        case 'pareggio':
          resultColor = Colors.orange;
          break;
        case 'sconfitta':
          resultColor = Colors.red;
          break;
      }
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showMatchActions(match),
      border: resultColor != null ? Border.all(color: resultColor, width: 2) : null,
      child: Row(
        children: [
          // Match Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (resultColor ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              match.isHome ? Icons.home : Icons.flight_takeoff,
              color: resultColor ?? AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Match Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Vs ${match.opponent}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (match.isCompleted && match.result != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: resultColor!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          match.result!,
                          style: TextStyle(
                            color: resultColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
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
                        match.location,
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
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(match.dateTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Result/Score
          if (match.isCompleted && match.goalsFor != null && match.goalsAgainst != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${match.goalsFor}-${match.goalsAgainst}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
          else if (!match.isCompleted)
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
        ],
      ),
    );
  }

  void _showMatchActions(Match match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: _MatchActionsBottomSheet(match: match),
      ),
    );
  }

  void _addMatch() {
    showDialog(
      context: context,
      builder: (context) => const _AddMatchDialog(),
    );
  }

  Widget _buildEmptyState([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Nessuna Partita',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inizia aggiungendo la prima partita',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addMatch,
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Partita'),
          ),
        ],
      ),
    );
  }

  static void _showResultDialog(BuildContext context, Match match) {
    final goalsForController = TextEditingController();
    final goalsAgainstController = TextEditingController();
    String selectedResult = 'Vittoria';
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Risultato - Vs ${match.opponent}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedResult,
                decoration: const InputDecoration(labelText: 'Risultato'),
                items: const [
                  DropdownMenuItem(value: 'Vittoria', child: Text('Vittoria')),
                  DropdownMenuItem(value: 'Pareggio', child: Text('Pareggio')),
                  DropdownMenuItem(value: 'Sconfitta', child: Text('Sconfitta')),
                ],
                onChanged: (value) => setState(() => selectedResult = value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: goalsForController,
                      decoration: const InputDecoration(labelText: 'Gol Fatti'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: goalsAgainstController,
                      decoration: const InputDecoration(labelText: 'Gol Subiti'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                final goalsFor = int.tryParse(goalsForController.text) ?? 0;
                final goalsAgainst = int.tryParse(goalsAgainstController.text) ?? 0;
                
                try {
                  await context.read<MatchProvider>().updateMatchResult(
                    matchId: match.id,
                    result: selectedResult,
                    goalsFor: goalsFor,
                    goalsAgainst: goalsAgainst,
                  );
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Risultato salvato con successo')),
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

  static void _showEditMatchDialog(BuildContext context, Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Partita'),
        content: const Text('Funzione non ancora implementata.\nPer modifiche complete, è consigliabile eliminare e ricreare la partita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showFormationDialog(BuildContext context, Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestisci Formazione'),
        content: const Text('Funzione non ancora implementata.\nLa gestione delle formazioni sarà disponibile nelle prossime versioni.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showDeleteConfirmation(BuildContext context, Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare la partita contro ${match.opponent}?\nQuesta azione non può essere annullata.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<MatchProvider>().removeMatch(match.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partita eliminata con successo')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Errore nell\'eliminazione: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}

class _AddMatchDialog extends StatefulWidget {
  const _AddMatchDialog();

  @override
  State<_AddMatchDialog> createState() => _AddMatchDialogState();
}

class _AddMatchDialogState extends State<_AddMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _opponentController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isHome = true;
  String _competitionType = 'Campionato';

  @override
  void dispose() {
    _opponentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuova Partita'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Avversario',
                controller: _opponentController,
                validator: (value) => value?.isEmpty ?? true ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Luogo',
                controller: _locationController,
                validator: (value) => value?.isEmpty ?? true ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Data'),
                      subtitle: Text(_selectedDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                          : 'Seleziona data'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Ora'),
                      subtitle: Text(_selectedTime != null 
                          ? _selectedTime!.format(context)
                          : 'Seleziona ora'),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Partita in casa'),
                value: _isHome,
                onChanged: (value) => setState(() => _isHome = value),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
      actions: [
        CustomTextButton(
          text: 'Annulla',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomButton(
          text: 'Salva',
          onPressed: _saveMatch,
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveMatch() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleziona data e ora')),
        );
        return;
      }

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      context.read<MatchProvider>().createQuickMatch(
            opponent: _opponentController.text,
            dateTime: dateTime,
            location: _locationController.text,
            isHome: _isHome,
            competitionType: _competitionType,
          );

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partita aggiunta con successo')),
      );
    }
  }
}

class _MatchActionsBottomSheet extends StatelessWidget {
  final Match match;

  const _MatchActionsBottomSheet({required this.match});

  @override
  Widget build(BuildContext context) {
    final isPast = match.dateTime.isBefore(DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vs ${match.opponent}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (!match.isCompleted && isPast) ...[
            _buildActionTile(
              icon: Icons.edit_note,
              title: 'Inserisci Risultato',
              onTap: () {
                Navigator.of(context).pop();
                _MatchesScreenState._showResultDialog(context, match);
              },
            ),
            const SizedBox(height: 8),
          ],
          _buildActionTile(
            icon: Icons.edit,
            title: 'Modifica Partita',
            onTap: () {
              Navigator.of(context).pop();
              _MatchesScreenState._showEditMatchDialog(context, match);
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.group,
            title: 'Gestisci Formazione',
            onTap: () {
              Navigator.of(context).pop();
              _MatchesScreenState._showFormationDialog(context, match);
            },
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.delete,
            title: 'Elimina Partita',
            textColor: AppTheme.errorColor,
            onTap: () {
              Navigator.of(context).pop();
              _MatchesScreenState._showDeleteConfirmation(context, match);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
