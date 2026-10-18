import 'package:flutter/material.dart';

import '../../../core/theme/cyber_colors.dart';

class QuickActionBar extends StatelessWidget {
  final Function(String action) onActionSelected;

  const QuickActionBar({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'YouTube Music', 'icon': Icons.music_note, 'id': 'music'},
      {'label': 'App Launcher', 'icon': Icons.apps, 'id': 'apps'},
      {'label': '3D Website Studio', 'icon': Icons.language, 'id': 'website'},
      {'label': 'AI Tutor', 'icon': Icons.school, 'id': 'tutor'},
      {'label': 'Settings', 'icon': Icons.settings, 'id': 'settings'},
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = actions[index];
          return ActionChip(
            avatar: Icon(
              item['icon'] as IconData,
              size: 16,
              color: CyberColors.primaryCyan,
            ),
            label: Text(
              item['label'] as String,
              style: const TextStyle(
                color: CyberColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: CyberColors.cardSurface,
            side: const BorderSide(color: CyberColors.glassBorder, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => onActionSelected(item['id'] as String),
          );
        },
      ),
    );
  }
}
