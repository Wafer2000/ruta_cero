import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Helper para nombres de mes localizados
class MonthNames {
  MonthNames._();

  /// Retorna nombre completo: "Enero", "February", "Junho"
  static String full(S l, int month) {
    switch (month) {
      case 1: return l.monthJan;
      case 2: return l.monthFeb;
      case 3: return l.monthMar;
      case 4: return l.monthApr;
      case 5: return l.monthMay;
      case 6: return l.monthJun;
      case 7: return l.monthJul;
      case 8: return l.monthAug;
      case 9: return l.monthSep;
      case 10: return l.monthOct;
      case 11: return l.monthNov;
      case 12: return l.monthDec;
      default: return '';
    }
  }

  /// Retorna nombre corto: "Ene", "Feb", "Jun"
  static String short(S l, int month) {
    switch (month) {
      case 1: return l.monthShortJan;
      case 2: return l.monthShortFeb;
      case 3: return l.monthShortMar;
      case 4: return l.monthShortApr;
      case 5: return l.monthShortMay;
      case 6: return l.monthShortJun;
      case 7: return l.monthShortJul;
      case 8: return l.monthShortAug;
      case 9: return l.monthShortSep;
      case 10: return l.monthShortOct;
      case 11: return l.monthShortNov;
      case 12: return l.monthShortDec;
      default: return '';
    }
  }

  /// Formatea monthKey "2026-06" a "Junio 2026"
  static String formatFull(S l, String monthKey) {
    final parts = monthKey.split('-');
    final monthNum = int.parse(parts[1]);
    return '${full(l, monthNum)} ${parts[0]}';
  }

  /// Formatea monthKey "2026-06" a "Jun 2026"
  static String formatShort(S l, String monthKey) {
    final parts = monthKey.split('-');
    final monthNum = int.parse(parts[1]);
    return '${short(l, monthNum)} ${parts[0]}';
  }
}
