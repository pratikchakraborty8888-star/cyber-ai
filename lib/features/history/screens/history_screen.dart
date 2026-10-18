import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../widgets/cyber_card.dart';
import '../../assistant/models/chat_message.dart';

class HistoryScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onClear;

  const HistoryScreen({
    super.key,
    required this.storageService,
    required this.onClear,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatMessage> _messages = [];
  List<ChatMessage> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await widget.storageService.loadChatHistory();
    setState(() {
      _messages = history.reversed.toList();
      _filtered = _messages;
      _isLoading = false;
    });
  }

  void _filter(String query) {
    final lower = query.toLowerCase();
    setState(() {
      if (lower.isEmpty) {
        _filtered = _messages;
      } else {
        _filtered = _messages
            .where((m) => m.text.toLowerCase().contains(lower))
            .toList();
      }
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CyberColors.cardSurface,
        title: const Text(
          'Clear Chat History?',
          style: TextStyle(color: CyberColors.textPrimary),
        ),
        content: const Text(
          'All conversation logs will be removed.',
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
              'Clear',
              style: TextStyle(color: CyberColors.cyberRed),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.clearChatHistory();
      widget.onClear();
      setState(() {
        _messages = [];
        _filtered = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        title: const Text('COMMAND & CHAT HISTORY'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: CyberColors.cyberRed),
              tooltip: 'Clear History',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: CyberColors.textPrimary),
              onChanged: _filter,
              decoration: const InputDecoration(
                hintText: 'Search past commands and queries...',
                prefixIcon: Icon(Icons.search, color: CyberColors.primaryCyan),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: CyberColors.primaryCyan,
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 48,
                          color: CyberColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No records found.',
                          style: TextStyle(color: CyberColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final msg = _filtered[index];
                      final isUser = msg.sender == MessageSender.user;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CyberCard(
                          padding: const EdgeInsets.all(14),
                          borderColor: isUser
                              ? CyberColors.electricBlue.withOpacity(0.3)
                              : CyberColors.glassBorder,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isUser
                                        ? 'USER COMMAND'
                                        : 'CYBER AI RESPONSE',
                                    style: TextStyle(
                                      color: isUser
                                          ? CyberColors.electricBlue
                                          : CyberColors.primaryCyan,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    '${msg.timestamp.month}/${msg.timestamp.day} ${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: CyberColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                msg.text,
                                style: const TextStyle(
                                  color: CyberColors.textPrimary,
                                  fontSize: 13.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
