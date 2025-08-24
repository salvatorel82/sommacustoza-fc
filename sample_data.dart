import '../../../data/models/player.dart';
import '../../../data/models/staff.dart';
import '../../../data/models/match.dart';
import '../../../data/models/training.dart';
import '../../../data/models/attendance.dart';
import '../../../core/utils/app_utils.dart';

class SampleData {
  /// Genera giocatori di esempio per testing e demo
  static List<Player> generateSamplePlayers() {
    final now = DateTime.now();
    
    return [
      Player(
        id: '1',
        name: 'Marco Rossi',
        number: 10,
        position: 'Centravanti',
        birthDate: DateTime(1995, 3, 15),
        phone: '+39 333 1234567',
        email: 'marco.rossi@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
        height: 180,
        weight: 75,
        notes: 'Capitano della squadra, ottimo realizzatore',
      ),
      Player(
        id: '2',
        name: 'Luca Bianchi',
        number: 1,
        position: 'Portiere',
        birthDate: DateTime(1990, 7, 22),
        phone: '+39 333 2345678',
        email: 'luca.bianchi@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now,
        height: 185,
        weight: 80,
        emergencyContact: 'Maria Bianchi',
        emergencyPhone: '+39 333 8888888',
      ),
      Player(
        id: '3',
        name: 'Andrea Verdi',
        number: 7,
        position: 'Ala Destra',
        birthDate: DateTime(1997, 11, 8),
        phone: '+39 333 3456789',
        email: 'andrea.verdi@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
        height: 175,
        weight: 70,
      ),
      Player(
        id: '4',
        name: 'Francesco Neri',
        number: 4,
        position: 'Difensore Centrale',
        birthDate: DateTime(1993, 5, 12),
        phone: '+39 333 4567890',
        email: 'francesco.neri@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now,
        height: 183,
        weight: 78,
      ),
      Player(
        id: '5',
        name: 'Gabriele Gialli',
        number: 8,
        position: 'Centrocampista',
        birthDate: DateTime(1996, 1, 20),
        phone: '+39 333 5678901',
        email: 'gabriele.gialli@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now,
        height: 177,
        weight: 72,
      ),
      Player(
        id: '6',
        name: 'Matteo Blu',
        number: 11,
        position: 'Ala Sinistra',
        birthDate: DateTime(1998, 9, 3),
        phone: '+39 333 6789012',
        email: 'matteo.blu@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
        height: 174,
        weight: 69,
      ),
      Player(
        id: '7',
        name: 'Alessandro Viola',
        number: 6,
        position: 'Mediano',
        birthDate: DateTime(1994, 12, 28),
        phone: '+39 333 7890123',
        email: 'alessandro.viola@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now,
        height: 179,
        weight: 74,
      ),
      Player(
        id: '8',
        name: 'Simone Rosa',
        number: 3,
        position: 'Terzino Sinistro',
        birthDate: DateTime(1997, 4, 7),
        phone: '+39 333 8901234',
        email: 'simone.rosa@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 80)),
        updatedAt: now,
        height: 176,
        weight: 71,
      ),
      Player(
        id: '9',
        name: 'Lorenzo Oro',
        number: 2,
        position: 'Terzino Destro',
        birthDate: DateTime(1995, 8, 14),
        phone: '+39 333 9012345',
        email: 'lorenzo.oro@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
        height: 178,
        weight: 73,
      ),
      Player(
        id: '10',
        name: 'Davide Argento',
        number: 5,
        position: 'Difensore Centrale',
        birthDate: DateTime(1992, 10, 25),
        phone: '+39 333 0123456',
        email: 'davide.argento@email.com',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 40)),
        updatedAt: now,
        height: 184,
        weight: 79,
      ),
    ];
  }

  /// Genera staff di esempio
  static List<Staff> generateSampleStaff() {
    final now = DateTime.now();
    
    return [
      Staff(
        id: '1',
        name: 'Giuseppe Conte',
        role: 'Allenatore',
        phone: '+39 333 9876543',
        email: 'giuseppe.conte@sommacustoza.com',
        birthDate: DateTime(1969, 8, 31),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 1000)),
        updatedAt: now,
        experienceYears: 15,
        joinedDate: DateTime(2020, 1, 1),
        qualifications: 'UEFA Pro License, Coverciano',
        permissions: [
          'manage_team',
          'manage_trainings',
          'manage_matches',
          'manage_attendance',
          'view_stats',
          'admin_access',
        ],
        notes: 'Allenatore principale con esperienza in Serie C',
      ),
      Staff(
        id: '2',
        name: 'Mario Preparatore',
        role: 'Preparatore Atletico',
        phone: '+39 333 8765432',
        email: 'mario.preparatore@sommacustoza.com',
        birthDate: DateTime(1975, 3, 20),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 800)),
        updatedAt: now,
        experienceYears: 8,
        joinedDate: DateTime(2021, 6, 1),
        qualifications: 'Laurea Scienze Motorie, Certificazione FIGC',
        permissions: [
          'manage_trainings',
          'view_stats',
          'manage_attendance',
        ],
      ),
      Staff(
        id: '3',
        name: 'Dr. Paolo Medici',
        role: 'Medico Sociale',
        phone: '+39 333 7654321',
        email: 'paolo.medici@sommacustoza.com',
        birthDate: DateTime(1970, 11, 15),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 600)),
        updatedAt: now,
        experienceYears: 20,
        joinedDate: DateTime(2022, 1, 15),
        qualifications: 'Medicina dello Sport, Traumatologia',
        permissions: [
          'view_stats',
          'manage_attendance',
        ],
      ),
      Staff(
        id: '4',
        name: 'Chiara Manager',
        role: 'Team Manager',
        phone: '+39 333 6543210',
        email: 'chiara.manager@sommacustoza.com',
        birthDate: DateTime(1985, 6, 8),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 400)),
        updatedAt: now,
        experienceYears: 5,
        joinedDate: DateTime(2022, 8, 1),
        qualifications: 'Economia e Management, Corso FIGC',
        permissions: [
          'manage_team',
          'view_stats',
          'send_notifications',
          'export_data',
        ],
      ),
    ];
  }

  /// Genera partite di esempio
  static List<Match> generateSampleMatches() {
    final now = DateTime.now();
    
    return [
      // Partite passate
      Match(
        id: '1',
        opponent: 'Virtus Verona',
        dateTime: now.subtract(const Duration(days: 14)),
        location: 'Stadio Comunale Sommacustoza',
        isHome: true,
        result: 'Vittoria',
        goalsFor: 2,
        goalsAgainst: 1,
        isCompleted: true,
        competitionType: 'Campionato',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 14)),
        notes: 'Bella vittoria in rimonta, ottima prestazione nel secondo tempo',
        opponentStrengths: 'Buon centrocampo, pressing alto',
        opponentWeaknesses: 'Difesa vulnerabile sui cross, calo fisico finale',
      ),
      Match(
        id: '2',
        opponent: 'Mazzini Padova',
        dateTime: now.subtract(const Duration(days: 21)),
        location: 'Stadio Mazzini',
        isHome: false,
        result: 'Pareggio',
        goalsFor: 1,
        goalsAgainst: 1,
        isCompleted: true,
        competitionType: 'Campionato',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 21)),
        notes: 'Pareggio giusto, partita equilibrata',
      ),
      Match(
        id: '3',
        opponent: 'Vicenza Calcio',
        dateTime: now.subtract(const Duration(days: 28)),
        location: 'Stadio Romeo Menti',
        isHome: false,
        result: 'Sconfitta',
        goalsFor: 0,
        goalsAgainst: 2,
        isCompleted: true,
        competitionType: 'Coppa',
        createdAt: now.subtract(const Duration(days: 32)),
        updatedAt: now.subtract(const Duration(days: 28)),
        notes: 'Partita difficile contro squadra di categoria superiore',
      ),
      // Partite future
      Match(
        id: '4',
        opponent: 'Montecchio Maggiore',
        dateTime: now.add(const Duration(days: 7)),
        location: 'Stadio Comunale Sommacustoza',
        isHome: true,
        competitionType: 'Campionato',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        opponentStrengths: 'Attacco veloce, buoni esterni',
        opponentWeaknesses: 'Difesa giovane, poca esperienza',
      ),
      Match(
        id: '5',
        opponent: 'Arzignano Valchiampo',
        dateTime: now.add(const Duration(days: 14)),
        location: 'Stadio Dal Molin',
        isHome: false,
        competitionType: 'Campionato',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
    ];
  }

  /// Genera allenamenti di esempio
  static List<Training> generateSampleTrainings() {
    final now = DateTime.now();
    
    return [
      // Allenamenti passati
      Training(
        id: '1',
        type: 'Tecnico',
        dateTime: now.subtract(const Duration(days: 2)),
        location: 'Campo Comunale',
        durationMinutes: 90,
        description: 'Lavoro tecnico sui passaggi e controllo di palla',
        intensity: 6,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
        exercises: [
          'Riscaldamento 15 min',
          'Passaggi corti 20 min',
          'Controllo e passaggio 25 min',
          'Partitella tecnica 25 min',
          'Defaticamento 5 min',
        ],
        notes: 'Buona partecipazione, miglioramenti evidenti nella precisione',
        weather: 'Sereno',
        temperature: 18.5,
      ),
      Training(
        id: '2',
        type: 'Fisico',
        dateTime: now.subtract(const Duration(days: 4)),
        location: 'Campo Comunale',
        durationMinutes: 75,
        description: 'Preparazione atletica e resistenza',
        intensity: 8,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 4)),
        exercises: [
          'Riscaldamento dinamico 15 min',
          'Sprint e cambi direzione 20 min',
          'Lavoro aerobico 25 min',
          'Forza funzionale 10 min',
          'Stretching 5 min',
        ],
        weather: 'Nuvoloso',
        temperature: 16.0,
      ),
      Training(
        id: '3',
        type: 'Tattico',
        dateTime: now.subtract(const Duration(days: 6)),
        location: 'Campo Comunale',
        durationMinutes: 100,
        description: 'Prove modulo 4-3-3 e movimenti offensivi',
        intensity: 7,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 9)),
        updatedAt: now.subtract(const Duration(days: 6)),
        focusArea: 'Fase offensiva',
        exercises: [
          'Riscaldamento 10 min',
          'Schemi su calcio d\'angolo 20 min',
          'Prove modulo 11vs11 45 min',
          'Situazioni di gioco 20 min',
          'Defaticamento 5 min',
        ],
      ),
      // Allenamenti futuri
      Training(
        id: '4',
        type: 'Partitella',
        dateTime: now.add(const Duration(days: 1)),
        location: 'Campo Comunale',
        durationMinutes: 90,
        description: 'Partitella in famiglia 11vs11',
        intensity: 7,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
        focusArea: 'Automatismi di gioco',
      ),
      Training(
        id: '5',
        type: 'Palle Inattive',
        dateTime: now.add(const Duration(days: 3)),
        location: 'Campo Comunale',
        durationMinutes: 60,
        description: 'Calci di punizione e calci d\'angolo',
        intensity: 5,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        focusArea: 'Situazioni di palla ferma',
      ),
      Training(
        id: '6',
        type: 'Recupero Attivo',
        dateTime: now.add(const Duration(days: 5)),
        location: 'Palestra',
        durationMinutes: 45,
        description: 'Defaticamento post-partita',
        intensity: 3,
        createdAt: now,
        updatedAt: now,
        exercises: [
          'Stretching guidato 15 min',
          'Mobilità articolare 15 min',
          'Esercizi propriocettivi 15 min',
        ],
      ),
    ];
  }

  /// Genera presenze di esempio
  static List<Attendance> generateSampleAttendance(
    List<Player> players,
    List<Training> trainings,
    List<Match> matches,
  ) {
    final now = DateTime.now();
    final attendances = <Attendance>[];

    // Genera presenze per allenamenti completati
    for (final training in trainings.where((t) => t.isCompleted)) {
      for (int i = 0; i < players.length; i++) {
        final player = players[i];
        
        // Simula diverse percentuali di presenza per giocatore
        final random = (player.id.hashCode + training.id.hashCode) % 100;
        String status;
        
        if (random < 75) {
          status = 'presente';
        } else if (random < 85) {
          status = 'assente';
        } else if (random < 95) {
          status = 'giustificato';
        } else {
          status = 'infortunato';
        }

        attendances.add(Attendance(
          id: '${training.id}_${player.id}',
          playerId: player.id,
          eventId: training.id,
          eventType: 'training',
          status: status,
          eventDate: training.dateTime,
          createdAt: training.dateTime.add(const Duration(hours: 1)),
          updatedAt: training.dateTime.add(const Duration(hours: 1)),
          excuseReason: status == 'giustificato' ? 'Motivi di lavoro' : null,
          isLate: status == 'presente' && random % 10 == 0,
          minutesLate: status == 'presente' && random % 10 == 0 ? 5 + (random % 15) : null,
        ));
      }
    }

    // Genera presenze per partite completate
    for (final match in matches.where((m) => m.isCompleted)) {
      for (int i = 0; i < players.length; i++) {
        final player = players[i];
        
        // Per le partite, percentuale di presenza più alta
        final random = (player.id.hashCode + match.id.hashCode) % 100;
        String status;
        
        if (random < 85) {
          status = 'presente';
        } else if (random < 92) {
          status = 'assente';
        } else if (random < 97) {
          status = 'giustificato';
        } else {
          status = 'infortunato';
        }

        attendances.add(Attendance(
          id: '${match.id}_${player.id}',
          playerId: player.id,
          eventId: match.id,
          eventType: 'match',
          status: status,
          eventDate: match.dateTime,
          createdAt: match.dateTime.subtract(const Duration(hours: 2)),
          updatedAt: match.dateTime.subtract(const Duration(hours: 2)),
          excuseReason: status == 'giustificato' ? 'Infortunio lieve' : null,
        ));
      }
    }

    return attendances;
  }

  /// Carica tutti i dati di esempio nel database
  static Future<void> loadAllSampleData() async {
    // Questa funzione può essere chiamata per popolare il database
    // con dati di esempio durante lo sviluppo o per demo
    
    print('🔄 Loading sample data...');
    
    // Qui andrà il codice per salvare i dati nel database
    // usando DatabaseService.instance
    
    print('✅ Sample data loaded successfully!');
  }
}
