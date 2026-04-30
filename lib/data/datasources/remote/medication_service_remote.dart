import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../../domain/models/medication.dart';

class MedicationServiceRemote {
  final _client = SupabaseConfig.client;

  Future<List<Medication>> fetchDoctorPrescribed(String patientId) async {
    try {
      final response = await _client
          .from('medications')
          .select()
          .eq('patient_id', patientId)
          .eq('is_doctor_prescribed', true);

      return (response as List).map((m) => Medication.fromMap(m)).toList();
    } catch (e) {
      print('Fetch Meds Error: $e');
      return [];
    }
  }

  void listenForNewPrescriptions(String patientId, Function() onUpdate) {
    _client
        .channel('public:medications')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'medications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'patient_id',
            value: patientId,
          ),
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  Future<void> addMedication(Medication med) async {
    await _client.from('medications').insert(med.toMap());
  }

  Future<void> deleteMedication(String id) async {
    await _client.from('medications').delete().eq('id', id);
  }

  Future<void> updateMedication(Medication med) async {
    await _client.from('medications').update(med.toMap()).eq('id', med.id);
  }
}
