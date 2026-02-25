import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
// import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// A dual-date calendar cell showing both Gregorian and Hijri dates.
/// Used as a custom cell builder inside TableCalendar.
class DualCalendarCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isFocused;
  final bool isOutside;
  final VoidCallback? onTap;

  const DualCalendarCell({
    super.key,
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.isFocused = false,
    this.isOutside = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromDate(date);

    Color background = Colors.transparent;
    Color textColor = isOutside ? AppColors.textMuted : AppColors.textPrimary;
    Color hijriColor = isOutside
        ? AppColors.textMuted.withOpacity(0.5)
        : AppColors.textSecondary;

    if (isSelected) {
      background = AppColors.accent;
      textColor = AppColors.black;
      hijriColor = AppColors.black.withOpacity(0.6);
    } else if (isToday) {
      background = AppColors.primary.withOpacity(0.3);
      textColor = AppColors.accent;
      hijriColor = AppColors.accent.withOpacity(0.7);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.accent.withOpacity(0.6), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gregorian day
            Text(
              '${date.day}',
              style: AppTypography.titleSmall.copyWith(
                color: textColor,
                fontWeight:
                    isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 1),
            // Hijri day
            Text(
              '${hijri.hDay}',
              style: AppTypography.labelSmall.copyWith(
                color: hijriColor,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
