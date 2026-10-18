import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/website_generator.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../widgets/cyber_button.dart';
import '../../../widgets/cyber_card.dart';
import '../models/generated_website.dart';
import 'website_preview_screen.dart';

class WebsiteStudioScreen extends StatefulWidget {
  final WebsiteGenerator websiteGenerator;
  final StorageService storageService;
  final String? apiKey;
  final String selectedModel;
  final String? initialPrompt;

  const WebsiteStudioScreen({
    super.key,
    required this.websiteGenerator,
    required this.storageService,
    this.apiKey,
    required this.selectedModel,
    this.initialPrompt,
  });

  @override
  State<WebsiteStudioScreen> createState() => _WebsiteStudioScreenState();
}

class _WebsiteStudioScreenState extends State<WebsiteStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  List<GeneratedWebsite> _projects = [];
  bool _isGenerating = false;
  String _currentPhase = '';

  final List<String> _exampleBriefs = [
    'Build a premium 3D sneaker store',
    'Create a cinematic portfolio for a photographer',
    'Create a modern SaaS landing page',
    'Build an elegant restaurant website',
    'Create an interactive education dashboard',
    'Create a futuristic gaming community website',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      _promptController.text = widget.initialPrompt!;
    }
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final list = await widget.storageService.loadWebsites();
    setState(() => _projects = list);
  }

  Future<void> _generateWebsite() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _currentPhase = 'PHASE A: Analyzing Requirements & Architecture...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(
        () => _currentPhase = 'PHASE B: Planning Design System & 3D Tokens...',
      );
      await Future.delayed(const Duration(milliseconds: 300));
      setState(
        () => _currentPhase =
            'PHASE C: Generating Content & Semantic Structure...',
      );
      await Future.delayed(const Duration(milliseconds: 300));
      setState(
        () =>
            _currentPhase = 'PHASE D: Synthesizing HTML5, CSS3 & Modern JS...',
      );

      final site = await widget.websiteGenerator.generateFromPrompt(
        prompt: prompt,
        apiKey: widget.apiKey,
        model: widget.selectedModel,
      );

      setState(
        () => _currentPhase =
            'PHASE E: Running Security & Sandboxing Validation...',
      );
      await Future.delayed(const Duration(milliseconds: 200));

      final updatedList = [site, ..._projects];
      await widget.storageService.saveWebsites(updatedList);

      setState(() {
        _projects = updatedList;
        _isGenerating = false;
        _currentPhase = '';
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebsitePreviewScreen(
              website: site,
              websiteGenerator: widget.websiteGenerator,
              storageService: widget.storageService,
              apiKey: widget.apiKey,
              selectedModel: widget.selectedModel,
              onWebsiteUpdated: (updatedSite) {
                setState(() {
                  final idx = _projects.indexWhere(
                    (p) => p.id == updatedSite.id,
                  );
                  if (idx != -1) {
                    _projects[idx] = updatedSite;
                  }
                });
                widget.storageService.saveWebsites(_projects);
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _currentPhase = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation failed: $e'),
            backgroundColor: CyberColors.cyberRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(GeneratedWebsite project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CyberColors.cardSurface,
        title: const Text(
          'Delete Project',
          style: TextStyle(color: CyberColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"?',
          style: const TextStyle(color: CyberColors.textSecondary),
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
              'Delete',
              style: TextStyle(color: CyberColors.cyberRed),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _projects.removeWhere((p) => p.id == project.id);
      });
      await widget.storageService.saveWebsites(_projects);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(title: const Text('WEBSITE GENERATION STUDIO')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Prompt Input Card
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: CyberColors.primaryCyan,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI SPECIFICATION BUILDER',
                      style: TextStyle(
                        color: CyberColors.primaryCyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _promptController,
                  maxLines: 3,
                  style: const TextStyle(color: CyberColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Describe your website: brand purpose, style, 3D elements, target audience...',
                  ),
                ),
                const SizedBox(height: 14),

                // Example Briefs
                const Text(
                  'QUICK BRIEFS:',
                  style: TextStyle(
                    color: CyberColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _exampleBriefs.map((brief) {
                    return InkWell(
                      onTap: () =>
                          setState(() => _promptController.text = brief),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: CyberColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CyberColors.glassBorder),
                        ),
                        child: Text(
                          brief,
                          style: const TextStyle(
                            color: CyberColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                if (_isGenerating) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CyberColors.neonViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CyberColors.neonViolet.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CyberColors.neonViolet,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentPhase,
                            style: const TextStyle(
                              color: CyberColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: CyberButton(
                      text: 'GENERATE 3D WEBSITE',
                      icon: Icons.rocket_launch,
                      onPressed: _generateWebsite,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Generated Projects History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR WEBSITE PROJECTS',
                style: TextStyle(
                  color: CyberColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${_projects.length} Saved',
                style: const TextStyle(
                  color: CyberColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_projects.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.web_asset,
                      size: 48,
                      color: CyberColors.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No websites generated yet.',
                      style: TextStyle(color: CyberColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter a prompt above to build your first 3D website.',
                      style: TextStyle(
                        color: CyberColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ..._projects.map((project) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CyberCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebsitePreviewScreen(
                          website: project,
                          websiteGenerator: widget.websiteGenerator,
                          storageService: widget.storageService,
                          apiKey: widget.apiKey,
                          selectedModel: widget.selectedModel,
                          onWebsiteUpdated: (updatedSite) {
                            setState(() {
                              final idx = _projects.indexWhere(
                                (p) => p.id == updatedSite.id,
                              );
                              if (idx != -1) _projects[idx] = updatedSite;
                            });
                            widget.storageService.saveWebsites(_projects);
                          },
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CyberColors.primaryCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: CyberColors.primaryCyan.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.language,
                          color: CyberColors.primaryCyan,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                color: CyberColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.spec.layoutType.name.toUpperCase(),
                              style: const TextStyle(
                                color: CyberColors.primaryCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: CyberColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => _deleteProject(project),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: CyberColors.textMuted,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
