import 'package:flutter/material.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/platform_bridge.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/website_generator.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/utils/intent_parser.dart';
import '../../../models/user_preferences.dart';
import '../../apps/screens/app_launcher_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../music/screens/music_screen.dart';
import '../../music/services/music_handoff_service.dart';
import '../../settings/screens/settings_screen.dart';
import '../../voice/screens/voice_screen.dart';
import '../../websites/screens/website_studio_screen.dart';
import '../models/action_intent.dart';
import '../models/chat_message.dart';
import '../widgets/assistant_orb.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_action_bar.dart';
import '../widgets/state_pill.dart';

class AssistantScreen extends StatefulWidget {
  final StorageService storageService;
  final PlatformBridge platformBridge;
  final AIService aiService;
  final SpeechService speechService;
  final TTSService ttsService;
  final WebsiteGenerator websiteGenerator;
  final MusicHandoffService musicService;

  const AssistantScreen({
    super.key,
    required this.storageService,
    required this.platformBridge,
    required this.aiService,
    required this.speechService,
    required this.ttsService,
    required this.websiteGenerator,
    required this.musicService,
  });

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  UserPreferences _preferences = const UserPreferences();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await widget.storageService.loadPreferences();
    final history = await widget.storageService.loadChatHistory();

    setState(() {
      _preferences = prefs;
      if (history.isNotEmpty) {
        _messages = history;
      } else {
        _messages = [
          ChatMessage(
            id: 'welcome_1',
            sender: MessageSender.assistant,
            text: 'Cyber AI initialized and standing by. I can tutor you in complex topics, control your Android apps, route YouTube Music with ReVanced support, or generate full 3D websites.',
            timestamp: DateTime.now(),
          ),
        ];
      }
    });

    await widget.ttsService.initialize(
      rate: prefs.speechRate,
      volume: prefs.speechVolume,
    );
  }

  Future<void> _handleCommand(String rawInput) async {
    final input = rawInput.trim();
    if (input.isEmpty) return;

    _textController.clear();
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: input,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    // 1. Parse intent
    final intent = IntentParser.parse(input);

    switch (intent.type) {
      case ActionType.stopSpeaking:
        await widget.ttsService.stop();
        _addAssistantResponse('Voice output halted.', intent: intent);
        break;

      case ActionType.openSettings:
        _addAssistantResponse('Opening Settings.', intent: intent);
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                storageService: widget.storageService,
                platformBridge: widget.platformBridge,
                ttsService: widget.ttsService,
                currentPreferences: _preferences,
                onPreferencesChanged: (newPrefs) {
                  setState(() => _preferences = newPrefs);
                },
              ),
            ),
          );
        }
        break;

      case ActionType.openMusicApp:
        final success = await widget.musicService.launchMusicApp(
          _preferences.preferredMusicPackage,
        );
        final response = success
            ? 'Launched your preferred music application.'
            : 'Could not launch music application. Opened YouTube Music web fallback.';
        _addAssistantResponse(response, intent: intent);
        break;

      case ActionType.searchMusic:
        final query = intent.parameters['query']?.toString() ?? 'Trending';
        final result = await widget.musicService.searchAndPlay(
          query: query,
          preferredPackage: _preferences.preferredMusicPackage,
        );
        _addAssistantResponse(result.message, intent: intent);
        break;

      case ActionType.openApp:
        final appName = intent.parameters['appName']?.toString() ?? '';
        final packageName = intent.parameters['packageName']?.toString() ?? '';

        if (packageName.isNotEmpty) {
          final launched = await widget.platformBridge.launchApp(packageName);
          if (launched) {
            _addAssistantResponse(
              'Launched $appName successfully.',
              intent: intent,
            );
          } else {
            _addAssistantResponse(
              'Application $appName ($packageName) is not installed on this device.',
              intent: intent,
              isError: true,
            );
          }
        } else {
          // Unknown package, open launcher screen
          _addAssistantResponse(
            'Searching for app "$appName" in App Launcher...',
            intent: intent,
          );
          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AppLauncherScreen(
                  platformBridge: widget.platformBridge,
                  searchQuery: appName,
                ),
              ),
            );
          }
        }
        break;

      case ActionType.createWebsite:
        final prompt = intent.parameters['prompt']?.toString() ?? input;
        _addAssistantResponse(
          'Navigating to Website Studio to build your site: "$prompt"',
          intent: intent,
        );
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebsiteStudioScreen(
                websiteGenerator: widget.websiteGenerator,
                storageService: widget.storageService,
                apiKey: _preferences.geminiApiKey,
                selectedModel: _preferences.selectedModel,
                initialPrompt: prompt,
              ),
            ),
          );
        }
        break;

      case ActionType.answerQuestion:
      case ActionType.unsupportedAction:
        try {
          widget.speechService.setState(AssistantState.processing);
          final response = await widget.aiService.sendMessage(
            prompt: input,
            conversationHistory: _messages,
            model: _preferences.selectedModel,
            apiKey: _preferences.geminiApiKey,
          );
          _addAssistantResponse(response, intent: intent);

          if (_preferences.spokenResponsesEnabled) {
            widget.speechService.setState(AssistantState.speaking);
            await widget.ttsService.speak(response);
            widget.speechService.setState(AssistantState.idle);
          }
        } catch (e) {
          _addAssistantResponse(
            'Error communicating with AI engine: $e',
            isError: true,
          );
        }
        break;
    }

    setState(() => _isLoading = false);
    await widget.storageService.saveChatHistory(_messages);
  }

  void _addAssistantResponse(
    String text, {
    ActionIntent? intent,
    bool isError = false,
  }) {
    final responseMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.assistant,
      text: text,
      timestamp: DateTime.now(),
      intent: intent,
      isError: isError,
    );
    setState(() {
      _messages.add(responseMsg);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onQuickAction(String actionId) {
    switch (actionId) {
      case 'music':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MusicScreen(
              musicService: widget.musicService,
              platformBridge: widget.platformBridge,
              storageService: widget.storageService,
              preferences: _preferences,
            ),
          ),
        );
        break;
      case 'apps':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AppLauncherScreen(platformBridge: widget.platformBridge),
          ),
        );
        break;
      case 'website':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebsiteStudioScreen(
              websiteGenerator: widget.websiteGenerator,
              storageService: widget.storageService,
              apiKey: _preferences.geminiApiKey,
              selectedModel: _preferences.selectedModel,
            ),
          ),
        );
        break;
      case 'tutor':
        _handleCommand('Explain quantum computing principles with analogies.');
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              storageService: widget.storageService,
              platformBridge: widget.platformBridge,
              ttsService: widget.ttsService,
              currentPreferences: _preferences,
              onPreferencesChanged: (p) => setState(() => _preferences = p),
            ),
          ),
        );
        break;
    }
  }

  void _openVoiceScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceScreen(
          speechService: widget.speechService,
          ttsService: widget.ttsService,
          reducedMotion: _preferences.reducedMotion,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      _handleCommand(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, color: CyberColors.primaryCyan, size: 20),
            const SizedBox(width: 8),
            const Text(
              'CYBER AI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CyberColors.glassFill,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: CyberColors.glassBorder),
              ),
              child: const Text(
                'v1.0',
                style: TextStyle(
                  fontSize: 9,
                  color: CyberColors.primaryCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: CyberColors.textSecondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    storageService: widget.storageService,
                    onClear: () {
                      setState(() {
                        _messages = [
                          ChatMessage(
                            id: 'welcome_reset',
                            sender: MessageSender.assistant,
                            text: 'History cleared. Cyber AI ready for your next mission.',
                            timestamp: DateTime.now(),
                          ),
                        ];
                      });
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: CyberColors.textSecondary),
            onPressed: () => _onQuickAction('settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Holographic Visualization Area
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ValueListenableBuilder<AssistantState>(
                    valueListenable: widget.speechService.stateNotifier,
                    builder: (context, state, _) {
                      return Column(
                        children: [
                          AssistantOrb(
                            state: _isLoading
                                ? AssistantState.processing
                                : state,
                            size: 110,
                            reducedMotion: _preferences.reducedMotion,
                          ),
                          const SizedBox(height: 10),
                          StatePill(
                            state: _isLoading
                                ? AssistantState.processing
                                : state,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Quick Actions Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: QuickActionBar(onActionSelected: _onQuickAction),
            ),

            const Divider(color: CyberColors.subtleDivider, height: 1),

            // Message Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return MessageBubble(
                    message: msg,
                    onActionTap:
                        msg.intent != null &&
                            msg.intent!.type == ActionType.createWebsite
                        ? () => _onQuickAction('website')
                        : null,
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: CyberColors.surface,
                border: Border(
                  top: BorderSide(color: CyberColors.glassBorder, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Mic button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CyberColors.glassFill,
                        border: Border.all(
                          color: CyberColors.primaryCyan.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: CyberColors.primaryCyan,
                        size: 20,
                      ),
                    ),
                    onPressed: _openVoiceScreen,
                  ),
                  const SizedBox(width: 8),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(
                        color: CyberColors.textPrimary,
                        fontSize: 14,
                      ),
                      onSubmitted: _handleCommand,
                      decoration: InputDecoration(
                        hintText: 'Enter command, prompt, or ask Cyber AI...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: widget.ttsService.isPlaying
                            ? IconButton(
                                icon: const Icon(
                                  Icons.volume_off,
                                  color: CyberColors.cyberRed,
                                  size: 18,
                                ),
                                onPressed: () async {
                                  await widget.ttsService.stop();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: CyberColors.cyberGradient,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF070B14),
                        size: 18,
                      ),
                    ),
                    onPressed: () => _handleCommand(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
