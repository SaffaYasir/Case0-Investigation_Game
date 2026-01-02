import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'case_zero_channel',
      'Case Zero Updates',
      importance: Importance.high,
      description: 'Notifications for game updates and reminders',
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
    print('NotificationService initialized');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'case_zero_channel',
      'Case Zero Updates',
      channelDescription: 'Game notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, platformDetails,
        payload: payload);
  }

  Future<void> showCaseUpdateNotification({
    required int caseNumber,
    required String message,
  }) async {
    await showNotification(
      title: 'Case #$caseNumber Update',
      body: message,
      payload: 'case_$caseNumber',
    );
  }

  Future<void> showDailyReminder() async {
    await showNotification(
      title: 'Case Zero Detective',
      body: 'New clues await your investigation!',
      payload: 'daily_reminder',
    );
  }

  Future<void> showAchievementNotification(String achievement) async {
    await showNotification(
      title: 'Achievement Unlocked!',
      body: 'You earned: $achievement',
      payload: 'achievement',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}