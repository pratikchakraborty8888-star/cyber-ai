import 'package:flutter/material.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/cyber_colors.dart';

class StatePill extends StatelessWidget {
  final AssistantState state;

  const StatePill({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    String label;
    IconData icon;

    switch (state) {
      case AssistantState.idle:
        indicatorColor = CyberColors.primaryCyan;
        label = 'CYBER AI READY';
        icon = Icons.radio_button_checked;
        break;
      case AssistantState.listening:
        indicatorColor = CyberColors.primaryCyan;
        label = 'LISTENING...';
        icon = Icons.mic;
        break;
      case AssistantState.processing:
        indicatorColor = CyberColors.neonViolet;
        label = 'PROCESSING...';
        icon = Icons.memory;
        break;
      case AssistantState.speaking:
        indicatorColor = CyberColors.matrixGreen;
        label = 'SPEAKING...';
        icon = Icons.volume_up;
        break;
      case AssistantState.error:
        indicatorColor = CyberColors.cyberRed;
        label = 'ALERT';
        icon = Icons.warning_amber_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: indicatorColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: indicatorColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: indicatorColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
