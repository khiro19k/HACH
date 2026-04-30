import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_config.dart';

class GlucoseService {
  final _client = SupabaseConfig.client;

  Future<void> syncReading(double level, String patientId, String context) async {
    await _client.from('glucose_readings').insert({
      'patient_id': patientId,
      'glucose_level': level,
      'reading_context': context,
      'is_manual': true,
    });
  }

  Future<List<Map<String, dynamic>>> fetchReadings(String patientId) async {
    final response = await _client
        .from('glucose_readings')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  void subscribeToReadings(String patientId, Function(Map<String, dynamic>) onNewReading) {
    _client
        .channel('public:glucose_readings')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'glucose_readings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'patient_id',
            value: patientId,
          ),
          callback: (payload) => onNewReading(payload.newRecord),
        )
        .subscribe();
  }
}
