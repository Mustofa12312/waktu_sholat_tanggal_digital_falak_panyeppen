import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.cardDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Locale init for Indonesian dates
  await initializeDateFormatting('id', null);

  // Hive init
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(AppStrings.prayerSettingsBox);
  await Hive.openBox<dynamic>(AppStrings.locationBox);
  await Hive.openBox<dynamic>(AppStrings.prayerTimesBox);

  // DI
  await configureDependencies();

  // Notifications
  final notifService = getIt<NotificationService>();
  await notifService.initialize();

  // Refresh prayer times for tomorrow in background (microtask)
  final bgService = getIt<BackgroundService>();
  await bgService.scheduleMidnightRefresh();

  runApp(const AnNoorApp());
}

class AnNoorApp extends StatelessWidget {
  const AnNoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
    );
  }
}
