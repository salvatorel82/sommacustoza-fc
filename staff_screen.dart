import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/staff.dart';
import '../../providers/team_provider.dart';
import '../../widgets/common/custom_cards.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';
import 'add_edit_staff_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
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
            child: _buildStaffTab(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStaff,
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
              'Staff',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<TeamProvider>(
              builder: (context, teamProvider, child) {
                return Text(
                  '${teamProvider.totalStaff} membri dello staff',
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
        hint: 'Cerca staff...',
        prefixIcon: const Icon(Icons.search),
        controller: _searchController,
        onChanged: (value) {
          context.read<TeamProvider>().setSearchQuery(value);
        },
      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
    );
  }

  Widget _buildStaffTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final staff = teamProvider.filteredStaff;
        
        if (staff.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Space for FAB
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final member = staff[index];
            return _buildStaffCard(member);
          },
        );
      },
    );
  }

  Widget _buildStaffCard(Staff staff) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showStaffOptions(staff),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.purple.withOpacity(0.1),
            backgroundImage: staff.photo != null ? NetworkImage(staff.photo!) : null,
            child: staff.photo == null
                ? Text(
                    _getInitials(staff.name),
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Staff Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  staff.role,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (staff.qualifications != null && staff.qualifications!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    staff.qualifications!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: (staff.hashCode % 5 * 50).ms)
        .slideX(begin: 0.2);
  }

  void _addStaff() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditStaffScreen(),
      ),
    );
  }

  void _showStaffOptions(Staff staff) {
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
        child: _StaffOptionsBottomSheet(staff: staff),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun Membro dello Staff',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inizia aggiungendo il primo membro dello staff',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addStaff,
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Staff'),
          ),
        ],
      ),
    );
  }
}

class _StaffOptionsBottomSheet extends StatelessWidget {
  final Staff staff;

  const _StaffOptionsBottomSheet({required this.staff});

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
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: Text(
              _getInitials(staff.name),
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            staff.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            staff.role,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionTile(
            icon: Icons.edit,
            title: 'Modifica Staff',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditStaffScreen(staff: staff),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.phone,
            title: 'Contatta',
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Contact staff member
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.info,
            title: 'Dettagli',
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Show staff details
            },
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.delete,
            title: 'Rimuovi Staff',
            textColor: AppTheme.errorColor,
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, staff);
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

  void _showDeleteConfirmation(BuildContext context, Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rimuovi Staff'),
        content: Text('Sei sicuro di voler rimuovere ${staff.name} dallo staff?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TeamProvider>().removeStaff(staff.id);
            },
            child: const Text('Rimuovi', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
