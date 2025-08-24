import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/team_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/common/custom_cards.dart';
import '../../widgets/common/custom_buttons.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTeamTab(),
                _buildMatchesTab(),
                _buildTrainingsTab(),
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
            Text(
              'Statistiche',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Analisi prestazioni della squadra',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
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
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        isScrollable: true,
        tabs: const [
          Tab(text: 'Panoramica'),
          Tab(text: 'Squadra'),
          Tab(text: 'Partite'),
          Tab(text: 'Allenamenti'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeasonSummary(),
          const SizedBox(height: 24),
          _buildPerformanceChart(),
          const SizedBox(height: 24),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildSeasonSummary() {
    return Consumer3<TeamProvider, CalendarProvider, MatchProvider>(
      builder: (context, teamProvider, calendarProvider, matchProvider, child) {
        final matchStats = matchProvider.matchStatistics;
        final winPercentage = (matchStats['total'] ?? 0) > 0 
            ? (matchStats['wins']! / matchStats['total']!) * 100 
            : 0.0;

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riepilogo Stagione',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Partite',
                      value: matchStats['total'].toString(),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Vittorie',
                      value: matchStats['wins'].toString(),
                      color: AppTheme.successColor,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      label: '% Vittorie',
                      value: '${winPercentage.toStringAsFixed(1)}%',
                      color: AppTheme.accentColor,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Allenamenti',
                      value: calendarProvider.totalTrainings.toString(),
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms);
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Andamento Prestazioni',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 3),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                      const FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildQuickStats() {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiche Rapide',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                StatsCard(
                  title: 'Gol Fatti',
                  value: matchProvider.goalsScored.toString(),
                  subtitle: 'Totali',
                  icon: Icons.sports_soccer,
                  iconColor: AppTheme.primaryColor,
                ),
                StatsCard(
                  title: 'Gol Subiti',
                  value: matchProvider.goalsConceded.toString(),
                  subtitle: 'Totali',
                  icon: Icons.sports_soccer,
                  iconColor: AppTheme.errorColor,
                ),
                StatsCard(
                  title: 'Media Gol',
                  value: matchProvider.averageGoalsScored.toStringAsFixed(1),
                  subtitle: 'Per partita',
                  icon: Icons.trending_up,
                  iconColor: AppTheme.successColor,
                ),
                StatsCard(
                  title: 'Differenza',
                  value: (matchProvider.goalsScored - matchProvider.goalsConceded).toString(),
                  subtitle: 'Reti',
                  icon: Icons.compare_arrows,
                  iconColor: AppTheme.accentColor,
                ),
              ],
            ),
          ],
        );
      },
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTeamTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistiche Squadra',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Column(
                  children: [
                    _buildTeamStatRow('Giocatori Totali', teamProvider.totalPlayers.toString()),
                    const Divider(),
                    _buildTeamStatRow('Staff Totale', teamProvider.totalStaff.toString()),
                    const Divider(),
                    _buildTeamStatRow('Giocatori Attivi', teamProvider.activePlayers.toString()),
                    const Divider(),
                    _buildTeamStatRow('Età Media', '${teamProvider.averageAge.toStringAsFixed(1)} anni'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final stats = matchProvider.matchStatistics;
        final homeAwayStats = matchProvider.homeAwayStats;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistiche Partite',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Column(
                  children: [
                    _buildTeamStatRow('Partite Totali', stats['total'].toString()),
                    const Divider(),
                    _buildTeamStatRow('Vittorie', stats['wins'].toString()),
                    const Divider(),
                    _buildTeamStatRow('Pareggi', stats['draws'].toString()),
                    const Divider(),
                    _buildTeamStatRow('Sconfitte', stats['losses'].toString()),
                    const Divider(),
                    _buildTeamStatRow('Gol Fatti', matchProvider.goalsScored.toString()),
                    const Divider(),
                    _buildTeamStatRow('Gol Subiti', matchProvider.goalsConceded.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Casa vs Trasferta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      child: Column(
                        children: [
                          const Text(
                            'Casa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Vittorie: ${homeAwayStats['homeWins']}'),
                          Text('Pareggi: ${homeAwayStats['homeDraws']}'),
                          Text('Sconfitte: ${homeAwayStats['homeLosses']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomCard(
                      child: Column(
                        children: [
                          const Text(
                            'Trasferta',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Vittorie: ${homeAwayStats['awayWins']}'),
                          Text('Pareggi: ${homeAwayStats['awayDraws']}'),
                          Text('Sconfitte: ${homeAwayStats['awayLosses']}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingsTab() {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        final stats = calendarProvider.getTrainingStatistics();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistiche Allenamenti',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Column(
                  children: [
                    _buildTeamStatRow('Allenamenti Totali', stats['totalTrainings'].toString()),
                    const Divider(),
                    _buildTeamStatRow('Completati', stats['completedTrainings'].toString()),
                    const Divider(),
                    _buildTeamStatRow('In Programma', stats['upcomingTrainings'].toString()),
                    const Divider(),
                    _buildTeamStatRow('Ore Totali', stats['totalHours'].toString()),
                    const Divider(),
                    _buildTeamStatRow('% Completamento', '${stats['completionRate'].toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
