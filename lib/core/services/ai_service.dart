import '../../features/assistant/models/chat_message.dart';

abstract class AIService {
  Future<String> sendMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required String model,
    String? apiKey,
  });

  Future<String> generateWebsiteSpec({
    required String userPrompt,
    required String model,
    String? apiKey,
  });

  Future<String> refineWebsiteCode({
    required String originalHtml,
    required String changeRequest,
    required String model,
    String? apiKey,
  });
}
