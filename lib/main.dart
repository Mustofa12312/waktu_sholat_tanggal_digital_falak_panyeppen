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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/blocs/calendar/calendar_cubit.dart';
import 'presentation/blocs/prayer/prayer_bloc.dart';
import 'presentation/blocs/prayer/prayer_event.dart';
import 'presentation/blocs/settings/settings_cubit.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'domain/entities/prayer_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<PrayerBloc>(
          create: (_) => getIt<PrayerBloc>()..add(const LoadPrayerTimes()),
        ),
        BlocProvider<CalendarCubit>(create: (_) => getIt<CalendarCubit>()),
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => getIt<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, PrayerSettings>(
        builder: (context, settings) {
          // Automatic theme switching based on time logic
          bool currentDarkState = settings.isDarkMode;
          if (settings.autoThemeEnabled) {
            final now = DateTime.now();
            final isNight = now.hour < 5 || now.hour >= 18;
            currentDarkState = isNight;
          }
          ThemeConfig.isDark = currentDarkState;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  currentDarkState ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: AppColors.surface,
              systemNavigationBarIconBrightness:
                  currentDarkState ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
