import '../models/glucose_record.dart';

class PredictTrendsUseCase {
  String predict(List<GlucoseRecord> records) {
    if (records.isEmpty) return 'Not enough data to predict trends.';
    
    // Simple linear trend analysis placeholder
    double sum = 0;
    for (var r in records) {
      sum += r.value;
    }
    final average = sum / records.length;
    
    if (average > 180) {
      return 'Trend indicates a risk of Hyperglycemia. Consider reducing carb intake.';
    } else if (average < 70) {
      return 'Trend indicates a risk of Hypoglycemia. Ensure regular meal times.';
    } else {
      return 'Your glucose levels are trending within the target range. Keep it up!';
    }
  }
}
