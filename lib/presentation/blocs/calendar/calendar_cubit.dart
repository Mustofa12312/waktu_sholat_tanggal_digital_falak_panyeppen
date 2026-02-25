//
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarState {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat format;
  final Map<DateTime, List<dynamic>> events;

  const CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    this.format = CalendarFormat.month,
    this.events = const {},
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    CalendarFormat? format,
    Map<DateTime, List<dynamic>>? events,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      format: format ?? this.format,
      events: events ?? this.events,
    );
  }
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit()
      : super(
          CalendarState(
              focusedDay: DateTime.now(), selectedDay: DateTime.now()),
        );

  void selectDay(DateTime day, DateTime focusedDay) {
    emit(state.copyWith(selectedDay: day, focusedDay: focusedDay));
  }

  void changeFocusedDay(DateTime day) {
    emit(state.copyWith(focusedDay: day));
  }

  void changeFormat(CalendarFormat format) {
    emit(state.copyWith(format: format));
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(focusedDay: now, selectedDay: now));
  }

  void goToPreviousMonth() {
    final prev = DateTime(state.focusedDay.year, state.focusedDay.month - 1, 1);
    emit(state.copyWith(focusedDay: prev));
  }

  void goToNextMonth() {
    final next = DateTime(state.focusedDay.year, state.focusedDay.month + 1, 1);
    emit(state.copyWith(focusedDay: next));
  }
}
