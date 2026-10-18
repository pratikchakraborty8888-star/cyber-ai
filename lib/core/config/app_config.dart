class AppConfig {
  static const String appName = 'Cyber AI';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Gemini Model Options
  static const String defaultGeminiModel = 'gemini-1.5-flash';
  static const List<String> supportedModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash-exp',
  ];

  // API Configuration
  static const int apiTimeoutSeconds = 15;
  static const int maxApiRetries = 2;

  // Music App Packages
  static const String pkgYouTubeMusicReVanced =
      'app.revanced.android.apps.youtube.music';
  static const String pkgYouTubeReVanced = 'app.revanced.android.youtube';
  static const String pkgYouTubeMusicOfficial =
      'com.google.android.apps.youtube.music';
  static const String pkgYouTubeOfficial = 'com.google.android.youtube';
  static const String pkgYouTubeMusicRvx = 'app.rvx.android.apps.youtube.music';

  static const List<String> defaultMusicTargets = [
    pkgYouTubeMusicReVanced,
    pkgYouTubeMusicOfficial,
    pkgYouTubeMusicRvx,
  ];

  // System Settings Types
  static const List<String> supportedSettingsTypes = [
    'general',
    'application_details',
    'wifi',
    'bluetooth',
    'sound',
    'display',
  ];
}
