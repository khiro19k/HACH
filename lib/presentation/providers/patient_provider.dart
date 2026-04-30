import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientState {
  final Map<String, dynamic>? profile;
  final bool isLoading;

  PatientState({this.profile, this.isLoading = false});
}

class PatientNotifier extends StateNotifier<PatientState> {
  PatientNotifier() : super(PatientState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('patient_profile');
    if (profileStr != null) {
      state = PatientState(profile: jsonDecode(profileStr));
    }
  }

  Future<void> setPatient(Map<String, dynamic> data) async {
    state = PatientState(profile: data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patient_profile', jsonEncode(data));
  }

  Future<void> logout() async {
    state = PatientState(profile: null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('patient_profile');
  }
}

final patientProvider = StateNotifierProvider<PatientNotifier, PatientState>((ref) {
  return PatientNotifier();
});
