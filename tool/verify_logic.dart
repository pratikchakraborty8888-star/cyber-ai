import 'dart:convert';

import '../lib/core/config/app_config.dart';
import '../lib/core/utils/intent_parser.dart';
import '../lib/features/assistant/models/action_intent.dart';
import '../lib/features/websites/models/website_spec.dart';
import '../lib/features/websites/services/template_engine.dart';
import '../lib/features/websites/services/code_generator.dart';
import '../lib/features/websites/services/security_validator.dart';
import '../lib/models/user_preferences.dart';

void main() {
  print('====================================================');
  print('CYBER AI LOGIC & VALIDATION VERIFICATION');
  print('====================================================\n');

  int passed = 0;
  int failed = 0;

  void assertTest(String description, bool condition) {
    if (condition) {
      print(' [PASS] $description');
      passed++;
    } else {
      print(' [FAIL] $description');
      failed++;
    }
  }

  // 1. Intent Parser Tests
  print('--- Testing Intent Classification ---');
  final intent1 = IntentParser.parse('Open Chrome');
  assertTest(
    'Open Chrome resolves to openApp with com.android.chrome',
    intent1.type == ActionType.openApp &&
        intent1.parameters['packageName'] == 'com.android.chrome',
  );

  final intent2 = IntentParser.parse('Open YouTube Music');
  assertTest(
    'Open YouTube Music resolves to openMusicApp',
    intent2.type == ActionType.openMusicApp,
  );

  final intent3 = IntentParser.parse('Play relaxing ambient music');
  assertTest(
    'Play music resolves to searchMusic with query',
    intent3.type == ActionType.searchMusic &&
        intent3.parameters['query'] == 'relaxing ambient music',
  );

  final intent4 = IntentParser.parse(
    'Create a 3D website for my clothing brand',
  );
  assertTest(
    'Create 3D website resolves to createWebsite with 3D flag',
    intent4.type == ActionType.createWebsite &&
        intent4.parameters['is3D'] == true,
  );

  final intent5 = IntentParser.parse('Go to settings');
  assertTest(
    'Go to settings resolves to openSettings',
    intent5.type == ActionType.openSettings,
  );

  final intent6 = IntentParser.parse('Stop speaking');
  assertTest(
    'Stop speaking resolves to stopSpeaking',
    intent6.type == ActionType.stopSpeaking,
  );

  final intent7 = IntentParser.parse(
    'Explain the Calvin cycle in photosynthesis',
  );
  assertTest(
    'Explain photosynthesis resolves to answerQuestion',
    intent7.type == ActionType.answerQuestion,
  );

  // 2. Template Engine & 3D CSS Tests
  print('\n--- Testing 3D Website Studio Engine ---');
  final sneakerSpec = TemplateEngine.inferSpecification(
    'Build a 3D sneaker store',
  );
  assertTest(
    'Sneaker store infers ecommerce layout',
    sneakerSpec.layoutType == LayoutType.ecommerce,
  );
  assertTest(
    'Sneaker store enables 3D transforms',
    sneakerSpec.enable3DEffects == true,
  );
  assertTest(
    'Sneaker store assigns luxury gold/obsidian palette',
    sneakerSpec.primaryColor == '#f59e0b',
  );

  final portfolioSpec = TemplateEngine.inferSpecification(
    'Create a cinematic portfolio for a photographer',
  );
  assertTest(
    'Portfolio infers portfolio layout',
    portfolioSpec.layoutType == LayoutType.portfolio,
  );

  final generatedHtml = CodeGenerator.generateFullHtml(sneakerSpec);
  assertTest(
    'Generated full HTML includes doctype and viewport',
    generatedHtml.contains('<!DOCTYPE html>') &&
        generatedHtml.contains('name="viewport"'),
  );
  assertTest(
    'Generated CSS includes genuine 3D perspective',
    generatedHtml.contains('perspective: 1200px') &&
        generatedHtml.contains('transform-style: preserve-3d'),
  );
  assertTest(
    'Generated code includes interactive 3D card tilt JS',
    generatedHtml.contains('perspective(1000px) rotateX('),
  );

  // 3. Security Validator Tests
  print('\n--- Testing Security Sandboxing & Validation ---');
  final cleanResult = SecurityValidator.validate(generatedHtml);
  assertTest(
    'Generated website passes strict security validation',
    cleanResult.isValid,
  );

  final maliciousPayload = '''
  <html>
    <body>
      <script>window.Android.readUserData();</script>
      <a href="intent:#Intent;package=com.target;end">Click</a>
      <iframe src="file:///sdcard/keys"></iframe>
    </body>
  </html>
  ''';
  final badResult = SecurityValidator.validate(maliciousPayload);
  assertTest(
    'Validator catches and rejects window.Android attack',
    !badResult.isValid &&
        badResult.violations.any(
          (v) => v.toLowerCase().contains('window.android'),
        ),
  );
  assertTest(
    'Validator catches and rejects intent: attack',
    badResult.violations.any((v) => v.contains('intent:')),
  );
  assertTest(
    'Validator catches and rejects file:// attack',
    badResult.violations.any((v) => v.contains('file://')),
  );

  final sanitizedHrefResult = SecurityValidator.validate(
    '<a href="javascript:alert(1)">Click</a>',
  );
  assertTest(
    'Validator sanitizes dangerous javascript: href',
    sanitizedHrefResult.sanitizedHtml.contains('href="#safe-'),
  );

  // 4. User Preferences Tests
  print('\n--- Testing User Preferences & Persistence ---');
  const prefs = UserPreferences(
    geminiApiKey: 'AIzaSyVerifiedSecret',
    selectedModel: 'gemini-1.5-pro',
    preferredMusicPackage: AppConfig.pkgYouTubeMusicReVanced,
    speechRate: 0.8,
    speechVolume: 0.9,
    spokenResponsesEnabled: true,
    reducedMotion: true,
  );
  assertTest('Preferences recognizes configured API key', prefs.hasApiKey);

  final json = prefs.toJson();
  final restored = UserPreferences.fromJson(json);
  assertTest(
    'Preferences round-trips through JSON without data loss',
    restored.geminiApiKey == prefs.geminiApiKey &&
        restored.selectedModel == prefs.selectedModel &&
        restored.reducedMotion == prefs.reducedMotion,
  );

  print('\n====================================================');
  print('SUMMARY: $passed Passed, $failed Failed');
  print('====================================================');

  if (failed > 0) {
    throw Exception('One or more logic verification checks failed.');
  }
}
