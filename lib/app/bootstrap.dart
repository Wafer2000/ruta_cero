import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../core/config/environment.dart';
import '../core/config/dev_http_overrides.dart';
import '../data/remote/supabase_service.dart';
import 'app.dart';

/// Inicializa la app con la configuración del ambiente dado
Future<void> bootstrap(EnvConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // En desarrollo: bypass SSL para firewalls corporativos
  if (config.isDev) {
    HttpOverrides.global = DevHttpOverrides();
  }

  // Locale para fechas
  await initializeDateFormatting('es_CO', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('pt_BR', null);

  // Orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Barra de estado
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0B1020),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Supabase
  await SupabaseService.initialize(config);

  if (config.enableLogging) {
    debugPrint('╔══════════════════════════════════════');
    debugPrint('║ Ruta Cero - ${config.environment.name.toUpperCase()}');
    debugPrint('║ Supabase: ${config.supabaseUrl.isNotEmpty ? "connected" : "offline"}');
    debugPrint('║ Auth: ${SupabaseService.isAuthenticated ? "logged in" : "anonymous"}');
    debugPrint('╚══════════════════════════════════════');
  }

  runApp(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWithValue(config),
      ],
      child: const RutaCeroApp(),
    ),
  );
}
