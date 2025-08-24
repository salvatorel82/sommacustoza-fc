import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/common/custom_cards.dart';
import '../../widgets/common/custom_buttons.dart';
import '../players/players_screen.dart';
import '../staff/staff_screen.dart';
import '../calendar/calendar_screen.dart';
import '../matches/matches_screen.dart';
import '../statistics/statistics_screen.dart';
import '../formations/formations_screen.dart';
import '../attendance/attendance_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  
  final List<Widget> _screens = [
    const DashboardHome(),
    const PlayersScreen(),
    const StaffScreen(),
    const CalendarScreen(),
    const MatchesScreen(),
    const AttendanceScreen(),
    const StatisticsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Giocatori',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.work),
      label: 'Staff',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Calendario',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.sports_soccer),
      label: 'Partite',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.how_to_reg),
      label: 'Presenze',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: 'Statistiche',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    context.read<AppProvider>().setCurrentIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Scaffold(
            body: PageView(
              controller: _pageController,
              children: _screens,
              onPageChanged: (index) {
                appProvider.setCurrentIndex(index);
              },
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: appProvider.currentIndex,
                onTap: _onNavItemTapped,
                items: _navItems,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppTheme.primaryColor,
                unselectedItemColor: AppTheme.textSecondary,
                selectedFontSize: 11,
                unselectedFontSize: 10,
                elevation: 0,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiudi App'),
        content: const Text('Sei sicuro di voler chiudere l\'app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    ) ?? false;
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickStats(context),
                const SizedBox(height: 24),
                _buildNextEvents(context),
                const SizedBox(height: 24),
                _buildRecentActivity(context),
                const SizedBox(height: 32), // Space for bottom navigation
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'SOMMACUSTOZA08',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer3<TeamProvider, CalendarProvider, MatchProvider>(
      builder: (context, teamProvider, calendarProvider, matchProvider, child) {
        final matchStats = matchProvider.matchStatistics;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiche Rapide',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                StatsCard(
                  title: 'Giocatori',
                  value: teamProvider.totalPlayers.toString(),
                  subtitle: 'Attivi',
                  icon: Icons.people,
                  iconColor: AppTheme.primaryColor,
                ),
                StatsCard(
                  title: 'Staff',
                  value: teamProvider.totalStaff.toString(),
                  subtitle: 'Attivo',
                  icon: Icons.work,
                  iconColor: Colors.purple,
                ),
                StatsCard(
                  title: 'Vittorie',
                  value: matchStats['wins'].toString(),
                  subtitle: '${matchStats['total']} totali',
                  icon: Icons.emoji_events,
                  iconColor: AppTheme.successColor,
                ),
                StatsCard(
                  title: 'Allenamenti',
                  value: calendarProvider.completedTrainings.toString(),
                  subtitle: 'Completati',
                  icon: Icons.fitness_center,
                  iconColor: AppTheme.accentColor,
                ),
              ],
            ),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
      },
    );
  }

  Widget _buildNextEvents(BuildContext context) {
    return Consumer2<CalendarProvider, MatchProvider>(
      builder: (context, calendarProvider, matchProvider, child) {
        final upcomingEvents = [
          ...calendarProvider.getUpcomingEvents(limit: 3),
          ...matchProvider.getNextMatches(limit: 2),
        ];
        
        upcomingEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prossimi Eventi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomTextButton(
                  text: 'Tutti',
                  onPressed: () {
                    context.read<AppProvider>().setCurrentIndex(3);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (upcomingEvents.isEmpty)
              const CustomCard(
                child: Text(
                  'Nessun evento in programma',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ...upcomingEvents.take(3).map((event) {
                final isTraining = event.runtimeType.toString() == 'Training';
                return EventCard(
                  title: isTraining ? 'Allenamento ${event.type}' : 'Vs ${event.opponent}',
                  subtitle: event.location,
                  dateTime: event.dateTime,
                  icon: isTraining ? Icons.fitness_center : Icons.sports_soccer,
                  iconColor: isTraining ? AppTheme.accentColor : AppTheme.primaryColor,
                  onTap: () {
                    // TODO: Navigate to event details
                  },
                ).animate()
                    .fadeIn(delay: (300 + upcomingEvents.indexOf(event) * 100).ms)
                    .slideX(begin: 0.3);
              }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Consumer2<CalendarProvider, MatchProvider>(
      builder: (context, calendarProvider, matchProvider, child) {
        final recentMatches = matchProvider.getRecentMatches(limit: 3);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attività Recente',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recentMatches.isEmpty)
              const CustomCard(
                child: Text(
                  'Nessuna attività recente',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ...recentMatches.map((match) {
                Color resultColor = AppTheme.textSecondary;
                if (match.result != null) {
                  switch (match.result!.toLowerCase()) {
                    case 'vittoria':
                      resultColor = AppTheme.successColor;
                      break;
                    case 'pareggio':
                      resultColor = AppTheme.warningColor;
                      break;
                    case 'sconfitta':
                      resultColor = AppTheme.errorColor;
                      break;
                  }
                }
                
                return EventCard(
                  title: 'Vs ${match.opponent}',
                  subtitle: '${match.result ?? "N/A"} • ${match.goalsFor ?? 0}-${match.goalsAgainst ?? 0}',
                  dateTime: match.dateTime,
                  icon: Icons.sports_soccer,
                  iconColor: resultColor,
                  isPast: true,
                  onTap: () {
                    // TODO: Navigate to match details
                  },
                ).animate()
                    .fadeIn(delay: (500 + recentMatches.indexOf(match) * 100).ms)
                    .slideX(begin: -0.3);
              }).toList(),
          ],
        );
      },
    );
  }
}
