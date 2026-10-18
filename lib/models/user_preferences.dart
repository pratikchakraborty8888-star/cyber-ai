import '../core/config/app_config.dart';

class UserPreferences {
  final String? geminiApiKey;
  final String selectedModel;
  final String preferredMusicPackage;
  final double speechRate;
  final double speechVolume;
  final bool spokenResponsesEnabled;
  final bool reducedMotion;
  final bool hapticFeedback;
  final List<String> customMusicPackages;
  final bool openLinksInChooser;

  const UserPreferences({
    this.geminiApiKey,
    this.selectedModel = AppConfig.defaultGeminiModel,
    this.preferredMusicPackage = AppConfig.pkgYouTubeMusicReVanced,
    this.speechRate = 0.5,
    this.speechVolume = 1.0,
    this.spokenResponsesEnabled = true,
    this.reducedMotion = false,
    this.hapticFeedback = true,
    this.customMusicPackages = const [],
    this.openLinksInChooser = false,
  });

  bool get hasApiKey => geminiApiKey != null && geminiApiKey!.trim().isNotEmpty;

  UserPreferences copyWith({
    String? geminiApiKey,
    String? selectedModel,
    String? preferredMusicPackage,
    double? speechRate,
    double? speechVolume,
    bool? spokenResponsesEnabled,
    bool? reducedMotion,
    bool? hapticFeedback,
    List<String>? customMusicPackages,
    bool? openLinksInChooser,
  }) {
    return UserPreferences(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      selectedModel: selectedModel ?? this.selectedModel,
      preferredMusicPackage:
          preferredMusicPackage ?? this.preferredMusicPackage,
      speechRate: speechRate ?? this.speechRate,
      speechVolume: speechVolume ?? this.speechVolume,
      spokenResponsesEnabled:
          spokenResponsesEnabled ?? this.spokenResponsesEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      customMusicPackages: customMusicPackages ?? this.customMusicPackages,
      openLinksInChooser: openLinksInChooser ?? this.openLinksInChooser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geminiApiKey': geminiApiKey,
      'selectedModel': selectedModel,
      'preferredMusicPackage': preferredMusicPackage,
      'speechRate': speechRate,
      'speechVolume': speechVolume,
      'spokenResponsesEnabled': spokenResponsesEnabled,
      'reducedMotion': reducedMotion,
      'hapticFeedback': hapticFeedback,
      'customMusicPackages': customMusicPackages,
      'openLinksInChooser': openLinksInChooser,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      geminiApiKey: json['geminiApiKey'] as String?,
      selectedModel:
          (json['selectedModel'] as String?) ?? AppConfig.defaultGeminiModel,
      preferredMusicPackage:
          (json['preferredMusicPackage'] as String?) ??
          AppConfig.pkgYouTubeMusicReVanced,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.5,
      speechVolume: (json['speechVolume'] as num?)?.toDouble() ?? 1.0,
      spokenResponsesEnabled: (json['spokenResponsesEnabled'] as bool?) ?? true,
      reducedMotion: (json['reducedMotion'] as bool?) ?? false,
      hapticFeedback: (json['hapticFeedback'] as bool?) ?? true,
      customMusicPackages:
          (json['customMusicPackages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      openLinksInChooser: (json['openLinksInChooser'] as bool?) ?? false,
    );
  }
}
