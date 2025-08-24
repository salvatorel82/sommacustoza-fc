import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/player.dart';
import '../../providers/team_provider.dart';
import '../../widgets/common/custom_cards.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';

class FormationsScreen extends StatefulWidget {
  const FormationsScreen({super.key});

  @override
  State<FormationsScreen> createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFormation = '4-4-2';
  Map<String, Player?> _selectedPlayers = {};
  List<Player> _availablePlayers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPlayers() {
    final teamProvider = context.read<TeamProvider>();
    setState(() {
      _availablePlayers = teamProvider.players;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFormationBuilderTab(),
                _buildSavedFormationsTab(),
                _buildTacticalAnalysisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
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
                  'Formazioni',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: _saveCurrentFormation,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: _shareFormation,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Crea e gestisci le formazioni della squadra',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Crea'),
          Tab(text: 'Salvate'),
          Tab(text: 'Analisi'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFormationBuilderTab() {
    return Column(
      children: [
        _buildFormationSelector(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildFootballField(),
              ),
              Container(
                width: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                flex: 1,
                child: _buildPlayersList(),
              ),
            ],
          ),
        ),
        _buildFormationActions(),
      ],
    );
  }

  Widget _buildFormationSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: CustomDropdown<String>(
        label: 'Modulo',
        value: _selectedFormation,
        items: AppConstants.formations
            .map((formation) => DropdownMenuItem(
                  value: formation,
                  child: Text(formation),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedFormation = value!;
            _selectedPlayers.clear();
          });
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildFootballField() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: CustomCard(
        child: AspectRatio(
          aspectRatio: 0.68, // Standard football field ratio
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                _buildFieldMarkings(),
                ..._buildPlayerPositions(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildFieldMarkings() {
    return CustomPaint(
      size: Size.infinite,
      painter: FootballFieldPainter(),
    );
  }

  List<Widget> _buildPlayerPositions() {
    final positions = _getFormationPositions(_selectedFormation);
    List<Widget> playerWidgets = [];

    for (int i = 0; i < positions.length; i++) {
      final position = positions[i];
      final player = _selectedPlayers['position_$i'];
      
      playerWidgets.add(
        Positioned(
          left: position['x']! * 320 - 25, // Adjust for player circle size
          top: position['y']! * 480 - 25,
          child: GestureDetector(
            onTap: () => _showPlayerSelectionDialog(i),
            child: _buildPlayerCircle(player, position['role']!),
          ),
        ),
      );
    }

    return playerWidgets;
  }

  Widget _buildPlayerCircle(Player? player, String role) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: player != null ? AppTheme.primaryColor : Colors.white,
        border: Border.all(
          color: player != null ? Colors.white : AppTheme.primaryColor,
          width: 2,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (player != null) ...[
            Text(
              player.number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              player.name.split(' ').first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Icon(
              Icons.add,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            Text(
              role,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giocatori Disponibili',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _availablePlayers.length,
              itemBuilder: (context, index) {
                final player = _availablePlayers[index];
                final isSelected = _selectedPlayers.values.contains(player);
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: isSelected 
                          ? AppTheme.primaryColor.withOpacity(0.2)
                          : Colors.grey.shade200,
                      child: Text(
                        player.number.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    subtitle: Text(
                      player.position,
                      style: const TextStyle(fontSize: 12),
                    ),
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: isSelected 
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: CustomOutlinedButton(
              text: 'Cancella',
              onPressed: () {
                setState(() {
                  _selectedPlayers.clear();
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Salva Formazione',
              onPressed: _saveCurrentFormation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedFormationsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Nessuna formazione salvata',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Le formazioni salvate appariranno qui',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormationAnalysis(),
          const SizedBox(height: 24),
          _buildPlayerRolesAnalysis(),
          const SizedBox(height: 24),
          _buildTacticalSuggestions(),
        ],
      ),
    );
  }

  Widget _buildFormationAnalysis() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analisi Modulo $_selectedFormation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem(
            'Stile di Gioco',
            _getFormationStyle(_selectedFormation),
            Icons.sports_soccer,
          ),
          _buildAnalysisItem(
            'Punti di Forza',
            _getFormationStrengths(_selectedFormation),
            Icons.trending_up,
          ),
          _buildAnalysisItem(
            'Punti Deboli',
            _getFormationWeaknesses(_selectedFormation),
            Icons.trending_down,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildPlayerRolesAnalysis() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analisi Ruoli',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRoleAnalysis('Difesa', _getDefendersCount(), AppTheme.primaryColor),
          _buildRoleAnalysis('Centrocampo', _getMidfieldersCount(), AppTheme.successColor),
          _buildRoleAnalysis('Attacco', _getAttackersCount(), AppTheme.accentColor),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRoleAnalysis(String role, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              role,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$count giocatori',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalSuggestions() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggerimenti Tattici',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_getTacticalSuggestions(_selectedFormation).map((suggestion) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildAnalysisItem(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerSelectionDialog(int positionIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona Giocatore'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _availablePlayers.length,
            itemBuilder: (context, index) {
              final player = _availablePlayers[index];
              final isAlreadySelected = _selectedPlayers.values.contains(player);
              
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  child: Text(player.number.toString()),
                ),
                title: Text(player.name),
                subtitle: Text(player.position),
                enabled: !isAlreadySelected,
                onTap: () {
                  setState(() {
                    _selectedPlayers['position_$positionIndex'] = player;
                  });
                  Navigator.of(context).pop();
                },
                trailing: isAlreadySelected 
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
              );
            },
          ),
        ),
        actions: [
          CustomTextButton(
            text: 'Rimuovi',
            onPressed: () {
              setState(() {
                _selectedPlayers.remove('position_$positionIndex');
              });
              Navigator.of(context).pop();
            },
          ),
          CustomTextButton(
            text: 'Annulla',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFormationPositions(String formation) {
    switch (formation) {
      case '4-4-2':
        return [
          // Goalkeeper
          {'x': 0.5, 'y': 0.95, 'role': 'P'},
          // Defenders
          {'x': 0.2, 'y': 0.75, 'role': 'TD'},
          {'x': 0.4, 'y': 0.75, 'role': 'DC'},
          {'x': 0.6, 'y': 0.75, 'role': 'DC'},
          {'x': 0.8, 'y': 0.75, 'role': 'TS'},
          // Midfielders
          {'x': 0.2, 'y': 0.45, 'role': 'ED'},
          {'x': 0.4, 'y': 0.45, 'role': 'CC'},
          {'x': 0.6, 'y': 0.45, 'role': 'CC'},
          {'x': 0.8, 'y': 0.45, 'role': 'ES'},
          // Forwards
          {'x': 0.35, 'y': 0.15, 'role': 'A'},
          {'x': 0.65, 'y': 0.15, 'role': 'A'},
        ];
      case '4-3-3':
        return [
          // Goalkeeper
          {'x': 0.5, 'y': 0.95, 'role': 'P'},
          // Defenders
          {'x': 0.2, 'y': 0.75, 'role': 'TD'},
          {'x': 0.4, 'y': 0.75, 'role': 'DC'},
          {'x': 0.6, 'y': 0.75, 'role': 'DC'},
          {'x': 0.8, 'y': 0.75, 'role': 'TS'},
          // Midfielders
          {'x': 0.3, 'y': 0.5, 'role': 'CC'},
          {'x': 0.5, 'y': 0.45, 'role': 'CC'},
          {'x': 0.7, 'y': 0.5, 'role': 'CC'},
          // Forwards
          {'x': 0.2, 'y': 0.15, 'role': 'AS'},
          {'x': 0.5, 'y': 0.1, 'role': 'A'},
          {'x': 0.8, 'y': 0.15, 'role': 'AD'},
        ];
      case '3-5-2':
        return [
          // Goalkeeper
          {'x': 0.5, 'y': 0.95, 'role': 'P'},
          // Defenders
          {'x': 0.3, 'y': 0.75, 'role': 'DC'},
          {'x': 0.5, 'y': 0.75, 'role': 'DC'},
          {'x': 0.7, 'y': 0.75, 'role': 'DC'},
          // Midfielders
          {'x': 0.15, 'y': 0.55, 'role': 'ES'},
          {'x': 0.35, 'y': 0.45, 'role': 'CC'},
          {'x': 0.5, 'y': 0.4, 'role': 'CC'},
          {'x': 0.65, 'y': 0.45, 'role': 'CC'},
          {'x': 0.85, 'y': 0.55, 'role': 'ED'},
          // Forwards
          {'x': 0.4, 'y': 0.15, 'role': 'A'},
          {'x': 0.6, 'y': 0.15, 'role': 'A'},
        ];
      default:
        return _getFormationPositions('4-4-2');
    }
  }

  String _getFormationStyle(String formation) {
    switch (formation) {
      case '4-4-2':
        return 'Equilibrato, gioco diretto, pressing alto';
      case '4-3-3':
        return 'Offensivo, possesso palla, attacchi sulle fasce';
      case '3-5-2':
        return 'Flessibile, controllo centrocampo, esterni attivi';
      case '4-2-3-1':
        return 'Creativo, supporto al centravanti, gioco di qualità';
      default:
        return 'Formazione versatile e bilanciata';
    }
  }

  String _getFormationStrengths(String formation) {
    switch (formation) {
      case '4-4-2':
        return 'Solidità difensiva, facilità di apprendimento, efficacia sulle palle inattive';
      case '4-3-3':
        return 'Ampiezza in attacco, pressione alta, gioco spettacolare';
      case '3-5-2':
        return 'Dominio del centrocampo, versatilità tattica, esterni protagonisti';
      case '4-2-3-1':
        return 'Creatività offensiva, protezione difensiva, superiorità numerica a centrocampo';
      default:
        return 'Equilibrio tra fase offensiva e difensiva';
    }
  }

  String _getFormationWeaknesses(String formation) {
    switch (formation) {
      case '4-4-2':
        return 'Inferiorità numerica a centrocampo, vulnerabilità sulle fasce';
      case '4-3-3':
        return 'Richiede giocatori fisicamente preparati, spazi tra i reparti';
      case '3-5-2':
        return 'Vulnerabile negli spazi laterali, richiede esterni molto preparati';
      case '4-2-3-1':
        return 'Dipendenza dal trequartista, possibili difficoltà offensive';
      default:
        return 'Potrebbe mancare di specializzazione in alcune fasi';
    }
  }

  List<String> _getTacticalSuggestions(String formation) {
    switch (formation) {
      case '4-4-2':
        return [
          'Mantieni i terzini alti per creare ampiezza',
          'I centrocampisti centrali devono coprire molto campo',
          'Le punte devono muoversi in modo complementare',
          'Pressa alta con i quattro di centrocampo',
        ];
      case '4-3-3':
        return [
          'Gli esterni devono rientrare per creare superiorità numerica',
          'Il centrocampista centrale ha un ruolo chiave nella costruzione',
          'Le ali devono attaccare lo spazio alle spalle dei terzini',
          'Mantieni un pressing coordinato sui tre livelli',
        ];
      case '3-5-2':
        return [
          'Gli esterni di centrocampo devono coprire tutta la fascia',
          'I tre centrali devono essere bravi nel gioco aereo',
          'Sfrutta la superiorità numerica a centrocampo',
          'Le punte devono dialogare spesso tra loro',
        ];
      default:
        return [
          'Mantieni equilibrio tra fase difensiva e offensiva',
          'Comunica costantemente tra i reparti',
          'Adatta la formazione in base all\'avversario',
        ];
    }
  }

  int _getDefendersCount() {
    final formation = _selectedFormation.split('-');
    return int.parse(formation[0]);
  }

  int _getMidfieldersCount() {
    final formation = _selectedFormation.split('-');
    return int.parse(formation[1]);
  }

  int _getAttackersCount() {
    final formation = _selectedFormation.split('-');
    return int.parse(formation[2]);
  }

  void _saveCurrentFormation() {
    // TODO: Implement formation saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formazione salvata con successo')),
    );
  }

  void _shareFormation() {
    // TODO: Implement formation sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Condivisione formazione in sviluppo')),
    );
  }
}

class FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Field boundaries
    canvas.drawRect(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(10, size.height / 2),
      Offset(size.width - 10, size.height / 2),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      paint,
    );

    // Goal areas
    final goalAreaHeight = size.height * 0.12;
    final goalAreaWidth = size.width * 0.3;
    
    // Top goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaWidth) / 2,
        10,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );

    // Bottom goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaWidth) / 2,
        size.height - 10 - goalAreaHeight,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );

    // Penalty areas
    final penaltyAreaHeight = size.height * 0.18;
    final penaltyAreaWidth = size.width * 0.5;
    
    // Top penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyAreaWidth) / 2,
        10,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      paint,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyAreaWidth) / 2,
        size.height - 10 - penaltyAreaHeight,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      paint,
    );

    // Penalty spots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, 10 + penaltyAreaHeight * 0.65),
      3,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height - 10 - penaltyAreaHeight * 0.65),
      3,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
