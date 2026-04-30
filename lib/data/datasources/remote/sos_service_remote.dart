import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_config.dart';

class SosServiceRemote {
  final _client = SupabaseConfig.client;

  Future<String?> triggerAlert({
    required String patientId,
    required double lat,
    required double lng,
    String status = 'active',
  }) async {
    final response = await _client.from('sos_alerts').insert({
      'patient_id': patientId,
      'latitude': lat,
      'longitude': lng,
      'status': status,
    }).select('id').single();
    
    return response['id'].toString();
  }

  void listenForAlertStatus(String alertId, Function(String) onStatusChange) {
    _client
        .channel('public:sos_alerts')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'sos_alerts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: alertId,
          ),
          callback: (payload) => onStatusChange(payload.newRecord['status']),
        )
        .subscribe();
  }
}
