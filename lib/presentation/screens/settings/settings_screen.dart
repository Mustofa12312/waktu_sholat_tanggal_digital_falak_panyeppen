import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/prayer/prayer_bloc.dart';
import '../../blocs/prayer/prayer_event.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/prayer_settings.dart';
import '../../../services/audio_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ─── Ambient Background Effects ─────────────────────────────────
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    duration: 4.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.08),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    duration: 5.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1)),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),
            ),
          ),

          // ─── Main Content ──────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    title: Text(
                      AppStrings.settings,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.1),
                  ),
                  iconTheme: const IconThemeData(color: AppColors.textPrimary),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<SettingsCubit, PrayerSettings>(
                    builder: (context, settings) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ─── Calculation Method ──────────────────────────────────
                            const _SectionHeader(
                              label: AppStrings.calculationMethod,
                              icon: Icons.explore_rounded,
                            ),
                            _CalculationMethodCard(settings: settings),
                            const SizedBox(height: 28),

                            // ─── Prayer Adjustments ──────────────────────────────────
                            const _SectionHeader(
                              label: AppStrings.prayerAdjustments,
                              icon: Icons.tune_rounded,
                            ),
                            _AdjustmentCard(settings: settings),
                            const SizedBox(height: 28),

                            // ─── Imsak Settings ──────────────────────────────────────
                            const _SectionHeader(
                              label: 'Imsak',
                              icon: Icons.wb_twilight_rounded,
                            ),
                            _ImsakCard(settings: settings),
                            const SizedBox(height: 28),

                            // ─── Notifications ───────────────────────────────────────
                            const _SectionHeader(
                              label: AppStrings.notifications,
                              icon: Icons.notifications_active_rounded,
                            ),
                            _NotificationsCard(settings: settings),
                            const SizedBox(height: 28),

                            // ─── Azan Audio ──────────────────────────────────────────
                            const _SectionHeader(
                              label: AppStrings.azanSound,
                              icon: Icons.volume_up_rounded,
                            ),
                            _AudioCard(settings: settings),
                            const SizedBox(height: 40),

                            // ─── Reset Button ────────────────────────────────────────
                            _ResetButton(
                                onTap: () => _showResetDialog(context)),
                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Reset Pengaturan?', style: AppTypography.titleLarge),
        content: Text(
          'Semua pengaturan akan kembali ke default. Anda yakin?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Batal',
              style: AppTypography.labelLarge,
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsCubit>().resetToDefaults();
              context.read<PrayerBloc>().add(const LoadPrayerTimes());
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Reset',
              style: AppTypography.labelLarge.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.accent,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.05);
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: child,
      ),
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.accent,
      activeTrackColor: AppColors.accent.withOpacity(0.4),
      inactiveThumbColor: AppColors.textSecondary,
      inactiveTrackColor: AppColors.divider.withOpacity(0.5),
    );
  }
}

class _CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _CustomSlider({
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.divider.withOpacity(0.5),
        trackHeight: 6,
        thumbColor: AppColors.white,
        overlayColor: AppColors.accent.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Settings Cards ──────────────────────────────────────────────────────────

class _CalculationMethodCard extends StatelessWidget {
  final PrayerSettings settings;
  const _CalculationMethodCard({required this.settings});

  static const _methods = [
    (PrayerCalculationMethod.kemenag, AppStrings.kemenag),
    (PrayerCalculationMethod.mwl, AppStrings.mwl),
    (PrayerCalculationMethod.isna, AppStrings.isna),
    (PrayerCalculationMethod.egypt, AppStrings.egypt),
    (PrayerCalculationMethod.makkah, AppStrings.makkah),
    (PrayerCalculationMethod.karachi, AppStrings.karachi),
    (PrayerCalculationMethod.singapore, 'Singapore (MUIS)'),
  ];

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        children: _methods.map((m) {
          final isSelected = settings.method == m.$1;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<SettingsCubit>().setMethod(m.$1);
                context.read<PrayerBloc>().add(const LoadPrayerTimes());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: isSelected
                    ? AppColors.accent.withOpacity(0.1)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.$2,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                        size: 24,
                      )
                          .animate()
                          .scale(duration: 200.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }
}

class _AdjustmentCard extends StatelessWidget {
  final PrayerSettings settings;
  const _AdjustmentCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _AdjustmentRow(
              label: AppStrings.fajr,
              value: settings.fajrAdjustment,
              onChanged: (v) =>
                  context.read<SettingsCubit>().setFajrAdjustment(v),
            ),
            _AdjustmentRow(
              label: AppStrings.dhuhr,
              value: settings.dhuhrAdjustment,
              onChanged: (v) =>
                  context.read<SettingsCubit>().setDhuhrAdjustment(v),
            ),
            _AdjustmentRow(
              label: AppStrings.asr,
              value: settings.asrAdjustment,
              onChanged: (v) =>
                  context.read<SettingsCubit>().setAsrAdjustment(v),
            ),
            _AdjustmentRow(
              label: AppStrings.maghrib,
              value: settings.maghribAdjustment,
              onChanged: (v) =>
                  context.read<SettingsCubit>().setMaghribAdjustment(v),
            ),
            _AdjustmentRow(
              label: AppStrings.isha,
              value: settings.ishaAdjustment,
              onChanged: (v) =>
                  context.read<SettingsCubit>().setIshaAdjustment(v),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1);
  }
}

class _AdjustmentRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _AdjustmentRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTypography.titleSmall),
          ),
          Expanded(
            child: _CustomSlider(
              value: value.toDouble(),
              min: -30,
              max: 30,
              divisions: 60,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 52,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: value != 0
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.divider.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${value > 0 ? '+' : ''}$value m',
                style: AppTypography.labelMedium.copyWith(
                  color:
                      value != 0 ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  final PrayerSettings settings;
  const _NotificationsCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.enableNotifications,
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Notifikasi otomatis di setiap waktu sholat',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              _CustomSwitch(
                value: settings.notificationsEnabled,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  context.read<SettingsCubit>().toggleNotifications(v);
                },
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

const _audioOptions = [
  ('assets/audio/azan1.mp3', 'Azan Makkah'),
  ('assets/audio/azan2.mp3', 'Azan Madinah'),
  ('assets/audio/azan3.mp3', 'Azan Al-Aqsa'),
  ('assets/audio/azan4.mp3', 'Azan Mesir'),
];

class _AudioCard extends StatelessWidget {
  final PrayerSettings settings;
  const _AudioCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._audioOptions.map((audio) {
            final isSelected = settings.selectedAdhan == audio.$1;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<SettingsCubit>().setSelectedAdhan(audio.$1);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            isSelected ? AppColors.accent : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        audio.$2,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Divider(color: AppColors.white.withOpacity(0.1), height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.volume_down_rounded,
                    color: AppColors.textSecondary, size: 24),
                Expanded(
                  child: _CustomSlider(
                    value: settings.azanVolume,
                    min: 0,
                    max: 1,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().setVolume(v),
                  ),
                ),
                const Icon(Icons.volume_up_rounded,
                    color: AppColors.accent, size: 24),
              ],
            ),
          ),
          Divider(color: AppColors.white.withOpacity(0.1), height: 1),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final audio = getIt<AudioService>();

                if (audio.isPlaying) {
                  await audio.stopAzan();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  return;
                }

                await audio.playAzan(assetPath: settings.selectedAdhan);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.music_note_rounded,
                            color: AppColors.accent),
                        const SizedBox(width: 12),
                        Text('Memutar azan...',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.white)),
                      ],
                    ),
                    backgroundColor: AppColors.surfaceLight,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.all(20),
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded,
                        color: AppColors.accent, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.testAzan,
                      style: AppTypography.titleMedium
                          .copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1);
  }
}

class _ImsakCard extends StatelessWidget {
  final PrayerSettings settings;
  const _ImsakCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peringatan Imsak',
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Notifikasi dan alarm 10 menit sebelum Subuh',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _CustomSwitch(
                    value: settings.imsakEnabled,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      context.read<SettingsCubit>().setImsakEnabled(v);
                      context.read<PrayerBloc>().add(const LoadPrayerTimes());
                    },
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            child: settings.imsakEnabled
                ? Column(
                    children: [
                      Divider(
                          height: 1, color: AppColors.white.withOpacity(0.1)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _AdjustmentRow(
                          label: 'Penyesuaian',
                          value: settings.imsakAdjustment,
                          onChanged: (v) {
                            context.read<SettingsCubit>().setImsakAdjustment(v);
                            context
                                .read<PrayerBloc>()
                                .add(const LoadPrayerTimes());
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ResetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        icon: const Icon(Icons.restore_rounded, color: AppColors.error),
        label: Text(
          'Reset ke Default',
          style: AppTypography.titleMedium.copyWith(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.error.withOpacity(0.05),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }
}
