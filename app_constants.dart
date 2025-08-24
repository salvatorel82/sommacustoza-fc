class AppConstants {
  // App Info
  static const String appName = 'SOMMACUSTOZA08';
  static const String appVersion = '1.0.0';
  static const String teamName = 'SOMMACUSTOZA08';
  
  // Database
  static const String playersBox = 'players';
  static const String staffBox = 'staff';
  static const String matchesBox = 'matches';
  static const String trainingsBox = 'trainings';
  static const String eventsBox = 'events';
  static const String attendanceBox = 'attendance';
  static const String formationsBox = 'formations';
  static const String settingsBox = 'settings';
  
  // Notifications
  static const String trainingReminderChannel = 'training_reminder';
  static const String matchReminderChannel = 'match_reminder';
  static const String eventReminderChannel = 'event_reminder';
  
  // Player Positions
  static const List<String> positions = [
    'Portiere',
    'Difensore Centrale',
    'Terzino Destro',
    'Terzino Sinistro',
    'Mediano',
    'Centrocampista',
    'Trequartista',
    'Ala Destra',
    'Ala Sinistra',
    'Seconda Punta',
    'Centravanti',
  ];
  
  // Training Types
  static const List<String> trainingTypes = [
    'Tecnico',
    'Tattico',
    'Fisico',
    'Portieri',
    'Palle Inattive',
    'Partitella',
    'Resistenza',
    'Velocità',
    'Forza',
    'Recupero Attivo',
  ];
  
  // Match Results
  static const List<String> matchResults = [
    'Vittoria',
    'Pareggio',
    'Sconfitta',
  ];
  
  // Staff Roles
  static const List<String> staffRoles = [
    'Allenatore',
    'Assistente Allenatore',
    'Preparatore Fisico',
    'Preparatore Portieri',
    'Team Manager',
    'Fisioterapista',
    'Medico Sociale',
    'Dirigente',
  ];
  
  // Formation Types
  static const List<String> formations = [
    '4-4-2',
    '4-3-3',
    '3-5-2',
    '4-2-3-1',
    '3-4-3',
    '5-3-2',
    '4-5-1',
    '3-4-2-1',
  ];
  
  // Ratings
  static const double maxRating = 10.0;
  static const double minRating = 1.0;
  
  // Colors (hex strings for database storage)
  static const String primaryColorHex = '#1976D2';
  static const String secondaryColorHex = '#FF9800';
  static const String successColorHex = '#4CAF50';
  static const String errorColorHex = '#F44336';
  static const String warningColorHex = '#FF9800';
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // API Endpoints (for future backend integration)
  static const String baseUrl = 'https://api.sommacustoza.com';
  static const String playersEndpoint = '/players';
  static const String matchesEndpoint = '/matches';
  static const String trainingsEndpoint = '/trainings';
}

class StaffPermissions {
  // Permission constants
  static const String manageTeam = 'manage_team';
  static const String manageTrainings = 'manage_trainings';
  static const String manageMatches = 'manage_matches';
  static const String viewStats = 'view_stats';
  static const String manageAttendance = 'manage_attendance';
  static const String sendNotifications = 'send_notifications';
  static const String exportData = 'export_data';
  static const String viewFinancials = 'view_financials';
  static const String manageFormations = 'manage_formations';
  static const String manageSettings = 'manage_settings';
  
  // All permissions list
  static const List<String> allPermissions = [
    manageTeam,
    manageTrainings,
    manageMatches,
    viewStats,
    manageAttendance,
    sendNotifications,
    exportData,
    viewFinancials,
    manageFormations,
    manageSettings,
  ];
  
  // Permission descriptions
  static const Map<String, String> permissionDescriptions = {
    manageTeam: 'Gestione Squadra',
    manageTrainings: 'Gestione Allenamenti',
    manageMatches: 'Gestione Partite',
    viewStats: 'Visualizzazione Statistiche',
    manageAttendance: 'Gestione Presenze',
    sendNotifications: 'Invio Notifiche',
    exportData: 'Esportazione Dati',
    viewFinancials: 'Visualizzazione Finanze',
    manageFormations: 'Gestione Formazioni',
    manageSettings: 'Gestione Impostazioni',
  };
  
  // File Paths
  static const String documentsPath = '/documents';
  static const String imagesPath = '/images';
  static const String backupsPath = '/backups';
}

class AppStrings {
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String players = 'Giocatori';
  static const String calendar = 'Calendario';
  static const String matches = 'Partite';
  static const String statistics = 'Statistiche';
  static const String formations = 'Formazioni';
  static const String settings = 'Impostazioni';
  
  // Common
  static const String add = 'Aggiungi';
  static const String edit = 'Modifica';
  static const String delete = 'Elimina';
  static const String save = 'Salva';
  static const String cancel = 'Annulla';
  static const String confirm = 'Conferma';
  static const String yes = 'Sì';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String loading = 'Caricamento...';
  static const String error = 'Errore';
  static const String success = 'Successo';
  static const String warning = 'Attenzione';
  static const String info = 'Informazione';
  
  // Player Management
  static const String addPlayer = 'Aggiungi Giocatore';
  static const String editPlayer = 'Modifica Giocatore';
  static const String playerName = 'Nome Giocatore';
  static const String playerNumber = 'Numero Maglia';
  static const String playerPosition = 'Ruolo';
  static const String playerAge = 'Età';
  static const String playerPhone = 'Telefono';
  static const String playerEmail = 'Email';
  
  // Attendance
  static const String present = 'Presente';
  static const String absent = 'Assente';
  static const String excused = 'Giustificato';
  static const String injured = 'Infortunato';
  
  // Training
  static const String training = 'Allenamento';
  static const String trainingType = 'Tipo Allenamento';
  static const String trainingDate = 'Data Allenamento';
  static const String trainingTime = 'Orario';
  static const String trainingLocation = 'Luogo';
  static const String trainingNotes = 'Note';
  
  // Matches
  static const String match = 'Partita';
  static const String opponent = 'Avversario';
  static const String matchDate = 'Data Partita';
  static const String matchTime = 'Orario';
  static const String matchLocation = 'Campo';
  static const String homeTeam = 'Casa';
  static const String awayTeam = 'Trasferta';
  static const String result = 'Risultato';
  static const String goalFor = 'Gol Fatti';
  static const String goalAgainst = 'Gol Subiti';
  
  // Notifications
  static const String trainingReminder = 'Promemoria Allenamento';
  static const String matchReminder = 'Promemoria Partita';
  static const String eventReminder = 'Promemoria Evento';
}
