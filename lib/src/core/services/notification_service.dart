import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(
    AndroidInitializationSettings androidSettings,
    DarwinInitializationSettings iosSettings,
  ) async {
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required tz.TZDateTime Function(tz.TZDateTime now) scheduleBuilder,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = scheduleBuilder(now);
    if (scheduled.isBefore(now))
      scheduled = scheduled.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      'Wunder reminder',
      'Log your gaming session today',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wunder_daily',
          'Daily reminders',
          channelDescription: 'Daily reminder to log gaming session',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
