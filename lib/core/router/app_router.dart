import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/calendar/calendar_cubit.dart';
import '../../presentation/blocs/prayer/prayer_bloc.dart';
import '../../presentation/blocs/prayer/prayer_event.dart';
import '../../presentation/blocs/settings/settings_cubit.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/qibla/qibla_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/di/injection.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/qibla',
            builder: (context, state) => const QiblaScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final Widget child;

  const _MainShell({required this.child});

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
      child: Builder(
        builder: (context) {
          final location = GoRouterState.of(context).uri.toString();
          int currentIndex = 0;
          if (location.startsWith('/calendar')) currentIndex = 1;
          if (location.startsWith('/qibla')) currentIndex = 2;
          if (location.startsWith('/settings')) currentIndex = 3;

          return Scaffold(
            body: child,
            bottomNavigationBar: _buildBottomNav(context, currentIndex),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: AppStrings.navHome,
                isActive: currentIndex == 0,
                onTap: () => context.go('/'),
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: AppStrings.navCalendar,
                isActive: currentIndex == 1,
                onTap: () => context.go('/calendar'),
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                label: AppStrings.navQibla,
                isActive: currentIndex == 2,
                onTap: () => context.go('/qibla'),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: AppStrings.navSettings,
                isActive: currentIndex == 3,
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive
              ? AppColors.accent.withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? AppColors.accent : AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.accent : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
