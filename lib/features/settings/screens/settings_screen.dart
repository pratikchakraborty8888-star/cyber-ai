import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/platform_bridge.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../models/user_preferences.dart';
import '../../../widgets/cyber_button.dart';
import '../../../widgets/cyber_card.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  final PlatformBridge platformBridge;
  final TTSService ttsService;
  final UserPreferences currentPreferences;
  final Function(UserPreferences updated) onPreferencesChanged;

  const SettingsScreen({
    super.key,
    required this.storageService,
    required this.platformBridge,
    required this.ttsService,
    required this.currentPreferences,
    required this.onPreferencesChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late String _selectedModel;
  late String _preferredMusicPackage;
  late double _speechRate;
  late double _speechVolume;
  late bool _spokenResponsesEnabled;
  late bool _reducedMotion;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final p = widget.currentPreferences;
    _apiKeyController = TextEditingController(text: p.geminiApiKey ?? '');
    _selectedModel = p.selectedModel;
    _preferredMusicPackage = p.preferredMusicPackage;
    _speechRate = p.speechRate;
    _speechVolume = p.speechVolume;
    _spokenResponsesEnabled = p.spokenResponsesEnabled;
    _reducedMotion = p.reducedMotion;
  }

  Future<void> _saveSettings() async {
    final updated = widget.currentPreferences.copyWith(
      geminiApiKey: _apiKeyController.text.trim().isEmpty
          ? null
          : _apiKeyController.text.trim(),
      selectedModel: _selectedModel,
      preferredMusicPackage: _preferredMusicPackage,
      speechRate: _speechRate,
      speechVolume: _speechVolume,
      spokenResponsesEnabled: _spokenResponsesEnabled,
      reducedMotion: _reducedMotion,
    );

    await widget.storageService.savePreferences(updated);
    await widget.ttsService.updateSettings(
      rate: _speechRate,
      volume: _speechVolume,
    );
    widget.onPreferencesChanged(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: CyberColors.matrixGreen,
        ),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CyberColors.cardSurface,
        title: const Text(
          'Clear All Local Data?',
          style: TextStyle(color: CyberColors.textPrimary),
        ),
        content: const Text(
          'This will permanently delete all locally stored conversation history and generated website projects. Your preferences and API key will be kept.',
          style: TextStyle(color: CyberColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: CyberColors.textMuted),
            ),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: const Text(
              'Clear Data',
              style: TextStyle(color: CyberColors.cyberRed),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All conversation and project records removed.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        title: const Text('CYBER AI SETTINGS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: CyberColors.primaryCyan),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. AI API Configuration
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.vpn_key,
                      color: CyberColors.primaryCyan,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'GEMINI API CONFIGURATION',
                      style: TextStyle(
                        color: CyberColors.primaryCyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Configure your personal Gemini API key. Stored securely on your device.',
                  style: TextStyle(color: CyberColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  style: const TextStyle(
                    color: CyberColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Gemini API Key (e.g. AIzaSy...)',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: CyberColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI MODEL SELECTION',
                  style: TextStyle(
                    color: CyberColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedModel,
                  dropdownColor: CyberColors.cardSurface,
                  style: const TextStyle(
                    color: CyberColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(isDense: true),
                  items: AppConfig.supportedModels.map((model) {
                    return DropdownMenuItem(value: model, child: Text(model));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedModel = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Voice & Speech Settings
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.record_voice_over,
                      color: CyberColors.neonViolet,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'VOICE & AUDIO SETTINGS',
                      style: TextStyle(
                        color: CyberColors.neonViolet,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Spoken Responses',
                    style: TextStyle(
                      color: CyberColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Read assistant responses aloud automatically',
                    style: TextStyle(
                      color: CyberColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  value: _spokenResponsesEnabled,
                  activeColor: CyberColors.primaryCyan,
                  onChanged: (val) =>
                      setState(() => _spokenResponsesEnabled = val),
                ),
                const SizedBox(height: 10),
                Text(
                  'Speech Rate: ${_speechRate.toStringAsFixed(2)}x',
                  style: const TextStyle(
                    color: CyberColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Slider(
                  value: _speechRate,
                  min: 0.2,
                  max: 1.0,
                  divisions: 8,
                  activeColor: CyberColors.primaryCyan,
                  inactiveColor: CyberColors.glassBorder,
                  onChanged: (val) => setState(() => _speechRate = val),
                ),
                Text(
                  'Speech Volume: ${(_speechVolume * 100).toInt()}%',
                  style: const TextStyle(
                    color: CyberColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Slider(
                  value: _speechVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: CyberColors.neonViolet,
                  inactiveColor: CyberColors.glassBorder,
                  onChanged: (val) => setState(() => _speechVolume = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. UI and Motion
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.motion_photos_off,
                      color: CyberColors.matrixGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ACCESSIBILITY & MOTION',
                      style: TextStyle(
                        color: CyberColors.matrixGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Reduced Motion',
                    style: TextStyle(
                      color: CyberColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Minimize continuous 3D rotations and glowing animations',
                    style: TextStyle(
                      color: CyberColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  value: _reducedMotion,
                  activeColor: CyberColors.matrixGreen,
                  onChanged: (val) => setState(() => _reducedMotion = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 4. Privacy & System Links
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: CyberColors.cyberAmber,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'PRIVACY & ANDROID INTEGRATION',
                      style: TextStyle(
                        color: CyberColors.cyberAmber,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.settings_applications,
                    color: CyberColors.primaryCyan,
                  ),
                  title: const Text(
                    'Open Android System Settings',
                    style: TextStyle(
                      color: CyberColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: CyberColors.textMuted,
                  ),
                  onTap: () => widget.platformBridge.openSystemSettings(),
                ),
                const Divider(color: CyberColors.subtleDivider),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_forever,
                    color: CyberColors.cyberRed,
                  ),
                  title: const Text(
                    'Clear All Local Data',
                    style: TextStyle(color: CyberColors.cyberRed, fontSize: 14),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: CyberColors.textMuted,
                  ),
                  onTap: _clearAllData,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          CyberButton(
            text: 'SAVE PREFERENCES',
            icon: Icons.check,
            onPressed: _saveSettings,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
