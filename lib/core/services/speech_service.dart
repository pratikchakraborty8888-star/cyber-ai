import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum AssistantState { idle, listening, processing, speaking, error }

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  AssistantState _state = AssistantState.idle;

  final ValueNotifier<AssistantState> stateNotifier = ValueNotifier(
    AssistantState.idle,
  );
  final ValueNotifier<String> wordsNotifier = ValueNotifier('');

  AssistantState get state => _state;
  bool get isAvailable => _isAvailable;

  void setState(AssistantState newState) {
    _state = newState;
    stateNotifier.value = newState;
  }

  /// Initialize speech recognition safely
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (errorNotification) {
          setState(AssistantState.error);
        },
        onStatus: (status) {
          if (status == 'listening') {
            setState(AssistantState.listening);
          } else if (status == 'notListening' &&
              _state == AssistantState.listening) {
            setState(AssistantState.processing);
          }
        },
      );
      return _isAvailable;
    } catch (_) {
      _isAvailable = false;
      return false;
    }
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String words) onResult,
    required VoidCallback onTimeout,
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) {
        setState(AssistantState.error);
        onTimeout();
        return;
      }
    }

    wordsNotifier.value = '';
    setState(AssistantState.listening);

    try {
      await _speech.listen(
        onResult: (result) {
          wordsNotifier.value = result.recognizedWords;
          if (result.finalResult) {
            setState(AssistantState.processing);
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );
    } catch (_) {
      setState(AssistantState.error);
      onTimeout();
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    if (_state == AssistantState.listening) {
      setState(AssistantState.idle);
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (_) {}
    setState(AssistantState.idle);
  }
}
