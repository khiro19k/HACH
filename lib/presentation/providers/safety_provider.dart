import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/sos_service.dart';
import '../../data/datasources/remote/sos_service_remote.dart';
import 'patient_provider.dart';

class SafetyState {
  final bool isOut;
  final Position? homePosition;
  final List<String> familyContacts;
  final bool isSafetyKitChecked;
  final String? activeAlertId;
  final String alertStatus; // 'idle', 'active', 'help_on_way', 'resolved'

  SafetyState({
    this.isOut = false,
    this.homePosition,
    this.familyContacts = const [],
    this.isSafetyKitChecked = false,
    this.activeAlertId,
    this.alertStatus = 'idle',
  });

  SafetyState copyWith({
    bool? isOut,
    Position? homePosition,
    List<String>? familyContacts,
    bool? isSafetyKitChecked,
    String? activeAlertId,
    String? alertStatus,
  }) {
    return SafetyState(
      isOut: isOut ?? this.isOut,
      homePosition: homePosition ?? this.homePosition,
      familyContacts: familyContacts ?? this.familyContacts,
      isSafetyKitChecked: isSafetyKitChecked ?? this.isSafetyKitChecked,
      activeAlertId: activeAlertId ?? this.activeAlertId,
      alertStatus: alertStatus ?? this.alertStatus,
    );
  }
}

class SafetyNotifier extends StateNotifier<SafetyState> {
  final Ref _ref;
  final String? _patientId;
  final SosServiceRemote _remoteSos = SosServiceRemote();

  SafetyNotifier(this._ref, this._patientId) : super(SafetyState()) {
    _init();
  }

  Future<void> _init() async {
    await loadSettings();
    _startGeofencing();
    
    // Start Shake Detection
    SosService().startShakeDetection(() {
      triggerPanicSOS();
    });
  }

  Future<void> triggerPanicSOS() async {
    if (_patientId == null) return;
    
    state = state.copyWith(alertStatus: 'active');
    
    // 1. Send SMS (Legacy/Local)
    await SosService().sendSosSms();
    
    // 2. Trigger in Supabase (Remote)
    try {
      final pos = await Geolocator.getCurrentPosition();
      final alertId = await _remoteSos.triggerAlert(
        patientId: _patientId!,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      if (alertId != null) {
        state = state.copyWith(activeAlertId: alertId);
        _remoteSos.listenForAlertStatus(alertId, (newStatus) {
          state = state.copyWith(alertStatus: newStatus);
        });
      }
    } catch (e) {
      debugPrint('Supabase SOS Error: $e');
    }
  }


  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('home_lat');
    final lng = prefs.getDouble('home_lng');
    final contacts = prefs.getStringList('family_contacts') ?? [];

    state = state.copyWith(
      homePosition: lat != null ? Position(
        latitude: lat,
        longitude: lng ?? 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ) : null,
      familyContacts: contacts,
    );
  }

  Future<void> setHomeLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('home_lat', position.latitude);
    await prefs.setDouble('home_lng', position.longitude);
    state = state.copyWith(homePosition: position);
  }

  Future<void> _startGeofencing() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) return;

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      ).listen(
        (position) {
          if (state.homePosition != null) {
            double distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              state.homePosition!.latitude,
              state.homePosition!.longitude,
            );

            bool wasOut = state.isOut;
            bool currentlyOut = distance > 100;

            if (currentlyOut != wasOut) {
              state = state.copyWith(isOut: currentlyOut);
            }
          }
        },
        onError: (error) {
          debugPrint('Geofencing error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start geofencing: $e');
    }
  }

  void setSafetyKitChecked(bool checked) {
    state = state.copyWith(isSafetyKitChecked: checked);
  }

  Future<void> updateFamilyContacts(List<String> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('family_contacts', contacts);
    state = state.copyWith(familyContacts: contacts);
  }

  Future<void> triggerEmergency(double glucoseValue) async {
    if (state.isOut && glucoseValue < 70) {
      triggerPanicSOS();
    }
  }

  Future<void> resolveAlert() async {
    if (state.activeAlertId != null) {
      // Potentially update status in Supabase too
      state = state.copyWith(alertStatus: 'idle', activeAlertId: null);
    }
  }
}

final safetyProvider = StateNotifierProvider<SafetyNotifier, SafetyState>((ref) {
  final patient = ref.watch(patientProvider).profile;
  final patientId = patient?['id'];
  return SafetyNotifier(ref, patientId);
});

