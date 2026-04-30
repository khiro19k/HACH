import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;
  final List<int>? imageBytes;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imageUrl,
    this.imageBytes,
  });
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService;

  ChatNotifier(this._geminiService) : super([]);

  Future<void> sendMessage(String text, {String? imageUrl, List<int>? imageBytes}) async {
    state = [...state, ChatMessage(text: text, isUser: true, imageUrl: imageUrl, imageBytes: imageBytes)];
    
    try {
      String response;
      if (imageBytes != null) {
        response = await _geminiService.analyzeFood(imageBytes, 'image/jpeg');
      } else {
        response = await _geminiService.chat(text);
      }
      state = [...state, ChatMessage(text: response, isUser: false)];
    } catch (e) {
      state = [...state, ChatMessage(text: 'المعذرة، حدث خطأ: $e', isUser: false)];
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return ChatNotifier(geminiService);
});
