import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/failures.dart';
import '../../features/assistant/models/chat_message.dart';
import 'ai_service.dart';

class GeminiAIService implements AIService {
  final http.Client _client;

  GeminiAIService([http.Client? client]) : _client = client ?? http.Client();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const String _systemPrompt = '''
You are Cyber AI, an autonomous personal Android assistant and tutor.
Your persona is sharp, futuristic, insightful, and highly intelligent.
You provide clear, accurate, and deeply educational answers. When tutoring, explain complex concepts with intuitive metaphors and real-world clarity.
Keep direct conversational responses concise and easy to read or listen to via speech.
Never execute shell commands or expose private secrets.
''';

  @override
  Future<String> sendMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required String model,
    String? apiKey,
  }) async {
    // If no API key configured or offline, use built-in offline intelligence
    if (apiKey == null || apiKey.trim().isEmpty) {
      return _generateOfflineResponse(prompt);
    }

    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');

    // Build contents payload
    final contents = <Map<String, dynamic>>[];

    // Add recent history (up to last 6 messages)
    final recentHistory = conversationHistory.length > 6
        ? conversationHistory.sublist(conversationHistory.length - 6)
        : conversationHistory;

    for (final msg in recentHistory) {
      if (msg.isError) continue;
      contents.add({
        'role': msg.sender == MessageSender.user ? 'user' : 'model',
        'parts': [
          {'text': msg.text},
        ],
      });
    }

    // Add current prompt
    contents.add({
      'role': 'user',
      'parts': [
        {'text': prompt},
      ],
    });

    final requestBody = {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
    };

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: AppConfig.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text']?.toString() ?? 'No response generated.';
          }
        }
        return 'I processed your request, but received an empty response.';
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        throw AuthFailure(
          'Invalid API key or unauthorized request. Please verify your Gemini API key in Settings.',
          code: '${response.statusCode}',
        );
      } else {
        throw NetworkFailure(
          'Gemini API returned status code ${response.statusCode}.',
          code: '${response.statusCode}',
        );
      }
    } on TimeoutException {
      return _generateOfflineResponse(
        prompt,
        fallbackReason: 'Network timeout occurred. Using offline intelligence.',
      );
    } on AuthFailure {
      rethrow;
    } catch (e) {
      // Graceful offline fallback
      return _generateOfflineResponse(
        prompt,
        fallbackReason: 'Offline mode active.',
      );
    }
  }

  @override
  Future<String> generateWebsiteSpec({
    required String userPrompt,
    required String model,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) {
      return ''; // will trigger local engine in website_generator
    }

    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');
    final specPrompt =
        '''
You are a senior UI/UX architect and web engineer.
Convert this user brief into a structured JSON website specification:
"$userPrompt"

Return ONLY a valid JSON object matching this schema:
{
  "title": "string",
  "tagline": "string",
  "layoutType": "saas" | "portfolio" | "ecommerce" | "restaurant" | "dashboard" | "agency" | "education" | "entertainment" | "productLaunch",
  "primaryColor": "#hex",
  "secondaryColor": "#hex",
  "backgroundColor": "#hex",
  "textColor": "#hex",
  "enable3DEffects": boolean,
  "navigationLinks": ["string", "string", "string", "string"],
  "sections": [
    {
      "id": "hero",
      "title": "string",
      "description": "string",
      "type": "hero"
    },
    {
      "id": "features",
      "title": "string",
      "description": "string",
      "type": "features"
    },
    {
      "id": "showcase",
      "title": "string",
      "description": "string",
      "type": "showcase3d"
    },
    {
      "id": "contact",
      "title": "string",
      "description": "string",
      "type": "contact"
    }
  ]
}
Do not wrap in markdown or backticks. Return pure JSON.
''';

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': specPrompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: AppConfig.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            String text = parts[0]['text']?.toString() ?? '';
            text = text.replaceAll('```json', '').replaceAll('```', '').trim();
            return text;
          }
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<String> refineWebsiteCode({
    required String originalHtml,
    required String changeRequest,
    required String model,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) {
      return originalHtml;
    }

    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');
    final prompt =
        '''
You are a frontend engineer.
Here is the existing single-file website code:
$originalHtml

Apply this change requested by the user:
"$changeRequest"

Requirements:
- Preserve responsive layout, CSS variables, and interactive features.
- Return ONLY the updated complete HTML code with <style> and <script> tags included.
- Do NOT output markdown code blocks.
''';

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: AppConfig.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            String text = parts[0]['text']?.toString() ?? '';
            text = text.replaceAll('```html', '').replaceAll('```', '').trim();
            return text;
          }
        }
      }
      return originalHtml;
    } catch (_) {
      return originalHtml;
    }
  }

  /// Built-in offline knowledge and tutoring base
  String _generateOfflineResponse(String prompt, {String? fallbackReason}) {
    final lower = prompt.toLowerCase();
    String prefix = fallbackReason != null ? '[$fallbackReason]\n\n' : '';

    if (lower.contains('photosynthesis')) {
      return '${prefix}Photosynthesis is the biochemical process by which green plants, algae, and cyanobacteria convert solar light energy into chemical energy stored in glucose.\n\n'
          'Key Reaction:\n'
          '6CO₂ + 6H₂O + Light Energy ➔ C₆H₁₂O₆ + 6O₂\n\n'
          '1. Light-Dependent Reactions (in thylakoid membranes): Chlorophyll absorbs photons, splitting H₂O to release Oxygen (O₂) and generate ATP and NADPH.\n'
          '2. Calvin Cycle / Light-Independent (in stroma): CO₂ is fixed into G3P sugar using the ATP and NADPH produced earlier.\n\n'
          'It is the biological engine that sustains Earth\'s atmospheric oxygen and oxygen-breathing life.';
    }

    if (lower.contains('quantum')) {
      return '${prefix}Quantum computing leverages the principles of quantum mechanics—namely superposition and entanglement—to process complex information exponentially faster than classical computers for specific problem classes.\n\n'
          '• Qubits can exist in a superposition of |0⟩ and |1⟩ states simultaneously.\n'
          '• Entanglement allows multiple qubits to correlate their states instantaneously.\n'
          '• Applications include molecular simulation, cryptographic analysis, and combinatorial optimization.';
    }

    if (lower.contains('neural network') || lower.contains('ai')) {
      return '${prefix}An artificial neural network consists of interconnected nodes (neurons) organized into layers: an input layer, hidden layers, and an output layer.\n\n'
          'During training, data flows forward, generating a loss compared to targets. Backpropagation computes gradients of the loss with respect to weights using the chain rule, and an optimizer adjusts weights to minimize error.';
    }

    if (lower.contains('who are you') || lower.contains('cyber ai')) {
      return '${prefix}I am Cyber AI — your autonomous personal Android assistant and intelligent workstation. I can tutor you in complex topics, control your Android apps, route YouTube Music with ReVanced support, and generate full 3D websites from natural language.';
    }

    return '${prefix}Cyber AI processed your inquiry: "$prompt". For full access to online generative reasoning, connect your Gemini API key in Settings.';
  }
}
