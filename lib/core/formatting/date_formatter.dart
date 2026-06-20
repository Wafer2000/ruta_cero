import 'package:intl/intl.dart';

/// Formateador de fechas para Colombia
class DateFormatter {
  DateFormatter._();

  static final _monthYear = DateFormat('MMMM yyyy', 'es_CO');
  static final _dayMonth = DateFormat('d MMM', 'es_CO');
  static final _fullDate = DateFormat('d MMMM yyyy', 'es_CO');
  static final _shortDate = DateFormat('dd/MM/yyyy', 'es_CO');

  /// "junio 2026"
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// "20 jun"
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  /// "20 junio 2026"
  static String fullDate(DateTime date) => _fullDate.format(date);

  /// "20/06/2026"
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// Retorna el mes y año como identificador: "2026-06"
  static String monthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Crea DateTime del primer día del mes
  static DateTime firstOfMonth(int year, int month) {
    return DateTime(year, month, 1);
  }

  /// Calcula diferencia en meses entre dos fechas
  static int monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }
}
