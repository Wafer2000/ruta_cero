import 'package:intl/intl.dart';

/// Formateador de moneda COP
/// Usa pesos enteros (NO centavos, NO doubles)
/// Formato colombiano: puntos para miles, coma para decimales
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final _formatterWithDecimals = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formatea un valor entero en pesos a formato COP
  /// Ejemplo: 6400000 -> "$6.400.000"
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// Formatea con decimales (raro en COP pero disponible)
  /// Ejemplo: 3816048 -> "$3.816.048,00"
  static String formatWithDecimals(int amount) {
    return _formatterWithDecimals.format(amount);
  }

  /// Formato corto para valores grandes
  /// Ejemplo: 8308693 -> "$8.3M"
  static String formatShort(int amount) {
    if (amount.abs() >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return format(amount);
  }

  /// Formatea la diferencia con signo
  /// Ejemplo: 500000 -> "+$500.000", -200000 -> "-$200.000"
  static String formatDifference(int amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_formatter.format(amount)}';
  }

  /// Parsea un string con formato COP a entero
  /// Ejemplo: "$6.400.000" -> 6400000
  static int? parse(String text) {
    try {
      final cleaned = text
          .replaceAll('\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      return double.parse(cleaned).round();
    } catch (_) {
      return null;
    }
  }
}
