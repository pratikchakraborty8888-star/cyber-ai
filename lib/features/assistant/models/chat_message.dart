import 'action_intent.dart';

enum MessageSender { user, assistant, system }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final ActionIntent? intent;
  final Map<String, dynamic>? metadata;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.intent,
    this.metadata,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.assistant,
      ),
      text: json['text'] as String,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isError: (json['isError'] as bool?) ?? false,
    );
  }
}
