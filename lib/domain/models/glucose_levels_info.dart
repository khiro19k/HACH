import 'package:flutter/material.dart';

enum GlucoseStatus { low, normal, slightlyHigh, high, veryHigh }

class GlucoseLevelInfo {
  final double value;
  final String status;
  final String treatment;
  final Color color;

  GlucoseLevelInfo({
    required this.value,
    required this.status,
    required this.treatment,
    required this.color,
  });

  static GlucoseLevelInfo getInfo(double value) {
    if (value < 70) {
      return GlucoseLevelInfo(
        value: value,
        status: 'منخفض جداً (Hypo)',
        treatment: 'تناول 15 جرام من السكر السريع (عصير أو ملعقة عسل)، انتظر 15 دقيقة ثم أعد القياس. إذا استمر الانخفاض، كرر العملية.',
        color: Colors.red,
      );
    } else if (value >= 70 && value <= 130) {
      return GlucoseLevelInfo(
        value: value,
        status: 'طبيعي',
        treatment: 'مستوى ممتاز. استمر في اتباع نظامك الغذائي والرياضي المتوازن.',
        color: const Color(0xFF4CAF50), // Green
      );
    } else if (value > 130 && value <= 180) {
      return GlucoseLevelInfo(
        value: value,
        status: 'مرتفع قليلاً',
        treatment: 'راقب وجبتك القادمة، اشرب الماء، وراجع إذا كنت قد نسيت جرعة الدواء.',
        color: Colors.orange,
      );
    } else if (value > 180 && value <= 250) {
      return GlucoseLevelInfo(
        value: value,
        status: 'مرتفع (Hyper)',
        treatment: 'شرب كميات كافية من الماء، تجنب السكريات تماماً، وراجع طبيبك إذا استمر الارتفاع لأكثر من قراءتين.',
        color: Colors.redAccent,
      );
    } else {
      return GlucoseLevelInfo(
        value: value,
        status: 'مرتفع جداً (خطر)',
        treatment: 'اتصل بطبيبك فوراً أو توجه للطوارئ. قد تكون هناك حاجة لتعديل جرعة الأنسولين أو فحص الكيتونات.',
        color: Colors.deepOrange,
      );
    }
  }
}
