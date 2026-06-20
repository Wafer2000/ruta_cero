import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para manejar el idioma seleccionado
/// Soporta: es (español), en (inglés), pt (portugués)
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void setSpanish() => state = const Locale('es');
  void setEnglish() => state = const Locale('en');
  void setPortuguese() => state = const Locale('pt');
}

/// Idiomas soportados
const supportedLocales = [
  Locale('es'),
  Locale('en'),
  Locale('pt'),
];
