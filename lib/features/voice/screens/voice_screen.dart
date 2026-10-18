import 'package:flutter/material.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../assistant/widgets/assistant_orb.dart';
import '../../assistant/widgets/state_pill.dart';

class VoiceScreen extends StatefulWidget {
  final SpeechService speechService;
  final TTSService ttsService;
  final bool reducedMotion;

  const VoiceScreen({
    super.key,
    required this.speechService,
    required this.ttsService,
    this.reducedMotion = false,
  });

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  String _recognizedWords = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startVoiceSession();
  }

  void _startVoiceSession() async {
    setState(() => _isListening = true);
    await widget.speechService.startListening(
      onResult: (words) {
        setState(() {
          _recognizedWords = words;
        });
        if (words.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              Navigator.pop(context, words);
            }
          });
        }
      },
      onTimeout: () {
        setState(() => _isListening = false);
      },
    );
  }

  void _stopListeningAndSubmit() async {
    await widget.speechService.stopListening();
    if (_recognizedWords.isNotEmpty && mounted) {
      Navigator.pop(context, _recognizedWords);
    } else {
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        title: const Text('VOICE INTERFACE'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: CyberColors.textSecondary),
          onPressed: () {
            widget.speechService.cancelListening();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Voice Assistant Visualization
              ValueListenableBuilder<AssistantState>(
                valueListenable: widget.speechService.stateNotifier,
                builder: (context, state, _) {
                  return Column(
                    children: [
                      AssistantOrb(
                        state: state,
                        size: 160,
                        reducedMotion: widget.reducedMotion,
                      ),
                      const SizedBox(height: 24),
                      StatePill(state: state),
                    ],
                  );
                },
              ),

              const SizedBox(height: 36),

              // Transcribed text display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CyberColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CyberColors.glassBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      _recognizedWords.isEmpty
                          ? 'Listening for your voice command...'
                          : _recognizedWords,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _recognizedWords.isEmpty
                            ? CyberColors.textMuted
                            : CyberColors.primaryCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Suggestion Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip('Explain photosynthesis'),
                  _buildSuggestionChip('Play relaxing music'),
                  _buildSuggestionChip('Open YouTube Music'),
                  _buildSuggestionChip('Build 3D sneaker store'),
                ],
              ),

              const Spacer(),

              // Mic Button Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_isListening) {
                        _stopListeningAndSubmit();
                      } else {
                        _startVoiceSession();
                      }
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: CyberColors.cyberGradient,
                        boxShadow: [
                          BoxShadow(
                            color: CyberColors.primaryCyan.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic,
                        color: const Color(0xFF070B14),
                        size: 34,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? 'Tap to finish' : 'Tap to speak',
                style: const TextStyle(
                  color: CyberColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: const TextStyle(color: CyberColors.textSecondary, fontSize: 12),
      ),
      backgroundColor: CyberColors.surface,
      side: const BorderSide(color: CyberColors.glassBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        widget.speechService.cancelListening();
        Navigator.pop(context, text);
      },
    );
  }
}
