import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/cyber_colors.dart';
import '../models/chat_message.dart';
import '../models/action_intent.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onActionTap;

  const MessageBubble({super.key, required this.message, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 4, right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: CyberColors.cyberGradient,
              ),
              child: const Icon(Icons.bolt, size: 18, color: Color(0xFF070B14)),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? CyberColors.electricBlue.withOpacity(0.2)
                    : CyberColors.cardSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUser
                      ? CyberColors.electricBlue.withOpacity(0.5)
                      : message.isError
                      ? CyberColors.cyberRed.withOpacity(0.6)
                      : CyberColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.intent != null &&
                      message.intent!.type != ActionType.answerQuestion) ...[
                    _buildIntentBadge(message.intent!.type),
                    const SizedBox(height: 6),
                  ],
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: message.isError
                          ? CyberColors.cyberRed
                          : CyberColors.textPrimary,
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: CyberColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 12,
                          color: CyberColors.textMuted,
                        ),
                      ),
                      if (onActionTap != null) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: onActionTap,
                          child: const Text(
                            'VIEW DETAILS',
                            style: TextStyle(
                              color: CyberColors.primaryCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentBadge(ActionType type) {
    String label = '';
    Color color = CyberColors.primaryCyan;

    switch (type) {
      case ActionType.openApp:
        label = 'ACTION: APP LAUNCH';
        color = CyberColors.primaryCyan;
        break;
      case ActionType.searchMusic:
      case ActionType.openMusicApp:
        label = 'ACTION: MUSIC HANDOFF';
        color = CyberColors.neonViolet;
        break;
      case ActionType.createWebsite:
        label = 'ACTION: WEBSITE STUDIO';
        color = CyberColors.matrixGreen;
        break;
      case ActionType.openSettings:
        label = 'ACTION: SETTINGS';
        color = CyberColors.cyberAmber;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
