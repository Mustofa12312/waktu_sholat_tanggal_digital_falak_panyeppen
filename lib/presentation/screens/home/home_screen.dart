import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../../blocs/prayer/prayer_bloc.dart';
import '../../blocs/prayer/prayer_event.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../widgets/azan_lottie_indicator.dart';
import 'widgets/solar_gradient_bg.dart';
import 'widgets/next_prayer_countdown.dart';
import 'widgets/prayer_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<PrayerBloc>().state is! PrayerLoaded) {
      context.read<PrayerBloc>().add(const LoadPrayerTimes());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerBloc, PrayerState>(
      listener: (context, state) {
        if (state is PrayerLoaded) {
          context.read<ThemeCubit>().updateFromPrayerTime(state.prayerTime);
        }
      },
      child: BlocBuilder<ThemeCubit, List<Color>>(
        builder: (context, gradientColors) {
          return SolarGradientBg(
            colors: gradientColors,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              appBar: _buildAppBar(context),
              body: BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  if (state is PrayerLoading) {
                    return const _LoadingView();
                  }
                  if (state is PrayerError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () => context.read<PrayerBloc>().add(
                            const LoadPrayerTimes(),
                          ),
                    );
                  }
                  if (state is PrayerLoaded) {
                    return _LoadedView(state: state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final hijri = HijriCalendar.now();
    final hijriStr =
        '${hijri.hDay} ${hijri.longMonthNameIndo} ${hijri.hYear} H';

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        children: [
          Text(
            AppStrings.appName,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          Text(
            hijriStr,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.my_location_rounded, color: Colors.white70),
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Memperbarui lokasi GPS...',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white),
                ),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context
                .read<PrayerBloc>()
                .add(const LoadPrayerTimes(forceLocationRefresh: true));
          },
          tooltip: 'Perbarui Lokasi',
        ),
      ],
    );
  }
}

// ─── Loading State ────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Mencari lokasi & menghitung\nwaktu sholat...',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onRetry();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }
}

// ─── Loaded State ─────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  final PrayerLoaded state;

  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final prayers = [
      ('Imsak', 'الإمساك', state.prayerTime.imsak),
      (AppStrings.fajr, AppStrings.fajrArabic, state.prayerTime.fajr),
      (AppStrings.dhuhr, AppStrings.dhuhrArabic, state.prayerTime.dhuhr),
      (AppStrings.asr, AppStrings.asrArabic, state.prayerTime.asr),
      (AppStrings.maghrib, AppStrings.maghribArabic, state.prayerTime.maghrib),
      (AppStrings.isha, AppStrings.ishaArabic, state.prayerTime.isha),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location bar
            _LocationBar(
              city: state.location.city,
              date: state.date,
            ).animate().fadeIn(delay: 50.ms),

            const SizedBox(height: 20),

            // Azan indicator + next prayer name
            Center(
              child: AzanLottieIndicator(
                isActive: _isCurrentPrayer(state),
                prayerName: state.currentPrayerName,
              ),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 24),

            // Countdown
            NextPrayerCountdown(
              nextPrayerName: state.nextPrayerName,
              timeUntilNext: state.timeUntilNext,
            ),

            const SizedBox(height: 28),

            // Section title
            Text(
              AppStrings.todayPrayers,
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            // Prayer cards
            ...prayers.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              final isNext = p.$1 == state.nextPrayerName;
              final isCurrent =
                  p.$1 == state.currentPrayerName && _isCurrentPrayer(state);

              return PrayerCard(
                name: p.$1,
                arabicName: p.$2,
                time: p.$3,
                isNext: isNext,
                isCurrent: isCurrent,
              ).animate(delay: Duration(milliseconds: 100 * i));
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _isCurrentPrayer(PrayerLoaded state) {
    final now = DateTime.now();
    final t = state.prayerTime;
    if (now.isAfter(t.imsak) && now.isBefore(t.fajr)) return true;
    if (now.isAfter(t.fajr) && now.isBefore(t.sunrise)) return true;
    if (now.isAfter(t.dhuhr) && now.isBefore(t.asr)) return true;
    if (now.isAfter(t.asr) && now.isBefore(t.maghrib)) return true;
    if (now.isAfter(t.maghrib) && now.isBefore(t.isha)) return true;
    return false;
  }
}

// ─── Location Bar ─────────────────────────────────────────────────────────────

class _LocationBar extends StatelessWidget {
  final String city;
  final DateTime date;

  const _LocationBar({required this.city, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.glassWhite,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              city.isEmpty ? 'Jakarta, Indonesia' : city,
              style: AppTypography.labelMedium.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            DateFormat('EEE, d MMM', 'id').format(date),
            style: AppTypography.labelSmall.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
