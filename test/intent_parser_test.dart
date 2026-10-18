import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_ai/core/utils/intent_parser.dart';
import 'package:cyber_ai/features/assistant/models/action_intent.dart';

void main() {
  group('IntentParser Tests', () {
    test('Identifies open app command for Chrome', () {
      final intent = IntentParser.parse('Open Chrome');
      expect(intent.type, ActionType.openApp);
      expect(intent.parameters['appName'], 'chrome');
      expect(intent.parameters['packageName'], 'com.android.chrome');
    });

    test('Identifies open music app command', () {
      final intent = IntentParser.parse('Open YouTube Music');
      expect(intent.type, ActionType.openMusicApp);
    });

    test('Identifies music search command', () {
      final intent = IntentParser.parse('Play relaxing ambient music');
      expect(intent.type, ActionType.searchMusic);
      expect(intent.parameters['query'], 'relaxing ambient music');
    });

    test('Identifies 3D website generation command', () {
      final intent = IntentParser.parse(
        'Create a 3D website for my clothing brand',
      );
      expect(intent.type, ActionType.createWebsite);
      expect(intent.parameters['is3D'], true);
    });

    test('Identifies settings command', () {
      final intent = IntentParser.parse('Go to settings');
      expect(intent.type, ActionType.openSettings);
    });

    test('Identifies stop speaking command', () {
      final intent = IntentParser.parse('Stop speaking');
      expect(intent.type, ActionType.stopSpeaking);
    });

    test('Defaults to educational / general conversation question', () {
      final intent = IntentParser.parse(
        'Explain the Calvin cycle in photosynthesis',
      );
      expect(intent.type, ActionType.answerQuestion);
    });

    test('Handles empty input gracefully', () {
      final intent = IntentParser.parse('   ');
      expect(intent.type, ActionType.unsupportedAction);
    });
  });
}
