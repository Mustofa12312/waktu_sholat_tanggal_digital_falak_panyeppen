import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
// import '../../../../core/utils/extensions.dart';

class NextPrayerCountdown extends StatelessWidget {
  final String nextPrayerName;
  final Duration timeUntilNext;

  const NextPrayerCountdown({
    super.key,
    required this.nextPrayerName,
    required this.timeUntilNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.glassWhite,
        border: Border.all(color: AppColors.glassBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            'Menuju $nextPrayerName',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          // Countdown digits
          _CountdownDisplay(timeUntilNext: timeUntilNext),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Jam : Menit : Detik',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.95, 0.95), duration: 500.ms);
  }
}

class _CountdownDisplay extends StatelessWidget {
  final Duration timeUntilNext;

  const _CountdownDisplay({required this.timeUntilNext});

  @override
  Widget build(BuildContext context) {
    final hours = timeUntilNext.inHours.toString().padLeft(2, '0');
    final mins =
        timeUntilNext.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs =
        timeUntilNext.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DigitBox(value: hours),
        _Separator(),
        _DigitBox(value: mins),
        _Separator(),
        _DigitBox(value: secs),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  final String value;

  const _DigitBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.glassWhite,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            value,
            key: ValueKey(value),
            style: AppTypography.countdown.copyWith(fontSize: 32),
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: AppTypography.countdown.copyWith(
          fontSize: 28,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
