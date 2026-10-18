import '../config/app_config.dart';
import '../../features/assistant/models/action_intent.dart';

class IntentParser {
  /// Known common apps and their standard Android package identifiers
  static const Map<String, String> commonAppPackages = {
    'chrome': 'com.android.chrome',
    'google chrome': 'com.android.chrome',
    'browser': 'com.android.chrome',
    'youtube': 'com.google.android.youtube',
    'youtube music': AppConfig.pkgYouTubeMusicReVanced,
    'yt music': AppConfig.pkgYouTubeMusicReVanced,
    'revanced': AppConfig.pkgYouTubeReVanced,
    'spotify': 'com.spotify.music',
    'whatsapp': 'com.whatsapp',
    'camera': 'com.android.camera',
    'settings': 'com.android.settings',
    'calculator': 'com.google.android.calculator',
    'clock': 'com.google.android.deskclock',
    'maps': 'com.google.android.apps.maps',
    'google maps': 'com.google.android.apps.maps',
    'gmail': 'com.google.android.gm',
    'play store': 'com.android.vending',
  };

  /// Parses an input string into an [ActionIntent].
  static ActionIntent parse(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) {
      return const ActionIntent(
        type: ActionType.unsupportedAction,
        rawQuery: '',
        directResponse: "I didn't catch that. How can I help you?",
      );
    }

    final lower = cleaned.toLowerCase();

    // 1. Stop speaking / silence commands
    if (lower == 'stop speaking' ||
        lower == 'stop talking' ||
        lower == 'silence' ||
        lower == 'be quiet' ||
        lower == 'shut up') {
      return ActionIntent(
        type: ActionType.stopSpeaking,
        rawQuery: cleaned,
        directResponse: 'Stopping voice playback.',
      );
    }

    // 2. Open Settings commands
    if (lower == 'go to settings' ||
        lower == 'open settings' ||
        lower == 'settings' ||
        lower.startsWith('open system settings')) {
      return ActionIntent(
        type: ActionType.openSettings,
        rawQuery: cleaned,
        parameters: {'settingType': 'general'},
        directResponse: 'Opening Settings.',
      );
    }

    // 3. Website generation commands
    // e.g., "create a portfolio website", "build a 3d website for my clothing brand"
    final websiteTriggers = [
      'create a website',
      'build a website',
      'make a website',
      'design a website',
      'generate a website',
      'create website',
      'build website',
      'create a 3d website',
      'build a 3d website',
      'create portfolio',
      'create landing page',
    ];

    for (final trigger in websiteTriggers) {
      if (lower.contains(trigger)) {
        String prompt = cleaned;
        return ActionIntent(
          type: ActionType.createWebsite,
          rawQuery: cleaned,
          parameters: {'prompt': prompt, 'is3D': lower.contains('3d')},
          directResponse:
              'Initializing Website Studio with your specification...',
        );
      }
    }

    if (lower.startsWith('create ') &&
        (lower.endsWith('website') ||
            lower.endsWith('site') ||
            lower.contains('store') ||
            lower.contains('portfolio') ||
            lower.contains('landing page'))) {
      return ActionIntent(
        type: ActionType.createWebsite,
        rawQuery: cleaned,
        parameters: {'prompt': cleaned, 'is3D': lower.contains('3d')},
        directResponse: 'Entering Website Studio to design your site.',
      );
    }

    // 4. Music commands
    // e.g., "play relaxing music", "open youtube music", "search for this song"
    if (lower == 'open youtube music' || lower == 'open yt music') {
      return ActionIntent(
        type: ActionType.openMusicApp,
        rawQuery: cleaned,
        directResponse: 'Opening YouTube Music.',
      );
    }

    if (lower.startsWith('play ') ||
        lower.startsWith('search music for ') ||
        lower.startsWith('search for song ') ||
        lower.startsWith('listen to ')) {
      String query = cleaned;
      if (lower.startsWith('play ')) {
        query = cleaned.substring(5).trim();
      } else if (lower.startsWith('search music for ')) {
        query = cleaned.substring(17).trim();
      } else if (lower.startsWith('search for song ')) {
        query = cleaned.substring(16).trim();
      } else if (lower.startsWith('listen to ')) {
        query = cleaned.substring(10).trim();
      }

      if (query.isEmpty) {
        query = 'Top music';
      }

      return ActionIntent(
        type: ActionType.searchMusic,
        rawQuery: cleaned,
        parameters: {'query': query},
        directResponse:
            'Searching for "$query" on your configured music player.',
      );
    }

    if (lower == 'search for this song' || lower == 'search music') {
      return ActionIntent(
        type: ActionType.searchMusic,
        rawQuery: cleaned,
        parameters: {'query': 'Trending music'},
        directResponse: 'Opening music search.',
      );
    }

    // 5. Open app commands
    // e.g., "open chrome", "launch camera"
    if (lower.startsWith('open ') || lower.startsWith('launch ')) {
      final appName = lower.startsWith('open ')
          ? lower.substring(5).trim()
          : lower.substring(7).trim();

      // Check if it's music or settings
      if (appName == 'settings') {
        return ActionIntent(
          type: ActionType.openSettings,
          rawQuery: cleaned,
          parameters: {'settingType': 'general'},
        );
      }
      if (appName == 'youtube music' || appName == 'yt music') {
        return ActionIntent(type: ActionType.openMusicApp, rawQuery: cleaned);
      }

      // Check common map
      final mappedPackage = commonAppPackages[appName];
      return ActionIntent(
        type: ActionType.openApp,
        rawQuery: cleaned,
        parameters: {'appName': appName, 'packageName': mappedPackage ?? ''},
        directResponse: 'Launching $appName...',
      );
    }

    // Default to general AI question / conversation
    return ActionIntent(type: ActionType.answerQuestion, rawQuery: cleaned);
  }
}
