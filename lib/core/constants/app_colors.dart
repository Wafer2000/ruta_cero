import 'package:flutter/material.dart';

/// Paleta de colores definitiva de Ruta Cero
/// Basada en Sección 30.2 del documento de diseño
class AppColors {
  AppColors._();

  // === DARK MODE (Principal) ===

  /// Fondo principal premium - nunca usar negro puro
  static const Color backgroundDark = Color(0xFF070A13);

  /// Tarjetas, bottom navigation, contenedores y superficies elevadas
  static const Color surfaceDark = Color(0xFF0B1020);

  /// Violeta eléctrico - Color principal de marca, botones, CTA
  static const Color primary = Color(0xFF7C3AED);

  /// Cian neón - Líneas de ruta, progreso, gráficos, iconos activos
  static const Color secondary = Color(0xFF22D3EE);

  /// Verde menta - Pagos completados, deuda reducida, éxito
  static const Color success = Color(0xFF2EE6A6);

  /// Ámbar suave - Mes ajustado, pago próximo, advertencia
  static const Color warning = Color(0xFFFBBF24);

  /// Rojo coral - Pago vencido, sobregiro, riesgo alto
  static const Color danger = Color(0xFFFF5A7A);

  /// Texto principal sobre fondos oscuros
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Subtítulos, descripciones, labels y textos auxiliares
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Fondo alternativo modo claro, secciones suaves
  static const Color surfaceLight = Color(0xFFF4F0FF);

  // === LIGHT MODE ===
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLightCard = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // === SEMÁFORO MENSUAL ===
  static const Color monthGreen = success;
  static const Color monthYellow = warning;
  static const Color monthRed = danger;
  static const Color monthBlue = secondary; // Ingreso extra
  static const Color monthPurple = primary; // Evento especial

  // === GRADIENTES ===
  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFF22D3EE),
    Color(0xFF2EE6A6),
  ];

  static const List<Color> riskGradient = [
    Color(0xFFFBBF24),
    Color(0xFFFF5A7A),
  ];

  // === OPACIDADES ===
  static Color cardBorder = const Color(0xFF94A3B8).withOpacity(0.12);
  static Color glowCyan = secondary.withOpacity(0.20);
  static Color glowViolet = primary.withOpacity(0.18);
}
