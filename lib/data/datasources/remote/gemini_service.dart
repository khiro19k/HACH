import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/constants/constants.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );
    _visionModel = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );
  }

  Future<String> chat(String message) async {
    try {
      print('🚀 Gemini Request: $message');
      
      final content = [
        Content.text(AppConstants.systemPrompt),
        Content.text(message)
      ];

      final response = await _model.generateContent(content);
      
      print('✅ Gemini Response Received');
      return response.text ?? 'لم أستطع الحصول على إجابة حالياً.';
    } catch (e) {
      print('☢️ Gemini Exception: $e');
      return 'المعذرة يا خويا، واجهت مشكلة في الاتصال. إذا كان الأمر طارئاً، يرجى استشارة الطبيب فوراً.';
    }
  }

  Future<String> analyzeFood(List<int> imageBytes, String mimeType) async {
    try {
      print('📸 Gemini Image Request sent...');
      
      final imagePrompt = '''
        حلل هذه الصورة للطعام لمريض سكري جزائري:
        1. واش هو هذا الطعام بالضبط؟
        2. قداش فيه الكربوهيدرات (تقديراً)؟
        3. هل هو مليح لمريض السكري؟ واش هي النصيحة تاعك؟
        جاوب بالدارجة الجزائرية الودودة واستعمل القاموس الطبي إذا لزم الأمر.
      ''';

      final content = [
        Content.multi([
          TextPart(AppConstants.systemPrompt),
          TextPart(imagePrompt),
          DataPart(mimeType, Uint8List.fromList(imageBytes)),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      
      print('✅ Gemini Image Analysis Received');
      return response.text ?? 'لم أستطع تحليل الصورة حالياً.';
    } catch (e) {
      print('☢️ Gemini Image Exception: $e');
      return 'المعذرة، كاين مشكلة في تحليل الصورة. حاول مرة أخرى يا خويا.';
    }
  }
}


