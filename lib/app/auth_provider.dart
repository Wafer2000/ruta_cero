import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote/supabase_service.dart';

/// Estado de autenticación
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Provider que observa el estado de auth de Supabase
final authStateProvider = StreamProvider<AuthStatus>((ref) {
  if (!SupabaseService.isInitialized) {
    // Sin Supabase: modo offline, siempre "autenticado" localmente
    return Stream.value(AuthStatus.authenticated);
  }

  return SupabaseService.authStateChanges.map((state) {
    if (state.session != null) return AuthStatus.authenticated;
    return AuthStatus.unauthenticated;
  });
});

/// Provider del user ID actual
final currentUserIdProvider = Provider<String?>((ref) {
  return SupabaseService.userId;
});

/// Provider de si Supabase está activo
final isOnlineProvider = Provider<bool>((ref) {
  return SupabaseService.isInitialized && SupabaseService.isAuthenticated;
});
