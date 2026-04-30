import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthStats {
  final double sleepHours;
  final double waterLiters;
  final int activityPercentage;
  final bool isChallengeActive;

  HealthStats({
    this.sleepHours = 0.0,
    this.waterLiters = 0.0,
    this.activityPercentage = 0,
    this.isChallengeActive = false,
  });

  HealthStats copyWith({
    double? sleepHours,
    double? waterLiters,
    int? activityPercentage,
    bool? isChallengeActive,
  }) {
    return HealthStats(
      sleepHours: sleepHours ?? this.sleepHours,
      waterLiters: waterLiters ?? this.waterLiters,
      activityPercentage: activityPercentage ?? this.activityPercentage,
      isChallengeActive: isChallengeActive ?? this.isChallengeActive,
    );
  }
}

class HealthStatsNotifier extends StateNotifier<HealthStats> {
  HealthStatsNotifier() : super(HealthStats()) {
    _init();
  }

  Future<void> _init() async {
    await calculateSleep();
    await loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      waterLiters: prefs.getDouble('water_liters') ?? 0.0,
      activityPercentage: prefs.getInt('activity_percentage') ?? 0,
    );
  }

  // AI Sleep Heuristic: Detect gap between last app use and now
  Future<void> calculateSleep() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenStr = prefs.getString('last_seen_time');
    final now = DateTime.now();

    if (lastSeenStr != null) {
      final lastSeen = DateTime.parse(lastSeenStr);
      final gapHours = now.difference(lastSeen).inMinutes / 60.0;

      // If gap is between 4 and 12 hours, assume it was sleep
      if (gapHours >= 4 && gapHours <= 12) {
        state = state.copyWith(sleepHours: double.parse(gapHours.toStringAsFixed(1)));
        await prefs.setDouble('last_sleep_hours', state.sleepHours);
      } else {
        // Use last known sleep or default
        state = state.copyWith(sleepHours: prefs.getDouble('last_sleep_hours') ?? 7.0);
      }
    } else {
      state = state.copyWith(sleepHours: 7.5); // Default for first run
    }

    // Update last seen to now
    await prefs.setString('last_seen_time', now.toIso8601String());
  }

  Future<void> addWater(double amount) async {
    final newTotal = state.waterLiters + amount;
    state = state.copyWith(waterLiters: newTotal);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('water_liters', newTotal);
  }

  void setChallengeActive(bool active) {
    state = state.copyWith(isChallengeActive: active);
  }

  Future<void> completeActivity(int increment) async {
    final newTotal = (state.activityPercentage + increment).clamp(0, 100);
    state = state.copyWith(activityPercentage: newTotal, isChallengeActive: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activity_percentage', newTotal);
  }
}

final healthStatsProvider = StateNotifierProvider<HealthStatsNotifier, HealthStats>((ref) {
  return HealthStatsNotifier();
});
