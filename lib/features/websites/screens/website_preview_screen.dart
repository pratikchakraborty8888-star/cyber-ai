import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/website_generator.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../widgets/cyber_button.dart';
import '../models/generated_website.dart';
import '../services/zip_exporter.dart';

enum ViewportMode { mobile, tablet, desktop }

class WebsitePreviewScreen extends StatefulWidget {
  final GeneratedWebsite website;
  final WebsiteGenerator websiteGenerator;
  final StorageService storageService;
  final String? apiKey;
  final String selectedModel;
  final Function(GeneratedWebsite updated) onWebsiteUpdated;

  const WebsitePreviewScreen({
    super.key,
    required this.website,
    required this.websiteGenerator,
    required this.storageService,
    this.apiKey,
    required this.selectedModel,
    required this.onWebsiteUpdated,
  });

  @override
  State<WebsitePreviewScreen> createState() => _WebsitePreviewScreenState();
}

class _WebsitePreviewScreenState extends State<WebsitePreviewScreen>
    with SingleTickerProviderStateMixin {
  late GeneratedWebsite _currentWebsite;
  WebViewController? _webViewController;
  ViewportMode _viewportMode = ViewportMode.desktop;
  late TabController _tabController;
  final TextEditingController _refineController = TextEditingController();
  bool _isRefining = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _currentWebsite = widget.website;
    _tabController = TabController(length: 4, vsync: this);
    _initWebView();
  }

  void _initWebView() {
    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF070B14))
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              // Sandbox: prevent external navigation outside preview
              if (request.url.startsWith('data:') ||
                  request.url.startsWith('about:blank')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        )
        ..loadHtmlString(_currentWebsite.fullDocument);
    } catch (_) {
      _webViewController = null;
    }
  }

  Future<void> _applyRefinement(String changeRequest) async {
    final request = changeRequest.trim();
    if (request.isEmpty) return;

    setState(() => _isRefining = true);
    try {
      final updated = await widget.websiteGenerator.refineWebsite(
        original: _currentWebsite,
        changeRequest: request,
        apiKey: widget.apiKey,
        model: widget.selectedModel,
      );

      setState(() {
        _currentWebsite = updated;
        _isRefining = false;
      });

      widget.onWebsiteUpdated(updated);
      _webViewController?.loadHtmlString(updated.fullDocument);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Website updated successfully!'),
            backgroundColor: CyberColors.matrixGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isRefining = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refinement failed: $e'),
            backgroundColor: CyberColors.cyberRed,
          ),
        );
      }
    }
  }

  Future<void> _exportZip() async {
    setState(() => _isExporting = true);
    try {
      final file = await ZipExporter.exportToZip(_currentWebsite);
      setState(() {
        _isExporting = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: CyberColors.cardSurface,
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: CyberColors.matrixGreen),
                SizedBox(width: 8),
                Text(
                  'Export Complete',
                  style: TextStyle(color: CyberColors.textPrimary),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ZIP archive generated with index.html, styles.css, script.js, and README.md:',
                ),
                const SizedBox(height: 10),
                SelectableText(
                  file.path,
                  style: const TextStyle(
                    color: CyberColors.primaryCyan,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: CyberColors.primaryCyan),
                ),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: CyberColors.cyberRed,
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
        title: Text(_currentWebsite.name),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_rounded,
              color: CyberColors.primaryCyan,
            ),
            tooltip: 'Export ZIP',
            onPressed: _isExporting ? null : _exportZip,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CyberColors.primaryCyan,
          labelColor: CyberColors.primaryCyan,
          unselectedLabelColor: CyberColors.textMuted,
          tabs: const [
            Tab(text: 'PREVIEW'),
            Tab(text: 'HTML'),
            Tab(text: 'CSS'),
            Tab(text: 'JS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Preview Tab
          Column(
            children: [
              // Viewport Mode Switcher & Refinement Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: CyberColors.surface,
                child: Row(
                  children: [
                    const Text(
                      'VIEWPORT: ',
                      style: TextStyle(
                        color: CyberColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildViewportButton(
                      ViewportMode.mobile,
                      Icons.phone_android,
                    ),
                    _buildViewportButton(
                      ViewportMode.tablet,
                      Icons.tablet_android,
                    ),
                    _buildViewportButton(
                      ViewportMode.desktop,
                      Icons.desktop_windows,
                    ),
                    const Spacer(),
                    Text(
                      _currentWebsite.spec.layoutType.name.toUpperCase(),
                      style: const TextStyle(
                        color: CyberColors.primaryCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Sandboxed Viewport Area
              Expanded(
                child: Center(
                  child: Container(
                    width: _getViewportWidth(MediaQuery.of(context).size.width),
                    decoration: BoxDecoration(
                      border: Border.all(color: CyberColors.glassBorder),
                    ),
                    child: _webViewController != null
                        ? WebViewWidget(controller: _webViewController!)
                        : const Center(
                            child: Text(
                              'WebView preview active on supported device.',
                              style: TextStyle(color: CyberColors.textMuted),
                            ),
                          ),
                  ),
                ),
              ),

              // Quick Refinement Bar
              Container(
                padding: const EdgeInsets.all(12),
                color: CyberColors.surface,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRefineChip('Make it minimal'),
                          _buildRefineChip('Add 3D hero'),
                          _buildRefineChip('Cyber Cyan palette'),
                          _buildRefineChip('Gold Obsidian palette'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _refineController,
                            style: const TextStyle(
                              color: CyberColors.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Request change: "add pricing cards", "change layout"...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (val) {
                              _refineController.clear();
                              _applyRefinement(val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        CyberButton(
                          text: 'REFINE',
                          isLoading: _isRefining,
                          onPressed: () {
                            final text = _refineController.text;
                            _refineController.clear();
                            _applyRefinement(text);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. HTML Tab
          _buildSourceViewer(_currentWebsite.html),

          // 3. CSS Tab
          _buildSourceViewer(_currentWebsite.css),

          // 4. JS Tab
          _buildSourceViewer(_currentWebsite.javascript),
        ],
      ),
    );
  }

  Widget _buildViewportButton(ViewportMode mode, IconData icon) {
    final isSelected = _viewportMode == mode;
    return IconButton(
      icon: Icon(
        icon,
        size: 18,
        color: isSelected ? CyberColors.primaryCyan : CyberColors.textMuted,
      ),
      onPressed: () => setState(() => _viewportMode = mode),
    );
  }

  double _getViewportWidth(double screenWidth) {
    switch (_viewportMode) {
      case ViewportMode.mobile:
        return 375.0;
      case ViewportMode.tablet:
        return 768.0;
      case ViewportMode.desktop:
        return screenWidth;
    }
  }

  Widget _buildRefineChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(color: CyberColors.textPrimary, fontSize: 11),
        ),
        backgroundColor: CyberColors.cardSurface,
        side: const BorderSide(color: CyberColors.glassBorder),
        onPressed: () => _applyRefinement(label),
      ),
    );
  }

  Widget _buildSourceViewer(String code) {
    return Container(
      color: const Color(0xFF0A0F1D),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText(
          code,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
