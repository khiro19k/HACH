import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/medication.dart';
import '../../data/datasources/remote/medication_service_remote.dart';
import './patient_provider.dart';

class MedicationState {
  final List<Medication> medications;
  final bool isLoading;

  MedicationState({required this.medications, this.isLoading = false});
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  final MedicationServiceRemote _remoteService;
  final String? _patientId;

  MedicationNotifier(this._remoteService, this._patientId) : super(MedicationState(medications: [])) {
    if (_patientId != null) {
      loadMedications();
      _setupRealtime();
    }
  }

  void _setupRealtime() {
    _remoteService.listenForNewPrescriptions(_patientId!, () {
      loadMedications();
    });
  }

  Future<void> loadMedications() async {
    if (_patientId == null) return;
    state = MedicationState(medications: state.medications, isLoading: true);
    
    final medications = await _remoteService.fetchDoctorPrescribed(_patientId!);
    // Also fetch manual ones (or the schema might handle all in one table)
    // For now, fetchDoctorPrescribed fetches all where is_doctor_prescribed can be true or false
    
    state = MedicationState(medications: medications, isLoading: false);
  }

  Future<void> addMedication(String name, String dosage, String frequency) async {
    if (_patientId == null) return;
    
    final med = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _patientId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      isTaken: false,
    );

    await _remoteService.addMedication(med);
    loadMedications();
  }

  Future<void> toggleTaken(String id) async {
    final index = state.medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      final oldMed = state.medications[index];
      final newMed = Medication(
        id: oldMed.id,
        patientId: oldMed.patientId,
        name: oldMed.name,
        dosage: oldMed.dosage,
        frequency: oldMed.frequency,
        isTaken: !oldMed.isTaken,
        isDoctorPrescribed: oldMed.isDoctorPrescribed,
      );

      await _remoteService.updateMedication(newMed);
      loadMedications();
    }
  }

  Future<void> deleteMedication(String id) async {
    await _remoteService.deleteMedication(id);
    loadMedications();
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  final patient = ref.watch(patientProvider).profile;
  final patientId = patient?['id'];
  return MedicationNotifier(MedicationServiceRemote(), patientId);
});
