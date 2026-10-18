import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> initialize({double rate = 0.5, double volume = 1.0}) async {
    try {
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(volume);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isPlaying = true;
      });

      _tts.setCompletionHandler(() {
        _isPlaying = false;
      });

      _tts.setCancelHandler(() {
        _isPlaying = false;
      });

      _tts.setErrorHandler((_) {
        _isPlaying = false;
      });
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      _isPlaying = true;
      await _tts.speak(text);
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> updateSettings({double? rate, double? volume}) async {
    try {
      if (rate != null) await _tts.setSpeechRate(rate);
      if (volume != null) await _tts.setVolume(volume);
    } catch (_) {}
  }
}
