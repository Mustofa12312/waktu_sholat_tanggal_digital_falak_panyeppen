import 'notification_service.dart';
import 'alarm_service.dart';
import '../data/sources/location_service.dart';
import '../data/sources/prayer_calculator.dart';
import '../data/sources/prayer_local_source.dart';

/// Manages periodic prayer time refresh.
/// Background scheduling is done via flutter_local_notifications only.
/// True background execution via WorkManager has been intentionally removed
/// for compatibility; refresh happens when app is opened.
class BackgroundService {
  final NotificationService _notificationService;
  final AlarmService _alarmService;

  BackgroundService(this._notificationService, this._alarmService);

  /// Call on app start to refresh prayer times for tomorrow if needed.
  Future<void> scheduleMidnightRefresh() async {
    // Perform refresh silently in background using compute/microtask
    Future.microtask(() async {
      try {
        final locationService = LocationService();
        final location = await locationService.getCurrentLocation();

        final localSource = PrayerLocalSource();
        final settings = localSource.loadSettings();

        final calculator = PrayerCalculator();
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final times = calculator.calculate(location, tomorrow, settings);

        await localSource.cachePrayerTimes(times);
        await _notificationService.schedulePrayerNotifications(times);
        await _alarmService.schedulePrayerAlarms(times, settings);
      } catch (_) {
        // Silently fail — will retry on next launch
      }
    });
  }
}
