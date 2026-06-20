import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
class AppTheme {
  AppTheme._();

  // ===== DARK THEME (Principal) =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: AppConstants.fontPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.danger,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.backgroundDark,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: AppConstants.fontPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          side: BorderSide(color: AppColors.cardBorder),
        ),
        margin: const EdgeInsets.symmetric(vertical: 7),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: AppConstants.fontPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: AppConstants.fontPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(
          fontFamily: AppConstants.fontSecondary,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppConstants.fontSecondary,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.bottomSheetBorderRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        labelStyle: const TextStyle(
          fontFamily: AppConstants.fontSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
      ),
      textTheme: _buildTextTheme(),
    );
  }

  // ===== LIGHT THEME =====
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: AppConstants.fontPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLightCard,
        error: AppColors.danger,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.backgroundDark,
        onSurface: AppColors.textPrimaryLight,
        onError: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceLightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      textTheme: _buildTextTheme(isDark: false),
    );
  }

  static TextTheme _buildTextTheme({bool isDark = true}) {
    final Color primaryColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final Color secondaryColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return TextTheme(
      // Título principal dashboard - Sora Bold 28-32px
      headlineLarge: TextStyle(
        fontFamily: AppConstants.fontPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.25,
      ),
      // Subtítulos de sección - Sora SemiBold 20-24px
      headlineMedium: TextStyle(
        fontFamily: AppConstants.fontPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),
      // Títulos de tarjeta - Sora SemiBold 18px
      headlineSmall: TextStyle(
        fontFamily: AppConstants.fontPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.35,
      ),
      // Valores grandes de dinero - Sora Bold 34px
      displayLarge: TextStyle(
        fontFamily: AppConstants.fontPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.15,
      ),
      // Valores secundarios de dinero - Inter SemiBold 18px
      displayMedium: TextStyle(
        fontFamily: AppConstants.fontSecondary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),
      // Texto normal - Inter Regular 15px
      bodyLarge: TextStyle(
        fontFamily: AppConstants.fontSecondary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      // Texto secundario - Inter Regular 14px
      bodyMedium: TextStyle(
        fontFamily: AppConstants.fontSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.5,
      ),
      // Labels / chips - Inter Medium 12px
      labelSmall: TextStyle(
        fontFamily: AppConstants.fontSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        height: 1.4,
      ),
      // Botones - Sora SemiBold 15px
      labelLarge: TextStyle(
        fontFamily: AppConstants.fontPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.45,
      ),
    );
  }
}
