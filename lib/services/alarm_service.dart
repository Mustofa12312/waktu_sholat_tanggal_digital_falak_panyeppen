import '../domain/entities/prayer_time.dart';
import '../domain/entities/prayer_settings.dart';
import 'notification_service.dart';

/// Schedules prayer notifications using flutter_local_notifications.
/// android_alarm_manager_plus dihapus karena tidak kompatibel dengan Flutter v2 embedding.
class AlarmService {
  final NotificationService _notificationService;

  static const int _imsakAlarmId = 199;
  static const int _fajrAlarmId = 200;
  static const int _dhuhrAlarmId = 202;
  static const int _asrAlarmId = 203;
  static const int _maghribAlarmId = 204;
  static const int _ishaAlarmId = 205;

  AlarmService(this._notificationService);

  Future<void> schedulePrayerAlarms(
    PrayerTime prayerTime,
    PrayerSettings settings,
  ) async {
    await cancelAllAlarms();

    if (!settings.notificationsEnabled) return;

    final prayers = {
      _fajrAlarmId: (prayerTime.fajr, 'Subuh', settings.selectedAdhan),
      _dhuhrAlarmId: (prayerTime.dhuhr, 'Zuhur', settings.selectedAdhan),
      _asrAlarmId: (prayerTime.asr, 'Ashar', settings.selectedAdhan),
      _maghribAlarmId: (prayerTime.maghrib, 'Maghrib', settings.selectedAdhan),
      _ishaAlarmId: (prayerTime.isha, 'Isya', settings.selectedAdhan),
    };

    if (settings.imsakEnabled) {
      prayers[_imsakAlarmId] = (prayerTime.imsak, 'Imsak', 'imsak.mp3');
    }

    for (final entry in prayers.entries) {
      final time = entry.value.$1;
      final name = entry.value.$2;
      final audioFileName = entry.value.$3
          .split('/')
          .last; // extract "azan1.mp3" from "assets/audio/azan1.mp3"
      if (time.isAfter(DateTime.now())) {
        // Delegate to NotificationService for scheduling
        await _notificationService.scheduleSinglePrayerNotification(
          id: entry.key,
          name: name,
          time: time,
          soundFileName: audioFileName,
        );
      }
    }
  }

  Future<void> cancelAllAlarms() async {
    for (final id in [
      _imsakAlarmId,
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
