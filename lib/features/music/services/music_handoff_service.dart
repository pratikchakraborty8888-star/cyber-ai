import 'package:cyber_ai/core/config/app_config.dart';
import 'package:cyber_ai/core/services/platform_bridge.dart';

import '../models/music_target.dart';

class MusicHandoffResult {
  final bool success;
  final String targetUsed;
  final String message;
  final bool usedFallback;

  const MusicHandoffResult({
    required this.success,
    required this.targetUsed,
    required this.message,
    required this.usedFallback,
  });
}

class MusicHandoffService {
  final PlatformBridge _bridge;

  MusicHandoffService(this._bridge);

  static const List<MusicTarget> defaultKnownTargets = [
    MusicTarget(
      id: 'revanced_music',
      displayName: 'YouTube Music ReVanced',
      packageName: AppConfig.pkgYouTubeMusicReVanced,
    ),
    MusicTarget(
      id: 'official_yt_music',
      displayName: 'YouTube Music (Official)',
      packageName: AppConfig.pkgYouTubeMusicOfficial,
    ),
    MusicTarget(
      id: 'revanced_yt',
      displayName: 'YouTube ReVanced',
      packageName: AppConfig.pkgYouTubeReVanced,
    ),
    MusicTarget(
      id: 'official_yt',
      displayName: 'YouTube (Official)',
      packageName: AppConfig.pkgYouTubeOfficial,
    ),
    MusicTarget(
      id: 'rvx_music',
      displayName: 'YouTube Music RVX',
      packageName: AppConfig.pkgYouTubeMusicRvx,
    ),
    MusicTarget(
      id: 'spotify',
      displayName: 'Spotify',
      packageName: 'com.spotify.music',
    ),
  ];

  /// Discover which music apps are currently installed
  Future<List<MusicTarget>> getAvailableTargets({
    List<String> customPackages = const [],
  }) async {
    final targets = <MusicTarget>[];

    for (final target in defaultKnownTargets) {
      final installed = await _bridge.isPackageInstalled(target.packageName);
      targets.add(target.copyWith(isInstalled: installed));
    }

    for (final customPkg in customPackages) {
      if (targets.any((t) => t.packageName == customPkg)) continue;
      final installed = await _bridge.isPackageInstalled(customPkg);
      targets.add(
        MusicTarget(
          id: customPkg,
          displayName: 'Custom ($customPkg)',
          packageName: customPkg,
          isInstalled: installed,
          isDefaultSupported: false,
        ),
      );
    }

    return targets;
  }

  /// Execute music search and handoff
  Future<MusicHandoffResult> searchAndPlay({
    required String query,
    required String preferredPackage,
  }) async {
    // 1. Try preferred package
    final isPreferredInstalled = await _bridge.isPackageInstalled(
      preferredPackage,
    );
    if (isPreferredInstalled) {
      final success = await _bridge.searchMusic(
        query,
        preferredPackage: preferredPackage,
      );
      if (success) {
        return MusicHandoffResult(
          success: true,
          targetUsed: preferredPackage,
          message: 'Launched search for "$query" in your preferred player.',
          usedFallback: false,
        );
      }
    }

    // 2. Try official YouTube Music
    if (preferredPackage != AppConfig.pkgYouTubeMusicOfficial) {
      final isOfficialInstalled = await _bridge.isPackageInstalled(
        AppConfig.pkgYouTubeMusicOfficial,
      );
      if (isOfficialInstalled) {
        final success = await _bridge.searchMusic(
          query,
          preferredPackage: AppConfig.pkgYouTubeMusicOfficial,
        );
        if (success) {
          return MusicHandoffResult(
            success: true,
            targetUsed: AppConfig.pkgYouTubeMusicOfficial,
            message:
                'Launched search in YouTube Music (fallback from missing $preferredPackage).',
            usedFallback: true,
          );
        }
      }
    }

    // 3. Try official YouTube
    final isYtInstalled = await _bridge.isPackageInstalled(
      AppConfig.pkgYouTubeOfficial,
    );
    if (isYtInstalled) {
      final success = await _bridge.searchMusic(
        query,
        preferredPackage: AppConfig.pkgYouTubeOfficial,
      );
      if (success) {
        return MusicHandoffResult(
          success: true,
          targetUsed: AppConfig.pkgYouTubeOfficial,
          message: 'Opened YouTube search for "$query" as fallback.',
          usedFallback: true,
        );
      }
    }

    // 4. Fallback to web browser
    final webSuccess = await _bridge.searchMusic(query, preferredPackage: null);
    return MusicHandoffResult(
      success: webSuccess,
      targetUsed: 'Web Browser',
      message: 'Music apps were not found; opened "$query" in web browser.',
      usedFallback: true,
    );
  }

  /// Launch music application directly
  Future<bool> launchMusicApp(String preferredPackage) async {
    final isInstalled = await _bridge.isPackageInstalled(preferredPackage);
    if (isInstalled) {
      return _bridge.launchApp(preferredPackage);
    }
    // Fallback to official
    final isOfficialInstalled = await _bridge.isPackageInstalled(
      AppConfig.pkgYouTubeMusicOfficial,
    );
    if (isOfficialInstalled) {
      return _bridge.launchApp(AppConfig.pkgYouTubeMusicOfficial);
    }
    // Fallback to browser
    return _bridge.openUrlInPackage('https://music.youtube.com');
  }
}
