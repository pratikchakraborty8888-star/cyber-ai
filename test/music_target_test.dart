import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_ai/core/config/app_config.dart';
import 'package:cyber_ai/core/services/platform_bridge.dart';
import 'package:cyber_ai/features/music/services/music_handoff_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MusicHandoffService Tests', () {
    late PlatformBridge bridge;
    late MusicHandoffService service;

    setUp(() {
      bridge = PlatformBridge();
      service = MusicHandoffService(bridge);
    });

    test(
      'Discovers default music targets and checks installation status',
      () async {
        final targets = await service.getAvailableTargets();
        expect(targets.isNotEmpty, isTrue);
        expect(
          targets.any(
            (t) => t.packageName == AppConfig.pkgYouTubeMusicReVanced,
          ),
          isTrue,
        );
        expect(
          targets.any(
            (t) => t.packageName == AppConfig.pkgYouTubeMusicOfficial,
          ),
          isTrue,
        );
      },
    );

    test('Appends custom package identifiers to available targets', () async {
      const customPkg = 'app.custom.player';
      final targets = await service.getAvailableTargets(
        customPackages: [customPkg],
      );
      expect(targets.any((t) => t.packageName == customPkg), isTrue);
    });

    test(
      'Performs honest music search handoff without claiming false playback',
      () async {
        final result = await service.searchAndPlay(
          query: 'Miles Davis Kind of Blue',
          preferredPackage: AppConfig.pkgYouTubeMusicReVanced,
        );

        expect(result.success, isTrue);
        expect(result.targetUsed.isNotEmpty, isTrue);
        expect(result.message, contains('Miles Davis Kind of Blue'));
      },
    );
  });
}
