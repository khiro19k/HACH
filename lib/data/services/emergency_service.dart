import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyService {
  static const String _lastActivityKey = 'last_activity_timestamp';
  static const int _inactivityThresholdHours = 24;

  Future<void> updateActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> checkEmergency() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_lastActivityKey);
    
    if (lastActivity == null) return false;
    
    final lastDateTime = DateTime.fromMillisecondsSinceEpoch(lastActivity);
    final difference = DateTime.now().difference(lastDateTime);
    
    return difference.inHours >= _inactivityThresholdHours;
  }

  void startSilentMonitoring() {
    // Logic to periodically check in background or during app use
    Timer.periodic(const Duration(hours: 1), (timer) async {
      final isEmergency = await checkEmergency();
      if (isEmergency) {
        _triggerAlert();
      }
    });
  }

  void _triggerAlert() {
    // Logic to notify emergency contacts or server
  }
}
