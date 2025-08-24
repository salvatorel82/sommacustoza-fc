import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SommacustozaWebApp());
}

// Provider per gestire stato app
class AppStateProvider extends ChangeNotifier {
  List<Player> _players = [];
  List<Staff> _staff = [];
  List<Training> _trainings = [];
  
  List<Player> get players => _players;
  List<Staff> get staff => _staff;
  List<Training> get trainings => _trainings;
  
  AppStateProvider() {
    _loadInitialData();
  }
  
  void _loadInitialData() {
    // Dati iniziali di esempio
    _players = [
      Player('Marco Rossi', 'Portiere', 25, '⭐⭐⭐⭐⭐'),
      Player('Luca Bianchi', 'Difensore', 23, '⭐⭐⭐⭐'),
      Player('Andrea Verdi', 'Centrocampista', 26, '⭐⭐⭐⭐⭐'),
      Player('Giuseppe Neri', 'Attaccante', 24, '⭐⭐⭐⭐'),
      Player('Francesco Blu', 'Centrocampista', 22, '⭐⭐⭐'),
    ];
    
    _staff = [
      Staff('Coach Martinelli', 'Allenatore', '📋 Tattica e strategia'),
      Staff('Dr. Sanchez', 'Preparatore Atletico', '💪 Fitness e recupero'),
      Staff('Antonio Ricci', 'Team Manager', '📊 Gestione squadra'),
    ];
    
    _trainings = [
      Training('Oggi 18:00', 'Allenamento tattico', '⚽ Preparazione partita'),
      Training('Domani 18:00', 'Preparazione fisica', '🏃‍♂️ Resistenza e velocità'),
      Training('Venerdì 18:00', 'Prove tecniche', '🎯 Passaggi e tiri'),
      Training('Sabato 16:00', 'Allenamento completo', '⚽ Tattica + Tecnica'),
    ];
    
    notifyListeners();
  }
  
  void addPlayer(Player player) {
    _players.add(player);
    notifyListeners();
  }
  
  void removePlayer(int index) {
    _players.removeAt(index);
    notifyListeners();
  }
  
  void addStaff(Staff staff) {
    _staff.add(staff);
    notifyListeners();
  }
  
  void addTraining(Training training) {
    _trainings.add(training);
    notifyListeners();
  }
}

// Modelli dati
class Player {
  final String name;
  final String position;
  final int age;
  final String rating;
  
  Player(this.name, this.position, this.age, this.rating);
}

class Staff {
  final String name;
  final String role;
  final String description;
  
  Staff(this.name, this.role, this.description);
}

class Training {
  final String datetime;
  final String title;
  final String description;
  
  Training(this.datetime, this.title, this.description);
}

class SommacustozaWebApp extends StatelessWidget {
  const SommacustozaWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStateProvider(),
      child: MaterialApp(
        title: 'SOMMACUSTOZA08',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
        ),
        locale: const Locale('it', 'IT'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it', 'IT'),
          Locale('en', 'US'),
        ],
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _startApp();
  }

  void _startApp() async {
    await _animationController.forward();
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 60,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SOMMACUSTOZA08',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gestione Squadra di Calcio',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🌐 Web App',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    
    final screens = [
      const DashboardScreen(),
      PlayersScreen(appState: appState),
      CalendarScreen(appState: appState),
      StaffScreen(appState: appState),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOMMACUSTOZA08'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Giocatori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account),
            label: 'Staff',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Info Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sports_soccer,
                        size: 40,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SOMMACUSTOZA08',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Stagione 2024/2025 • 🌐 Web App',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        '${appState.players.length}', 
                        'Giocatori', 
                        Icons.people,
                      ),
                      _buildStatCard(
                        '${appState.staff.length}', 
                        'Staff', 
                        Icons.supervisor_account,
                      ),
                      _buildStatCard(
                        '${appState.trainings.length}', 
                        'Allenamenti', 
                        Icons.fitness_center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Prossimi Allenamenti
          const Text(
            'Prossimi Allenamenti',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: appState.trainings.take(3).map((training) {
                  return _buildTrainingItem(
                    training.datetime,
                    training.title,
                    training.description,
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Info Web App
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.web, color: Color(0xFF2E7D32)),
                      SizedBox(width: 8),
                      Text(
                        'Web App Features',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '✅ Funziona su qualsiasi dispositivo\n'
                    '✅ Nessuna installazione necessaria\n'
                    '✅ Aggiornamenti automatici\n'
                    '✅ Condivisibile con link\n'
                    '✅ Installabile come PWA',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showInstallInfo(context),
                      icon: const Icon(Icons.install_mobile),
                      label: const Text('Come installare come app'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrainingItem(String time, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$title - $description',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showInstallInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Installa come App'),
        content: const Text(
          'Per installare SOMMACUSTOZA08 come app:\n\n'
          '🌐 Chrome/Edge: Menu → "Installa app"\n'
          '🍎 Safari: Condividi → "Aggiungi a Home"\n'
          '📱 Firefox: Menu → "Installa"\n\n'
          'L\'app apparirà nella home come un\'app nativa!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class PlayersScreen extends StatelessWidget {
  final AppStateProvider appState;
  
  const PlayersScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestione Giocatori',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FloatingActionButton.small(
                onPressed: () => _showAddPlayerDialog(context),
                backgroundColor: const Color(0xFF2E7D32),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: appState.players.length,
              itemBuilder: (context, index) {
                final player = appState.players[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32),
                      child: Text(
                        player.name.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${player.position} • ${player.age} anni • ${player.rating}',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: const Text('Rimuovi'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          appState.removePlayer(index);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddPlayerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final positionController = TextEditingController();
    final ageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Giocatore'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: positionController,
              decoration: const InputDecoration(labelText: 'Ruolo'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Età'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                appState.addPlayer(Player(
                  nameController.text,
                  positionController.text.isNotEmpty ? positionController.text : 'Giocatore',
                  int.tryParse(ageController.text) ?? 25,
                  '⭐⭐⭐',
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  final AppStateProvider appState;
  
  const CalendarScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendario Allenamenti',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FloatingActionButton.small(
                onPressed: () => _showAddTrainingDialog(context),
                backgroundColor: const Color(0xFF2E7D32),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: appState.trainings.length,
              itemBuilder: (context, index) {
                final training = appState.trainings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF2E7D32),
                      child: Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      training.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${training.datetime}\n${training.description}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddTrainingDialog(BuildContext context) {
    final titleController = TextEditingController();
    final datetimeController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Allenamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titolo'),
            ),
            TextField(
              controller: datetimeController,
              decoration: const InputDecoration(labelText: 'Data e ora'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                appState.addTraining(Training(
                  datetimeController.text.isNotEmpty ? datetimeController.text : 'Da definire',
                  titleController.text,
                  descriptionController.text.isNotEmpty ? descriptionController.text : '⚽ Allenamento standard',
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}

class StaffScreen extends StatelessWidget {
  final AppStateProvider appState;
  
  const StaffScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestione Staff',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FloatingActionButton.small(
                onPressed: () => _showAddStaffDialog(context),
                backgroundColor: const Color(0xFF2E7D32),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: appState.staff.length,
              itemBuilder: (context, index) {
                final staff = appState.staff[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32),
                      child: Text(
                        staff.name.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      staff.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${staff.role}\n${staff.description}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddStaffDialog(BuildContext context) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Ruolo'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                appState.addStaff(Staff(
                  nameController.text,
                  roleController.text.isNotEmpty ? roleController.text : 'Staff',
                  descriptionController.text.isNotEmpty ? descriptionController.text : '👨‍💼 Membro dello staff',
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}
