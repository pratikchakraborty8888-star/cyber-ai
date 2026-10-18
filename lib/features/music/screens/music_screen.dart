import 'package:flutter/material.dart';

import '../../../core/services/platform_bridge.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../models/user_preferences.dart';
import '../../../widgets/cyber_button.dart';
import '../../../widgets/cyber_card.dart';
import '../models/music_target.dart';
import '../services/music_handoff_service.dart';

class MusicScreen extends StatefulWidget {
  final MusicHandoffService musicService;
  final PlatformBridge platformBridge;
  final StorageService storageService;
  final UserPreferences preferences;

  const MusicScreen({
    super.key,
    required this.musicService,
    required this.platformBridge,
    required this.storageService,
    required this.preferences,
  });

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customPackageController =
      TextEditingController();
  List<MusicTarget> _targets = [];
  String _selectedPackage = '';
  bool _isLoading = true;
  String? _lastResultFeedback;

  @override
  void initState() {
    super.initState();
    _selectedPackage = widget.preferences.preferredMusicPackage;
    _loadMusicTargets();
  }

  Future<void> _loadMusicTargets() async {
    setState(() => _isLoading = true);
    final targets = await widget.musicService.getAvailableTargets(
      customPackages: widget.preferences.customMusicPackages,
    );
    setState(() {
      _targets = targets;
      _isLoading = false;
    });
  }

  Future<void> _selectTarget(String pkg) async {
    setState(() => _selectedPackage = pkg);
    final updated = widget.preferences.copyWith(preferredMusicPackage: pkg);
    await widget.storageService.savePreferences(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preferred music player set to $pkg'),
          backgroundColor: CyberColors.surface,
        ),
      );
    }
  }

  Future<void> _addCustomPackage() async {
    final pkg = _customPackageController.text.trim();
    if (pkg.isEmpty) return;
    _customPackageController.clear();

    final customList = List<String>.from(widget.preferences.customMusicPackages)
      ..add(pkg);
    final updated = widget.preferences.copyWith(
      customMusicPackages: customList,
      preferredMusicPackage: pkg,
    );
    await widget.storageService.savePreferences(updated);
    await _loadMusicTargets();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final result = await widget.musicService.searchAndPlay(
      query: query,
      preferredPackage: _selectedPackage,
    );

    setState(() {
      _lastResultFeedback = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(title: const Text('MUSIC & REVANCED ROUTING')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: CyberColors.primaryCyan),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Music Search Card
                CyberCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: CyberColors.primaryCyan,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'MUSIC SEARCH & HANDOFF',
                            style: TextStyle(
                              color: CyberColors.primaryCyan,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: CyberColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Enter artist, song, album, or genre...',
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.play_circle_fill,
                              color: CyberColors.primaryCyan,
                            ),
                            onPressed: _performSearch,
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                      if (_lastResultFeedback != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CyberColors.glassFill,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CyberColors.glassBorder),
                          ),
                          child: Text(
                            _lastResultFeedback!,
                            style: const TextStyle(
                              color: CyberColors.primaryCyan,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'TARGET APPLICATIONS',
                  style: TextStyle(
                    color: CyberColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                ..._targets.map((target) {
                  final isSelected = target.packageName == _selectedPackage;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CyberCard(
                      borderColor: isSelected
                          ? CyberColors.primaryCyan
                          : CyberColors.glassBorder,
                      backgroundColor: isSelected
                          ? CyberColors.primaryCyan.withOpacity(0.08)
                          : null,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      onTap: () => _selectTarget(target.packageName),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: target.packageName,
                            groupValue: _selectedPackage,
                            activeColor: CyberColors.primaryCyan,
                            onChanged: (val) {
                              if (val != null) _selectTarget(val);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  target.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: CyberColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  target.packageName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: CyberColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: target.isInstalled
                                  ? CyberColors.matrixGreen.withOpacity(0.15)
                                  : CyberColors.textMuted.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              target.isInstalled ? 'INSTALLED' : 'NOT DETECTED',
                              style: TextStyle(
                                color: target.isInstalled
                                    ? CyberColors.matrixGreen
                                    : CyberColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.open_in_new,
                              size: 18,
                              color: CyberColors.primaryCyan,
                            ),
                            tooltip: 'Test Launch',
                            onPressed: () => widget.platformBridge.launchApp(
                              target.packageName,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Add Custom Package Card
                CyberCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ADD CUSTOM REVANCED OR FORK PACKAGE',
                        style: TextStyle(
                          color: CyberColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customPackageController,
                              style: const TextStyle(
                                color: CyberColors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'e.g. app.rvx.android.apps.youtube.music',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CyberButton(
                            text: 'ADD',
                            onPressed: _addCustomPackage,
                            variant: CyberButtonVariant.outline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
