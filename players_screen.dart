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
import 'add_edit_player_screen.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<TeamProvider>().setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: _buildPlayersTab(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
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
            Text(
              'Giocatori',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomTextField(
        hint: 'Cerca giocatori...',
        prefixIcon: const Icon(Icons.search),
        controller: _searchController,
        onChanged: (value) {
          context.read<TeamProvider>().setSearchQuery(value);
        },
      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
    );
  }

  Widget _buildPlayersTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final players = teamProvider.filteredPlayers;
        
        if (players.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Space for FAB
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return PlayerCard(
              name: player.name,
              position: player.position,
              number: player.number,
              imageUrl: player.photoUrl,
              isActive: player.isActive,
              onTap: () => _showPlayerOptions(player),
            ).animate()
                .fadeIn(delay: (index * 50).ms)
                .slideX(begin: 0.2);
          },
        );
      },
    );
  }

  void _addPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditPlayerScreen(),
      ),
    );
  }

  void _showPlayerOptions(Player player) {
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
        child: _PlayerOptionsBottomSheet(player: player),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun Giocatore',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inizia aggiungendo il primo giocatore alla squadra',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addPlayer,
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Giocatore'),
          ),
        ],
      ),
    );
  }
}

class _PlayerOptionsBottomSheet extends StatelessWidget {
  final Player player;

  const _PlayerOptionsBottomSheet({required this.player});

  @override
  Widget build(BuildContext context) {
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
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _getInitials(player.name),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            player.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            player.position,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionTile(
            icon: Icons.edit,
            title: 'Modifica Giocatore',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditPlayerScreen(player: player),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.analytics,
            title: 'Statistiche',
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Navigate to player statistics
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.how_to_reg,
            title: 'Presenze',
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Navigate to player attendance
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: player.isActive ? Icons.block : Icons.check_circle,
            title: player.isActive ? 'Disattiva' : 'Riattiva',
            textColor: player.isActive ? AppTheme.errorColor : AppTheme.successColor,
            onTap: () {
              Navigator.of(context).pop();
              context.read<TeamProvider>().togglePlayerStatus(player.id);
            },
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.delete,
            title: 'Elimina Giocatore',
            textColor: AppTheme.errorColor,
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, player);
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

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  void _showDeleteConfirmation(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Giocatore'),
        content: Text('Sei sicuro di voler eliminare ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TeamProvider>().removePlayer(player.id);
            },
            child: const Text('Elimina', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
