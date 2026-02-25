import '../domain/entities/prayer_time.dart';
import 'notification_service.dart';

/// Schedules prayer notifications using flutter_local_notifications.
/// android_alarm_manager_plus dihapus karena tidak kompatibel dengan Flutter v2 embedding.
class AlarmService {
  final NotificationService _notificationService;

  static const int _fajrAlarmId = 200;
  static const int _dhuhrAlarmId = 202;
  static const int _asrAlarmId = 203;
  static const int _maghribAlarmId = 204;
  static const int _ishaAlarmId = 205;

  AlarmService(this._notificationService);

  Future<void> schedulePrayerAlarms(PrayerTime prayerTime) async {
    await cancelAllAlarms();

    final prayers = {
      _fajrAlarmId: (prayerTime.fajr, 'Subuh'),
      _dhuhrAlarmId: (prayerTime.dhuhr, 'Zuhur'),
      _asrAlarmId: (prayerTime.asr, 'Ashar'),
      _maghribAlarmId: (prayerTime.maghrib, 'Maghrib'),
      _ishaAlarmId: (prayerTime.isha, 'Isya'),
    };

    for (final entry in prayers.entries) {
      final time = entry.value.$1;
      final name = entry.value.$2;
      if (time.isAfter(DateTime.now())) {
        // Delegate to NotificationService for scheduling
        await _notificationService.scheduleSinglePrayerNotification(
          id: entry.key,
          name: name,
          time: time,
        );
      }
    }
  }

  Future<void> cancelAllAlarms() async {
    for (final id in [
      _fajrAlarmId,
      _dhuhrAlarmId,
      _asrAlarmId,
      _maghribAlarmId,
      _ishaAlarmId,
    ]) {
      await _notificationService.cancelNotification(id);
    }
  }
}
