import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  ShakeDetector? _detector;

  void startShakeDetection(VoidCallback onShakeDetected) {
    _detector ??= ShakeDetector.autoStart(
      onPhoneShake: (event) {
        onShakeDetected();
      },
      shakeThresholdGravity: 2.7,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
    );
  }

  void stopShakeDetection() {
    _detector?.stopListening();
  }

  Future<void> sendSosSms() async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = prefs.getStringList('family_contacts') ?? [];

    if (contacts.isEmpty) return;

    // Get Location
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    String mapsLink =
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    String message =
        "🚨 حالة طوارئ! رفيق الذكي يبلغك أن المريض ربما فقد وعيه. هذا هو موقعه الحالي:\n$mapsLink";

    for (final number in contacts) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: number,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }


  /// Send SMS silently to multiple contacts (family members added by doctor)
  Future<void> sendSosToAllContacts(List<String> contacts, String message) async {
    for (final number in contacts) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: number,
        queryParameters: {'body': message},
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }
}
