import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/glucose_record.dart';
import '../../data/datasources/remote/glucose_service.dart';
import 'safety_provider.dart';
import 'patient_provider.dart';

class GlucoseState {
  final List<GlucoseRecord> records;
  final bool isLoading;

  GlucoseState({required this.records, this.isLoading = false});
}

class GlucoseNotifier extends StateNotifier<GlucoseState> {
  final GlucoseService _remoteService;
  final Ref _ref;
  final String? _patientId;

  GlucoseNotifier(this._remoteService, this._ref, this._patientId) : super(GlucoseState(records: [])) {
    if (_patientId != null) {
      loadRecords();
      _setupRealtime();
    }
  }

  void _setupRealtime() {
    _remoteService.subscribeToReadings(_patientId!, (data) {
      loadRecords();
    });
  }

  Future<void> loadRecords() async {
    if (_patientId == null) return;
    state = GlucoseState(records: state.records, isLoading: true);
    
    final data = await _remoteService.fetchReadings(_patientId!);
    final records = data.map((m) => GlucoseRecord.fromMap(m)).toList();
    
    state = GlucoseState(records: records, isLoading: false);
  }

  Future<void> addRecord(double value, String type, String? notes) async {
    if (_patientId == null) return;

    await _remoteService.syncReading(value, _patientId!, type);
    // Real-time will trigger reload, but we can reload manually too
    loadRecords();

    // Automatic Emergency Check: If sugar is low (< 70) and user is OUT
    _ref.read(safetyProvider.notifier).triggerEmergency(value);
  }
}

final glucoseProvider = StateNotifierProvider<GlucoseNotifier, GlucoseState>((ref) {
  final patient = ref.watch(patientProvider).profile;
  final patientId = patient?['id'];
  return GlucoseNotifier(GlucoseService(), ref, patientId);
});
