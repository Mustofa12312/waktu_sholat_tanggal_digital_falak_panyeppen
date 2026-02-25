import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/constants/app_strings.dart';
import '../domain/entities/prayer_time.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create high-priority channel
    const channel = AndroidNotificationChannel(
      AppStrings.notifChannelId,
      AppStrings.notifChannelName,
      description: AppStrings.notifChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Navigate to home screen — handled by app router
  }

  Future<void> schedulePrayerNotifications(PrayerTime prayerTime) async {
    await cancelAllPrayerNotifications();

    final prayers = {
      100: ('Subuh', prayerTime.fajr),
      102: ('Zuhur', prayerTime.dhuhr),
      103: ('Ashar', prayerTime.asr),
      104: ('Maghrib', prayerTime.maghrib),
      105: ('Isya', prayerTime.isha),
    };

    for (final entry in prayers.entries) {
      final id = entry.key;
      final name = entry.value.$1;
      final time = entry.value.$2;

      if (time.isAfter(DateTime.now())) {
        await _scheduleNotification(id, name, time);
      }
    }
  }

  Future<void> _scheduleNotification(
    int id,
    String prayerName,
    DateTime time,
  ) async {
    await _plugin.zonedSchedule(
      id,
      AppStrings.notifTitle,
      'Sudah masuk waktu $prayerName',
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppStrings.notifChannelId,
          AppStrings.notifChannelName,
          channelDescription: AppStrings.notifChannelDesc,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Waktu $prayerName',
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(
            'Sudah masuk waktu $prayerName. Segera kerjakan sholat.',
            summaryText: 'An-Noor',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllPrayerNotifications() async {
    for (final id in [100, 102, 103, 104, 105]) {
      await _plugin.cancel(id);
    }
  }

  /// Schedule a single prayer notification (used by AlarmService)
  Future<void> scheduleSinglePrayerNotification({
    required int id,
    required String name,
    required DateTime time,
  }) async {
    await _scheduleNotification(id, name, time);
  }

  /// Cancel a single notification by ID
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> showImmediateTestNotification() async {
    await _plugin.show(
      999,
      'Tes Notifikasi',
      'An-Noor berhasil mengirim notifikasi!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppStrings.notifChannelId,
          AppStrings.notifChannelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
