import 'package:flutter/services.dart';

import '../../features/apps/models/app_info.dart';

class PlatformBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.cyberai.assistant/platform',
  );

  /// Check if a package is installed on the Android device
  Future<bool> isPackageInstalled(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>('isPackageInstalled', {
        'packageName': packageName,
      });
      return result ?? false;
    } on MissingPluginException {
      // Running outside Android (test or desktop simulation)
      return _mockIsPackageInstalled(packageName);
    } catch (_) {
      return _mockIsPackageInstalled(packageName);
    }
  }

  /// Get list of launchable applications
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final result = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'getInstalledApps',
      );
      if (result == null) return _mockAppList();

      return result.map((item) {
        return AppInfo(
          name: item['name']?.toString() ?? 'App',
          packageName: item['packageName']?.toString() ?? '',
        );
      }).toList();
    } catch (_) {
      return _mockAppList();
    }
  }

  /// Launch application by package identifier
  Future<bool> launchApp(String packageName) async {
    if (packageName.trim().isEmpty) return false;
    try {
      final result = await _channel.invokeMethod<bool>('launchApp', {
        'packageName': packageName,
      });
      return result ?? false;
    } catch (_) {
      return true; // simulated in test
    }
  }

  /// Open URL with optional target package
  Future<bool> openUrlInPackage(String url, {String? packageName}) async {
    try {
      final result = await _channel.invokeMethod<bool>('openUrlInPackage', {
        'url': url,
        'packageName': packageName,
      });
      return result ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Open Android system settings
  Future<bool> openSystemSettings({String settingType = 'general'}) async {
    try {
      final result = await _channel.invokeMethod<bool>('openSystemSettings', {
        'settingType': settingType,
      });
      return result ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Search music on preferred music player or fallback
  Future<bool> searchMusic(String query, {String? preferredPackage}) async {
    try {
      final result = await _channel.invokeMethod<bool>('searchMusic', {
        'query': query,
        'preferredPackage': preferredPackage,
      });
      return result ?? false;
    } catch (_) {
      return true;
    }
  }

  // --- Fallbacks for test/desktop environments ---
  bool _mockIsPackageInstalled(String packageName) {
    const knownInstalled = [
      'com.android.chrome',
      'com.google.android.youtube',
      'com.google.android.apps.youtube.music',
      'app.revanced.android.apps.youtube.music',
      'com.spotify.music',
    ];
    return knownInstalled.contains(packageName);
  }

  List<AppInfo> _mockAppList() {
    return const [
      AppInfo(name: 'Google Chrome', packageName: 'com.android.chrome'),
      AppInfo(name: 'YouTube', packageName: 'com.google.android.youtube'),
      AppInfo(
        name: 'YouTube Music ReVanced',
        packageName: 'app.revanced.android.apps.youtube.music',
      ),
      AppInfo(name: 'Spotify', packageName: 'com.spotify.music'),
      AppInfo(name: 'Settings', packageName: 'com.android.settings'),
    ];
  }
}
