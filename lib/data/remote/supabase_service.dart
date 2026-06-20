import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/environment.dart';

/// Servicio de conexión con Supabase
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize(EnvConfig config) async {
    if (config.supabaseUrl.isEmpty || config.supabaseAnonKey.isEmpty) {
      return; // Offline mode — no Supabase configurado
    }

    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
  }

  static bool get isInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  static User? get currentUser => isInitialized ? client.auth.currentUser : null;
  static String? get userId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      isInitialized ? client.auth.onAuthStateChange : const Stream.empty();
}
