import 'package:hijri/hijri_calendar.dart';
void main() {
  var h = HijriCalendar.now();
  print('${h.hYear}-${h.hMonth}-${h.hDay}');
  print('length: ${h.lengthOfMonth}');
  print('weDay: ${h.dayWeName}');
  var g = h.hijriToGregorian(h.hYear, h.hMonth, 1);
  print('1st day weekday: ${g.weekday}');
}
