import '../constants/app_constants.dart';

/// Ambientes de la aplicación
enum Environment { dev, staging, prod }

/// Configuración por ambiente
class EnvConfig {
  final Environment environment;
  final String appName;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool enableLogging;
  final bool enableCrashlytics;
  final bool showDebugBanner;

  const EnvConfig({
    required this.environment,
    required this.appName,
    this.supabaseUrl = '',
    this.supabaseAnonKey = '',
    this.enableLogging = false,
    this.enableCrashlytics = false,
    this.showDebugBanner = false,
  });

  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProd => environment == Environment.prod;

  static const dev = EnvConfig(
    environment: Environment.dev,
    appName: '${AppConstants.appName} DEV',
    supabaseUrl: 'https://srqlqnehioekfxcifkss.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNycWxxbmVoaW9la2Z4Y2lma3NzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5MjEzNzMsImV4cCI6MjA5NzQ5NzM3M30.GCR9HkFGEg89mFNscdh4J3uKgV0QwFhXaeeCpjSJDuo',
    enableLogging: true,
    enableCrashlytics: false,
    showDebugBanner: true,
  );

  static const staging = EnvConfig(
    environment: Environment.staging,
    appName: '${AppConstants.appName} STG',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableLogging: true,
    enableCrashlytics: true,
    showDebugBanner: false,
  );

  static const prod = EnvConfig(
    environment: Environment.prod,
    appName: AppConstants.appName,
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableLogging: false,
    enableCrashlytics: true,
    showDebugBanner: false,
  );
}
