/// Constantes globales de Ruta Cero
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Ruta Cero';
  static const String appVersion = '1.0.0';

  // Typography
  static const String fontPrimary = 'Sora';
  static const String fontSecondary = 'Inter';

  // Locale & Currency
  static const String locale = 'es_CO';
  static const String currency = 'COP';
  static const String currencySymbol = '\$';
  static const String currencyPrefix = '\$ ';
  static const String timezone = 'America/Bogota';
  static const String defaultHintAmount = '0';

  // Financial defaults
  static const int defaultReserveAmount = 500000;
  static const int defaultMonthlyIncome = 6400000;
  static const int maxProjectionMonths = 60;
  static const int minPasswordLength = 6;

  // UI
  static const int maxBottomNavItems = 5;
  static const double cardBorderRadius = 24.0;
  static const double cardSecondaryBorderRadius = 18.0;
  static const double buttonBorderRadius = 18.0;
  static const double inputBorderRadius = 16.0;
  static const double bottomSheetBorderRadius = 28.0;
  static const double screenHorizontalPadding = 20.0;
  static const double sectionSpacing = 24.0;
  static const double cardSpacing = 14.0;
  static const double cardInternalPadding = 20.0;

  // Animation durations
  static const Duration microInteraction = Duration(milliseconds: 250);
  static const Duration celebration = Duration(milliseconds: 700);

  // Logo
  static const String logoCharacter = '0';
  static const double logoSize = 80.0;
  static const double logoBorderRadius = 20.0;
  static const double logoFontSize = 40.0;
}
