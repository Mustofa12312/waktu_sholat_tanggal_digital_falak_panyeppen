import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import 'notification_service.dart';
import 'alarm_service.dart';
import '../data/sources/location_service.dart';
import '../data/sources/prayer_calculator.dart';
import '../data/sources/prayer_local_source.dart';
import 'package:workmanager/workmanager.dart';

/// Manages periodic prayer time refresh via WorkManager.
class BackgroundService {
  final NotificationService _notificationService;
  final AlarmService _alarmService;

  static const String refreshTaskName = "refreshPrayerTimesTask";

  BackgroundService(this._notificationService, this._alarmService);

  /// Initializes workmanager.
  void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Call on app start to schedule daily periodic refresh task.
  Future<void> scheduleMidnightRefresh() async {
    // Schedule a periodic task that runs every 24 hours
    // to calculate and schedule the next day's prayers.
    await Workmanager().registerPeriodicTask(
      "1",
      refreshTaskName,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    // Also run it immediately just to be safe
    _executeRefresh();
  }

  static Future<void> _executeRefresh() async {
    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentLocation();

      final localSource = PrayerLocalSource();
      final settings = localSource.loadSettings();

      final calculator = PrayerCalculator();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final times = calculator.calculate(location, tomorrow, settings);

      await localSource.cachePrayerTimes(times);
      
      final notifService = NotificationService();
      final alarmService = AlarmService(notifService);
      
      await notifService.schedulePrayerNotifications(times);
      await alarmService.schedulePrayerAlarms(times, settings);
    } catch (_) {
      // Silently fail — will retry on next schedule
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackgroundService.refreshTaskName) {
      // Run the static execute method
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      await Hive.openBox<dynamic>(AppStrings.prayerSettingsBox);
      await Hive.openBox<dynamic>(AppStrings.locationBox);
      await Hive.openBox<dynamic>(AppStrings.prayerTimesBox);

      final locationService = LocationService();
      final location = await locationService.getCurrentLocation();

      final localSource = PrayerLocalSource();
      final settings = localSource.loadSettings();

      final calculator = PrayerCalculator();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final times = calculator.calculate(location, tomorrow, settings);

      await localSource.cachePrayerTimes(times);
      
      final notifService = NotificationService();
      await notifService.initialize();
      final alarmService = AlarmService(notifService);
      
      await notifService.schedulePrayerNotifications(times);
      await alarmService.schedulePrayerAlarms(times, settings);
    }
    return Future.value(true);
  });
}
