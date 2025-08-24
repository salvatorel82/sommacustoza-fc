import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Android initialization
    const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization
    const iosInitialization = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    await _createNotificationChannels();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  Future<void> _createNotificationChannels() async {
    // Training reminders channel
    const trainingChannel = AndroidNotificationChannel(
      AppConstants.trainingReminderChannel,
      'Promemoria Allenamenti',
      description: 'Notifiche per promemoria allenamenti',
      importance: Importance.high,
    );

    // Match reminders channel
    const matchChannel = AndroidNotificationChannel(
      AppConstants.matchReminderChannel,
      'Promemoria Partite',
      description: 'Notifiche per promemoria partite',
      importance: Importance.high,
    );

    // Event reminders channel
    const eventChannel = AndroidNotificationChannel(
      AppConstants.eventReminderChannel,
      'Promemoria Eventi',
      description: 'Notifiche per eventi speciali',
      importance: Importance.defaultImportance,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(trainingChannel);
        
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(matchChannel);
        
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(eventChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // TODO: Handle navigation based on payload
    }
  }

  /// Mostra una notifica immediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = AppConstants.trainingReminderChannel,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.trainingReminderChannel,
      'Promemoria Allenamenti',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Programma una notifica per una data specifica (semplificata)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Per ora mostriamo una notifica immediata
    // TODO: Implementare scheduling reale quando risolviamo timezone
    if (scheduledDate.isAfter(DateTime.now())) {
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  /// Promemoria allenamento
  Future<void> scheduleTrainingReminder({
    required String trainingId,
    required String trainingType,
    required DateTime trainingDate,
    required String location,
  }) async {
    final reminderTime = trainingDate.subtract(const Duration(hours: 1));
    
    await scheduleNotification(
      id: trainingId.hashCode,
      title: '🏃‍♂️ Allenamento tra 1 ora!',
      body: 'Allenamento $trainingType alle ${trainingDate.hour}:${trainingDate.minute.toString().padLeft(2, '0')} presso $location',
      scheduledDate: reminderTime,
      payload: 'training_$trainingId',
    );
  }

  /// Promemoria partita
  Future<void> scheduleMatchReminder({
    required String matchId,
    required String opponent,
    required DateTime matchDate,
    required String location,
    required bool isHome,
  }) async {
    final reminderTime = matchDate.subtract(const Duration(hours: 2));
    final venue = isHome ? 'in casa' : 'in trasferta';
    
    await scheduleNotification(
      id: matchId.hashCode,
      title: '⚽ Partita tra 2 ore!',
      body: 'Vs $opponent $venue alle ${matchDate.hour}:${matchDate.minute.toString().padLeft(2, '0')} presso $location',
      scheduledDate: reminderTime,
      payload: 'match_$matchId',
    );
  }

  /// Promemoria evento generico
  Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
    String? description,
  }) async {
    final reminderTime = eventDate.subtract(const Duration(minutes: 30));
    
    await scheduleNotification(
      id: eventId.hashCode,
      title: '📅 Evento in arrivo!',
      body: description ?? '$eventTitle alle ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}',
      scheduledDate: reminderTime,
      payload: 'event_$eventId',
    );
  }

  /// Promemoria multipli per evento importante
  Future<void> scheduleMultipleReminders({
    required String eventId,
    required String title,
    required DateTime eventDate,
    required String description,
    List<Duration> intervals = const [
      Duration(days: 1),
      Duration(hours: 2),
      Duration(minutes: 30),
    ],
  }) async {
    for (int i = 0; i < intervals.length; i++) {
      final reminderTime = eventDate.subtract(intervals[i]);
      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: eventId.hashCode + i,
          title: title,
          body: description,
          scheduledDate: reminderTime,
          payload: 'multi_${eventId}_$i',
        );
      }
    }
  }

  /// Notifica di attività completata
  Future<void> showCompletionNotification({
    required String activityType,
    required String details,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '✅ $activityType Completato!',
      body: details,
      payload: 'completion_notification',
    );
  }

  /// Cancella notifica specifica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancella tutte le notifiche
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Ottieni notifiche pendenti
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Controlla se le notifiche sono abilitate
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status == PermissionStatus.granted;
  }

  /// Cancella notifiche per un evento specifico
  Future<void> cancelEventNotifications(String eventId, String eventType) async {
    // Cancella notifiche base
    await cancelNotification(eventId.hashCode);
    
    // Cancella notifiche multiple se esistono
    for (int i = 0; i < 5; i++) {
      await cancelNotification(eventId.hashCode + i);
    }
  }

  /// Mostra notifica risultato partita
  Future<void> showMatchResultNotification({
    required String opponent,
    required String result,
    required int goalsFor,
    required int goalsAgainst,
  }) async {
    String title;
    String emoji;
    
    switch (result.toLowerCase()) {
      case 'vittoria':
        title = '🎉 Vittoria!';
        emoji = '⚽';
        break;
      case 'pareggio':
        title = '🤝 Pareggio';
        emoji = '⚖️';
        break;
      case 'sconfitta':
        title = '😔 Sconfitta';
        emoji = '💪';
        break;
      default:
        title = '📊 Risultato';
        emoji = '⚽';
    }
    
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: '$emoji Vs $opponent: $goalsFor-$goalsAgainst',
      payload: 'match_result',
    );
  }

  /// Richiedi permessi notifiche
  Future<bool> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status == PermissionStatus.granted;
  }
}
