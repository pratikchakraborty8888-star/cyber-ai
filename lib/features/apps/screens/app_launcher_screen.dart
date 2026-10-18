import 'package:flutter/material.dart';

import '../../../core/services/platform_bridge.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../widgets/cyber_card.dart';
import '../models/app_info.dart';

class AppLauncherScreen extends StatefulWidget {
  final PlatformBridge platformBridge;
  final String? searchQuery;

  const AppLauncherScreen({
    super.key,
    required this.platformBridge,
    this.searchQuery,
  });

  @override
  State<AppLauncherScreen> createState() => _AppLauncherScreenState();
}

class _AppLauncherScreenState extends State<AppLauncherScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);
    final apps = await widget.platformBridge.getInstalledApps();
    setState(() {
      _allApps = apps;
      _filterApps(_searchController.text);
      _isLoading = false;
    });
  }

  void _filterApps(String query) {
    final lower = query.toLowerCase();
    setState(() {
      if (lower.isEmpty) {
        _filteredApps = _allApps;
      } else {
        _filteredApps = _allApps
            .where(
              (app) =>
                  app.name.toLowerCase().contains(lower) ||
                  app.packageName.toLowerCase().contains(lower),
            )
            .toList();
      }
    });
  }

  Future<void> _launchApp(AppInfo app) async {
    final launched = await widget.platformBridge.launchApp(app.packageName);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to launch ${app.name} (${app.packageName})'),
          backgroundColor: CyberColors.cyberRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(title: const Text('APP LAUNCHER')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: CyberColors.textPrimary),
              onChanged: _filterApps,
              decoration: InputDecoration(
                hintText: 'Search installed applications...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: CyberColors.primaryCyan,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: CyberColors.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filterApps('');
                        },
                      )
                    : null,
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
                : _filteredApps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.apps_outage,
                          size: 48,
                          color: CyberColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matching applications found',
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
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = _filteredApps[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CyberCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          onTap: () => _launchApp(app),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: CyberColors.glassFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: CyberColors.glassBorder,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.android,
                                    color: CyberColors.primaryCyan,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.name,
                                      style: const TextStyle(
                                        color: CyberColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      app.packageName,
                                      style: const TextStyle(
                                        color: CyberColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.launch,
                                size: 18,
                                color: CyberColors.primaryCyan,
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
