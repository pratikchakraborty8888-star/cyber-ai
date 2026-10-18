import 'package:flutter/material.dart';

import 'core/services/ai_service.dart';
import 'core/services/gemini_ai_service.dart';
import 'core/services/platform_bridge.dart';
import 'core/services/speech_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/website_generator.dart';
import 'core/theme/cyber_theme.dart';
import 'features/assistant/screens/assistant_screen.dart';
import 'features/music/services/music_handoff_service.dart';

class CyberAiApp extends StatelessWidget {
  final StorageService storageService;

  const CyberAiApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    final platformBridge = PlatformBridge();
    final AIService aiService = GeminiAIService();
    final speechService = SpeechService();
    final ttsService = TTSService();
    final websiteGenerator = WebsiteGenerator(aiService);
    final musicService = MusicHandoffService(platformBridge);

    return MaterialApp(
      title: 'Cyber AI',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.darkTheme,
      home: AssistantScreen(
        storageService: storageService,
        platformBridge: platformBridge,
        aiService: aiService,
        speechService: speechService,
        ttsService: ttsService,
        websiteGenerator: websiteGenerator,
        musicService: musicService,
      ),
    );
  }
}
