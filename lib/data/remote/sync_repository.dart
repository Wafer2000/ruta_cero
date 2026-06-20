import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Repositorio de sincronización con Supabase
/// Sube y baja datos entre la base local y la nube
class SyncRepository {
  SupabaseClient get _client => SupabaseService.client;
  String get _userId => SupabaseService.userId!;

  bool get canSync => SupabaseService.isAuthenticated;

  // ===== USER PROFILE =====

  Future<Map<String, dynamic>?> fetchProfile() async {
    final res = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    return res;
  }

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    await _client.from('user_profiles').upsert({
      ...data,
      'user_id': _userId,
    });
  }

  // ===== GENERIC CRUD =====

  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    final res = await _client
        .from(table)
        .select()
        .eq('user_id', _userId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> upsertRow(String table, Map<String, dynamic> data) async {
    await _client.from(table).upsert({
      ...data,
      'user_id': _userId,
    });
  }

  Future<void> deleteRow(String table, String id) async {
    await _client.from(table).delete().eq('id', id).eq('user_id', _userId);
  }

  // ===== PAYMENTS =====

  Future<List<Map<String, dynamic>>> fetchPayments({String? month}) async {
    var query = _client.from('payments').select().eq('user_id', _userId);
    if (month != null) {
      // Filter by month prefix in planned_date
      query = query.gte('planned_date', '$month-01').lt('planned_date', _nextMonth(month));
    }
    final res = await query.order('planned_date');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> markPaymentPaid(String paymentId, DateTime paidDate, int amount) async {
    await _client.from('payments').update({
      'status': 'paid',
      'paid_date': paidDate.toIso8601String().split('T')[0],
      'amount': amount,
    }).eq('id', paymentId).eq('user_id', _userId);
  }

  // ===== AUDIT LOG =====

  Future<void> insertAuditLog(Map<String, dynamic> log) async {
    await _client.from('audit_logs').insert({
      ...log,
      'user_id': _userId,
    });
  }

  Future<List<Map<String, dynamic>>> fetchAuditLogs({int limit = 50}) async {
    final res = await _client
        .from('audit_logs')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  String _nextMonth(String monthKey) {
    final parts = monthKey.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    month++;
    if (month > 12) { month = 1; year++; }
    return '$year-${month.toString().padLeft(2, '0')}-01';
  }
}
