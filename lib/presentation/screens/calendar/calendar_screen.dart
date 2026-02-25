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
        title: Column(
          children: [
            Text(AppStrings.calendar, style: AppTypography.titleMedium),
            Text(
              'Hijriah & Masehi',
              style: AppTypography.bodySmall.copyWith(color: AppColors.accent),
            ),
          ],
        ),
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
                child: _buildCalendar(context, calState),
              );
            },
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Selected day info
          BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, calState) {
              return _DayInfoPanel(selectedDay: calState.selectedDay);
            },
          ),

          const Divider(color: AppColors.divider, height: 1),

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
    return TableCalendar(
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
        titleTextStyle: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        formatButtonTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.accent,
        ),
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(12),
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textMuted,
        ),
        weekendStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.accent.withOpacity(0.7),
        ),
      ),
      calendarBuilders: CalendarBuilders(
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.surfaceLight,
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gregorianStr,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hijriStr,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── Prayer List For Selected Day ─────────────────────────────────────────────

class _PrayerListForDay extends StatelessWidget {
  final PrayerTime prayerTime;

  const _PrayerListForDay({required this.prayerTime});

  @override
  Widget build(BuildContext context) {
    final prayers = [
      ('🌙', AppStrings.fajr, prayerTime.fajr),
      ('🌅', AppStrings.dhuhr, prayerTime.dhuhr),
      ('🌤', AppStrings.asr, prayerTime.asr),
      ('🌇', AppStrings.maghrib, prayerTime.maghrib),
      ('🌃', AppStrings.isha, prayerTime.isha),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: prayers.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.divider, height: 1),
      itemBuilder: (context, i) {
        final p = prayers[i];
        return ListTile(
          leading: Text(p.$1, style: const TextStyle(fontSize: 20)),
          title: Text(p.$2, style: AppTypography.titleSmall),
          trailing: Text(
            p.$3.toTimeString(),
            style: AppTypography.prayerTime.copyWith(fontSize: 16),
          ),
          dense: true,
        )
            .animate(delay: Duration(milliseconds: 60 * i))
            .fadeIn()
            .slideX(begin: 0.05, end: 0, duration: 300.ms);
      },
    );
  }
}
