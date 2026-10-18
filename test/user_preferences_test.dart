import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_ai/models/user_preferences.dart';
import 'package:cyber_ai/core/config/app_config.dart';

void main() {
  group('UserPreferences Tests', () {
    test('Default values are initialized properly', () {
      const prefs = UserPreferences();
      expect(prefs.selectedModel, AppConfig.defaultGeminiModel);
      expect(prefs.preferredMusicPackage, AppConfig.pkgYouTubeMusicReVanced);
      expect(prefs.spokenResponsesEnabled, isTrue);
      expect(prefs.reducedMotion, isFalse);
      expect(prefs.hasApiKey, isFalse);
    });

    test('copyWith updates specified fields', () {
      const prefs = UserPreferences();
      final updated = prefs.copyWith(
        geminiApiKey: 'AIzaSyTest123',
        reducedMotion: true,
        speechRate: 0.8,
      );

      expect(updated.geminiApiKey, 'AIzaSyTest123');
      expect(updated.hasApiKey, isTrue);
      expect(updated.reducedMotion, isTrue);
      expect(updated.speechRate, 0.8);
      expect(updated.selectedModel, prefs.selectedModel);
    });

    test('JSON serialization round-trip', () {
      const original = UserPreferences(
        geminiApiKey: 'secret_key',
        selectedModel: 'gemini-1.5-pro',
        preferredMusicPackage: 'app.revanced.android.apps.youtube.music',
        speechRate: 0.75,
        speechVolume: 0.9,
        spokenResponsesEnabled: false,
        reducedMotion: true,
        hapticFeedback: false,
        customMusicPackages: ['custom.pkg.music'],
        openLinksInChooser: true,
      );

      final json = original.toJson();
      final reconstituted = UserPreferences.fromJson(json);

      expect(reconstituted.geminiApiKey, original.geminiApiKey);
      expect(reconstituted.selectedModel, original.selectedModel);
      expect(
        reconstituted.preferredMusicPackage,
        original.preferredMusicPackage,
      );
      expect(reconstituted.speechRate, original.speechRate);
      expect(reconstituted.speechVolume, original.speechVolume);
      expect(
        reconstituted.spokenResponsesEnabled,
        original.spokenResponsesEnabled,
      );
      expect(reconstituted.reducedMotion, original.reducedMotion);
      expect(reconstituted.hapticFeedback, original.hapticFeedback);
      expect(reconstituted.customMusicPackages, original.customMusicPackages);
      expect(reconstituted.openLinksInChooser, original.openLinksInChooser);
    });
  });
}
