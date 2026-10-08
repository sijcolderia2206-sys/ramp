// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/features/ai/ai_assistant_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

part 'ai_assistant_provider.g.dart';

class ChatMessage {
  final bool isAi;
  final String text;
  
  ChatMessage({required this.isAi, required this.text});
}

@riverpod
class AiAssistant extends _$AiAssistant {
  GenerativeModel? _model;

  @override
  FutureOr<List<ChatMessage>> build() {
    // IMPORTANT: In production, inject this securely via a backend service or secure env.
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system('You are RAMP, an expert real estate portfolio assistant for Landlords.'),
      );
    }
    
    return [
      ChatMessage(isAi: true, text: 'Hello! I am your RAMP portfolio assistant. How can I help you today?'),
    ];
  }

  Future<void> askQuestion(String prompt) async {
    if (prompt.trim().isEmpty) return;
    
    final currentHistory = state.value ?? [];
    // Optimistic UI addition
    state = AsyncData([...currentHistory, ChatMessage(isAi: false, text: prompt)]);

    if (_model == null) {
      state = AsyncData([
        ...state.value!,
        ChatMessage(isAi: true, text: 'Error: Gemini API Key not configured. Please set GEMINI_API_KEY during build.')
      ]);
      return;
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      if (response.text != null) {
        state = AsyncData([...state.value!, ChatMessage(isAi: true, text: response.text!)]);
      }
    } catch (e) {
      state = AsyncData([...state.value!, ChatMessage(isAi: true, text: 'Sorry, I encountered an error: $e')]);
    }
  }
}
