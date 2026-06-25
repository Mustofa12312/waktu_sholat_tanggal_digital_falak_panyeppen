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

    BoxDecoration decoration;
    Color textColor = isOutside ? AppColors.textMuted : AppColors.textPrimary;
    Color hijriColor = isOutside
        ? AppColors.textMuted.withOpacity(0.5)
        : AppColors.textSecondary;

    if (isSelected) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      );
      textColor = AppColors.black;
      hijriColor = AppColors.black.withOpacity(0.7);
    } else if (isToday) {
      decoration = BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      );
      textColor = AppColors.accent;
      hijriColor = AppColors.accent.withOpacity(0.8);
    } else {
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      );
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(4),
        decoration: decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Primary date
            Text(
              primaryText,
              style: TextStyle(
                color: primaryColor,
                fontSize: isToday && !isSelected
                    ? (isHijriPrimary ? 22 : 18)
                    : (isHijriPrimary ? 20 : 16),
                fontWeight:
                    isToday || isSelected ? FontWeight.w800 : FontWeight.w600,
                height: 1.1,
              ),
            ),
            // Secondary date
            const SizedBox(height: 2),
            Text(
              secondaryText,
              style: AppTypography.labelSmall.copyWith(
                color: secondaryColor,
                fontSize: isToday && !isSelected
                    ? (isHijriPrimary ? 12 : 14)
                    : (isHijriPrimary ? 11 : 13),
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
