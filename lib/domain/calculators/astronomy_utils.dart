import 'dart:math' as math;

/// Utility class for astronomical and spherical trigonometry calculations.
class AstronomyUtils {
  /// Converts degrees to radians.
  static double degToRad(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Converts radians to degrees.
  static double radToDeg(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// Sine of an angle in degrees.
  static double sinD(double degrees) {
    return math.sin(degToRad(degrees));
  }

  /// Cosine of an angle in degrees.
  static double cosD(double degrees) {
    return math.cos(degToRad(degrees));
  }

  /// Tangent of an angle in degrees.
  static double tanD(double degrees) {
    return math.tan(degToRad(degrees));
  }

  /// Arcsine returning degrees.
  static double asinD(double value) {
    return radToDeg(math.asin(value));
  }

  /// Arccosine returning degrees.
  static double acosD(double value) {
    return radToDeg(math.acos(value));
  }

  /// Arctangent returning degrees.
  static double atanD(double value) {
    return radToDeg(math.atan(value));
  }

  /// Arctangent 2 returning degrees.
  static double atan2D(double y, double x) {
    return radToDeg(math.atan2(y, x));
  }

  /// Normalize an angle to be within [0, 360).
  static double normalizeAngle(double angle) {
    double a = angle % 360.0;
    if (a < 0) {
      a += 360.0;
    }
    return a;
  }

  /// Calculate Julian Day from Gregorian date (at 00:00 UT if hour is not specified).
  /// Formula based on Jean Meeus Astronomical Algorithms.
  static double calculateJulianDay(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;
    double hour = date.hour + date.minute / 60.0 + date.second / 3600.0;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final int A = (year / 100).floor();
    final int B = 2 - A + (A / 4).floor();

    double jd = (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() +
        day +
        B -
        1524.5;
        
    jd += hour / 24.0;
    return jd;
  }
}
