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
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
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
