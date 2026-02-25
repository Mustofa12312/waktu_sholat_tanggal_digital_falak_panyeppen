import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions.dart';
// import '../../../../domain/entities/prayer_time.dart';

class PrayerCard extends StatelessWidget {
  final String name;
  final String arabicName;
  final DateTime time;
  final bool isNext;
  final bool isCurrent;

  const PrayerCard({
    super.key,
    required this.name,
    required this.arabicName,
    required this.time,
    this.isNext = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = isNext || isCurrent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isHighlighted
            ? AppColors.accent.withOpacity(0.15)
            : AppColors.glassWhite,
        border: Border.all(
          color: isHighlighted ? AppColors.accent : AppColors.glassBorder,
          width: isHighlighted ? 1.5 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? AppColors.success
                  : isNext
                      ? AppColors.accent
                      : AppColors.textMuted,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Prayer name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.prayerName.copyWith(
                    color: isHighlighted
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                Text(
                  arabicName,
                  style: AppTypography.bodySmall.copyWith(
                    color: isHighlighted
                        ? AppColors.accent.withOpacity(0.7)
                        : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time.toTimeString(),
                style: AppTypography.prayerTime.copyWith(
                  fontSize: 18,
                  color:
                      isHighlighted ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
              if (isNext)
                Text(
                  'Berikutnya',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              if (isCurrent)
                Text(
                  'Saat ini',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success.withOpacity(0.9),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
