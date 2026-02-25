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
  final bool isHijriPrimary;
  final VoidCallback? onTap;

  const DualCalendarCell({
    super.key,
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.isFocused = false,
    this.isOutside = false,
    this.isHijriPrimary = false,
    this.onTap,
  });

  String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

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

    // Determine primary and secondary texts
    final masehiText = '${date.day}';
    final hijriText = _toArabicDigits('${hijri.hDay}');

    final String primaryText = isHijriPrimary ? hijriText : masehiText;
    final String secondaryText = isHijriPrimary ? masehiText : hijriText;
    final Color primaryColor = isHijriPrimary ? hijriColor : textColor;
    final Color secondaryColor = isHijriPrimary ? textColor : hijriColor;

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
            // Primary date
            Text(
              primaryText,
              style: AppTypography.titleSmall.copyWith(
                color: primaryColor,
                fontWeight:
                    isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 1),
            // Secondary date
            Text(
              secondaryText,
              style: AppTypography.labelSmall.copyWith(
                color: secondaryColor,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
