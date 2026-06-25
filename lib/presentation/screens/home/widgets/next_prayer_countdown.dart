import 'dart:ui';
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
          const SizedBox(height: 16),

          // Glowing capsule countdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40), // Capsule shape
              color: AppColors.glassWhite,
              border: Border.all(
                color: AppColors.accent.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _CountdownDisplay(timeUntilNext: timeUntilNext),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
                duration: const Duration(seconds: 3),
                color: AppColors.accent.withOpacity(0.2),
              ),

          const SizedBox(height: 16),

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
    );
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
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DigitText(value: hours),
        _Separator(),
        _DigitText(value: mins),
        _Separator(),
        _DigitText(value: secs),
      ],
    );
  }
}

class _DigitText extends StatelessWidget {
  final String value;

  const _DigitText({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      key: ValueKey(value),
      style: AppTypography.countdown.copyWith(
        fontSize: 36,
        height: 1.0,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: AppTypography.countdown.copyWith(
          fontSize: 32,
          color: AppColors.accent,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
