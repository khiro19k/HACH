import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafiik/data/datasources/remote/gemini_service.dart';

void main() {
  test('Verify Food Analysis with Real API', () async {
    final service = GeminiService();
    
    // Path to the generated image
    final File imageFile = File(r'C:\Users\M-Tech\.gemini\antigravity\brain\8ac79043-be74-4734-a8d2-811771597ef6\algerian_couscous_test_1777395491084.png');
    
    if (!imageFile.existsSync()) {
      debugPrint('Test image not found!');
      return;
    }

    final bytes = await imageFile.readAsBytes();
    debugPrint('Analyzing image (Couscous)...');
    
    final result = await service.analyzeFood(bytes, 'image/png');
    
    debugPrint('--- AI RESPONSE ---');
    debugPrint(result);
    debugPrint('-------------------');
    
    expect(result, isNotNull);
    expect(result.isNotEmpty, true);
  });
}
