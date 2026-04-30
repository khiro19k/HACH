import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: AppConstants.geminiModel,
          apiKey: AppConstants.geminiApiKey,
        );

  Future<String> getHealthAdvice(String query) async {
    try {
      final content = [Content.text(query)];
      final response = await _model.generateContent(content);
      return response.text ?? 'لم أستطع الحصول على إجابة حالياً.';
    } catch (e) {
      return 'حدث خطأ: $e';
    }
  }
}
