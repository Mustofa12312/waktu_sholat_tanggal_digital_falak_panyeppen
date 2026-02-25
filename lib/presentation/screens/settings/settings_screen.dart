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
      appBar: AppBar(
        title: Text(AppStrings.settings, style: AppTypography.titleMedium),
      ),
      body: BlocBuilder<SettingsCubit, PrayerSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Calculation Method ──────────────────────────────────
              _SectionHeader(label: AppStrings.calculationMethod),
              _CalculationMethodCard(settings: settings),
              const SizedBox(height: 20),

              // ─── Prayer Adjustments ──────────────────────────────────
              _SectionHeader(label: AppStrings.prayerAdjustments),
              _AdjustmentCard(settings: settings),
              const SizedBox(height: 20),

              // ─── Notifications ───────────────────────────────────────
              _SectionHeader(label: AppStrings.notifications),
              _NotificationsCard(settings: settings),
              const SizedBox(height: 20),

              // ─── Azan Audio ──────────────────────────────────────────
              _SectionHeader(label: AppStrings.azanSound),
              _AudioCard(settings: settings),
              const SizedBox(height: 32),

              // Reset button
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showResetDialog(context);
                },
                icon: const Icon(Icons.restore_rounded, color: AppColors.error),
                label: Text(
                  'Reset ke Default',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text('Reset Pengaturan?', style: AppTypography.titleSmall),
        content: Text(
          'Semua pengaturan akan kembali ke default.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsCubit>().resetToDefaults();
              context.read<PrayerBloc>().add(const LoadPrayerTimes());
              Navigator.pop(ctx);
            },
            child: Text(
              'Reset',
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.accent,
          letterSpacing: 1.5,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── Calculation Method Card ──────────────────────────────────────────────────

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
    return _Card(
      child: Column(
        children: _methods.map((m) {
          final isSelected = settings.method == m.$1;
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<SettingsCubit>().setMethod(m.$1);
              context.read<PrayerBloc>().add(const LoadPrayerTimes());
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppColors.accent.withOpacity(0.15)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      m.$2,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

// ─── Adjustment Card ──────────────────────────────────────────────────────────

class _AdjustmentCard extends StatelessWidget {
  final PrayerSettings settings;
  const _AdjustmentCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _Card(
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
            onChanged: (v) => context.read<SettingsCubit>().setAsrAdjustment(v),
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
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05);
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: AppTypography.labelLarge),
          ),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: -30,
              max: 30,
              divisions: 60,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${value > 0 ? '+' : ''}$value m',
              style: AppTypography.labelMedium.copyWith(
                color: value != 0 ? AppColors.accent : AppColors.textMuted,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notifications Card ───────────────────────────────────────────────────────

class _NotificationsCard extends StatelessWidget {
  final PrayerSettings settings;
  const _NotificationsCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: SwitchListTile(
        title: Text(
          AppStrings.enableNotifications,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Notifikasi otomatis di setiap waktu sholat',
          style: AppTypography.bodySmall,
        ),
        value: settings.notificationsEnabled,
        onChanged: (v) {
          HapticFeedback.selectionClick();
          context.read<SettingsCubit>().toggleNotifications(v);
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05);
  }
}

// ─── Audio Card ───────────────────────────────────────────────────────────────

class _AudioCard extends StatelessWidget {
  final PrayerSettings settings;
  const _AudioCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Volume slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.volume_down_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: settings.azanVolume,
                    min: 0,
                    max: 1,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().setVolume(v),
                  ),
                ),
                const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Test button
          ListTile(
            leading: const Icon(
              Icons.play_circle_outline_rounded,
              color: AppColors.accent,
            ),
            title: Text(
              AppStrings.testAzan,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            onTap: () async {
              HapticFeedback.mediumImpact();
              final audio = getIt<AudioService>();
              await audio.playAzan();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Memutar azan...',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05);
  }
}

// ─── Card Container ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
