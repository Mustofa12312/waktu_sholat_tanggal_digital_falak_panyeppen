import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../../blocs/calendar/calendar_cubit.dart';
import '../../blocs/prayer/prayer_bloc.dart';
// import '../../blocs/prayer/prayer_event.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../widgets/dual_calendar_cell.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/prayer_time.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          children: [
            Text(AppStrings.calendar,
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(
              'Hijriah & Masehi',
              style: AppTypography.bodySmall.copyWith(color: AppColors.accent),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_calls_rounded, color: AppColors.accent),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<CalendarCubit>().toggleCalendarPrimary();
            },
            tooltip: 'Tukar Hijriah/Masehi',
          ),
          IconButton(
            icon:
                const Icon(Icons.today_rounded, color: AppColors.textSecondary),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<CalendarCubit>().goToToday();
            },
            tooltip: 'Hari Ini',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Table calendar
          BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, calState) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: calState.showHijriAsPrimary
                      ? _buildHijriCalendar(context, calState)
                      : _buildCalendar(context, calState),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Selected day info
          BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, calState) {
              return _DayInfoPanel(selectedDay: calState.selectedDay);
            },
          ),

          // Prayer times for selected day
          Expanded(
            child: BlocBuilder<PrayerBloc, PrayerState>(
              builder: (context, state) {
                if (state is PrayerLoaded) {
                  return _PrayerListForDay(prayerTime: state.prayerTime);
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, CalendarState calState) {
    final arabicMonths = [
      '', // 1-indexed
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
      'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    final arabicDays = [
      '',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];

    return Directionality(
      textDirection: calState.showHijriAsPrimary
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: TableCalendar(
        key: ValueKey(calState.focusedDay.month),
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: calState.focusedDay,
        locale: 'id',
        availableCalendarFormats: const {
          CalendarFormat.month: 'Bulan',
          CalendarFormat.twoWeeks: '2 Minggu',
          CalendarFormat.week: 'Minggu',
        },
        selectedDayPredicate: (day) => isSameDay(day, calState.selectedDay),
        calendarFormat: calState.format,
        onDaySelected: (selected, focused) {
          HapticFeedback.selectionClick();
          context.read<CalendarCubit>().selectDay(selected, focused);
        },
        onPageChanged: (focusedDay) {
          context.read<CalendarCubit>().changeFocusedDay(focusedDay);
        },
        onFormatChanged: (format) {
          context.read<CalendarCubit>().changeFormat(format);
        },
        calendarStyle: const CalendarStyle(
          defaultTextStyle: TextStyle(color: AppColors.textPrimary),
          weekendTextStyle: TextStyle(color: AppColors.textSecondary),
          outsideTextStyle: TextStyle(color: AppColors.textMuted),
          todayDecoration: BoxDecoration(shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(shape: BoxShape.circle),
          markerDecoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          formatButtonTextStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.accent.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textSecondary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.accent.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          headerTitleBuilder: (context, day) {
            if (calState.showHijriAsPrimary) {
              final hijri = HijriCalendar.fromDate(day);
              final hijriMonthName = arabicMonths[hijri.hMonth];
              return Text(
                '$hijriMonthName ${hijri.hYear}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return null; // fallback to default Gregorian
          },
          dowBuilder: (context, day) {
            if (calState.showHijriAsPrimary) {
              final text = arabicDays[day.weekday];
              return Center(
                child: Text(
                  text,
                  style: AppTypography.labelSmall.copyWith(
                    color: day.weekday == DateTime.sunday ||
                            day.weekday == DateTime.saturday
                        ? AppColors.accent.withOpacity(0.8)
                        : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return null; // fallback
          },
          defaultBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isHijriPrimary: calState.showHijriAsPrimary,
          ),
          todayBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isToday: true,
            isHijriPrimary: calState.showHijriAsPrimary,
          ),
          selectedBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isSelected: true,
            isToday: isSameDay(day, DateTime.now()),
            isHijriPrimary: calState.showHijriAsPrimary,
          ),
          outsideBuilder: (ctx, day, focusedDay) => DualCalendarCell(
            date: day,
            isOutside: true,
            isHijriPrimary: calState.showHijriAsPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHijriCalendar(BuildContext context, CalendarState calState) {
    final focusHijri = HijriCalendar.fromDate(calState.focusedDay);
    final int lengthOfMonth = focusHijri.lengthOfMonth;
    final DateTime firstDayGregorian =
        focusHijri.hijriToGregorian(focusHijri.hYear, focusHijri.hMonth, 1);

    // Day 1 to 7 corresponding to Mon to Sun in Dart's DateTime.weekday
    final int emptySlots = firstDayGregorian.weekday - 1;
    final int totalSlots = emptySlots + lengthOfMonth;
    final int rowCount = (totalSlots / 7).ceil();

    final arabicMonths = [
      '', // 1-indexed
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
      'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    final arabicDays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ]; // Monday to Sunday

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CalendarCubit>().goToPreviousMonth();
                  },
                ),
                Text(
                  '${arabicMonths[focusHijri.hMonth]} ${focusHijri.hYear}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CalendarCubit>().goToNextMonth();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Days of week
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Center(
                    child: Text(
                      arabicDays[index],
                      style: AppTypography.labelSmall.copyWith(
                        color: (index == 5 || index == 6)
                            ? AppColors.accent.withOpacity(0.8)
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCount * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < emptySlots || index >= emptySlots + lengthOfMonth) {
                final offset = index - emptySlots;
                final date = firstDayGregorian.add(Duration(days: offset));
                return DualCalendarCell(
                  date: date,
                  isOutside: true,
                  isHijriPrimary: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<CalendarCubit>().selectDay(date, date);
                  },
                );
              } else {
                final offset = index - emptySlots;
                final date = firstDayGregorian.add(Duration(days: offset));
                return DualCalendarCell(
                  date: date,
                  isSelected: isSameDay(date, calState.selectedDay),
                  isToday: isSameDay(date, DateTime.now()),
                  isHijriPrimary: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context
                        .read<CalendarCubit>()
                        .selectDay(date, calState.focusedDay);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── Day Info Panel ───────────────────────────────────────────────────────────

class _DayInfoPanel extends StatelessWidget {
  final DateTime selectedDay;

  const _DayInfoPanel({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromDate(selectedDay);
    final gregorianStr = DateFormat(
      'EEEE, d MMMM yyyy',
      'id',
    ).format(selectedDay);
    final hijriStr =
        '${hijri.hDay} ${hijri.longMonthNameIndo} ${hijri.hYear} H';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hijriStr,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gregorianStr,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

// ─── Prayer List For Selected Day ─────────────────────────────────────────────

class _PrayerListForDay extends StatelessWidget {
  final PrayerTime prayerTime;

  const _PrayerListForDay({required this.prayerTime});

  @override
  Widget build(BuildContext context) {
    final prayers = [
      (Icons.brightness_3_rounded, AppStrings.imsak, prayerTime.imsak),
      (Icons.wb_twilight_rounded, AppStrings.fajr, prayerTime.fajr),
      (Icons.wb_sunny_outlined, AppStrings.sunrise, prayerTime.sunrise),
      (Icons.sunny, AppStrings.dhuhr, prayerTime.dhuhr),
      (Icons.light_mode_rounded, AppStrings.asr, prayerTime.asr),
      (Icons.nights_stay_rounded, AppStrings.maghrib, prayerTime.maghrib),
      (Icons.nightlight_round, AppStrings.isha, prayerTime.isha),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: prayers.length,
      itemBuilder: (context, i) {
        final p = prayers[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(p.$1, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  p.$2,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Text(
                p.$3.toTimeString(),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 50 * i)).fadeIn().slideX(
            begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
      },
    );
  }
}
