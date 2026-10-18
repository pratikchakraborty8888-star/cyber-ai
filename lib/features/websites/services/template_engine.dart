import 'dart:convert';

import '../models/website_spec.dart';

class TemplateEngine {
  /// Converts a prompt into a typed [WebsiteSpecification] using heuristics or parsed JSON
  static WebsiteSpecification inferSpecification(
    String prompt, {
    String? jsonSpec,
  }) {
    if (jsonSpec != null && jsonSpec.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonSpec) as Map<String, dynamic>;
        return WebsiteSpecification.fromJson(decoded);
      } catch (_) {}
    }

    final lower = prompt.toLowerCase();

    // 1. Determine Layout Type
    LayoutType layout = LayoutType.saas;
    if (lower.contains('sneaker') ||
        lower.contains('clothing') ||
        lower.contains('store') ||
        lower.contains('shop') ||
        lower.contains('ecommerce')) {
      layout = LayoutType.ecommerce;
    } else if (lower.contains('portfolio') ||
        lower.contains('photographer') ||
        lower.contains('resume') ||
        lower.contains('artist')) {
      layout = LayoutType.portfolio;
    } else if (lower.contains('restaurant') ||
        lower.contains('cafe') ||
        lower.contains('bistro') ||
        lower.contains('food')) {
      layout = LayoutType.restaurant;
    } else if (lower.contains('dashboard') ||
        lower.contains('analytics') ||
        lower.contains('metrics')) {
      layout = LayoutType.dashboard;
    } else if (lower.contains('agency') ||
        lower.contains('marketing') ||
        lower.contains('consulting')) {
      layout = LayoutType.agency;
    } else if (lower.contains('education') ||
        lower.contains('course') ||
        lower.contains('school') ||
        lower.contains('learn')) {
      layout = LayoutType.education;
    } else if (lower.contains('game') ||
        lower.contains('gaming') ||
        lower.contains('esports') ||
        lower.contains('entertainment')) {
      layout = LayoutType.entertainment;
    } else if (lower.contains('launch') ||
        lower.contains('hardware') ||
        lower.contains('gadget')) {
      layout = LayoutType.productLaunch;
    }

    // 2. Determine Palette
    String primary = '#00f0ff';
    String secondary = '#8b5cf6';
    String bg = '#070b14';
    String text = '#f8fafc';

    if (layout == LayoutType.ecommerce ||
        lower.contains('luxury') ||
        lower.contains('clothing')) {
      primary = '#f59e0b'; // Gold accent
      secondary = '#ec4899'; // Rose
      bg = '#0a0a0c'; // Deep obsidian
    } else if (layout == LayoutType.portfolio ||
        lower.contains('photographer')) {
      primary = '#38bdf8'; // Sky blue
      secondary = '#a855f7'; // Purple
      bg = '#0f172a'; // Slate
    } else if (layout == LayoutType.restaurant) {
      primary = '#f97316'; // Amber orange
      secondary = '#ef4444'; // Warm red
      bg = '#140c07';
    } else if (layout == LayoutType.entertainment || lower.contains('gaming')) {
      primary = '#10b981'; // Matrix neon green
      secondary = '#00f0ff'; // Cyan
      bg = '#040d08';
    }

    // 3. Title & Tagline
    String title = 'Cyber AI Project';
    String tagline =
        'Engineered autonomously for maximum impact and responsive fidelity.';

    if (lower.contains('sneaker')) {
      title = 'AERO VORTEX 3D';
      tagline = 'Next-generation footwear designed with volumetric cushioning and aerodynamic form.';
    } else if (lower.contains('clothing')) {
      title = 'LUMEN ATELIER';
      tagline = 'Avant-garde streetwear engineered for the digital frontier.';
    } else if (lower.contains('portfolio')) {
      title = 'ALEX VANCE — VISUALS';
      tagline = 'Cinematography, creative direction, and digital architectural experiences.';
    } else if (lower.contains('saas')) {
      title = 'SYNAPSE CLOUD';
      tagline = 'Autonomous telemetry and AI orchestration for mission-critical infrastructure.';
    } else if (lower.contains('restaurant')) {
      title = 'NOIR BISTRO';
      tagline = 'Artisanal culinary craftsmanship infused with seasonal molecular gastronomy.';
    }

    final is3D =
        lower.contains('3d') ||
        layout == LayoutType.productLaunch ||
        layout == LayoutType.ecommerce;

    final sections = [
      const SectionSpec(
        id: 'overview',
        title: 'Core Architecture',
        description: 'Engineered with precision for uncompromised performance and interactive depth.',
        type: 'features',
      ),
      if (is3D)
        const SectionSpec(
          id: 'showcase',
          title: 'Volumetric 3D Experience',
          description: 'Explore the form factor with genuine real-time 3D perspective transforms.',
          type: 'showcase3d',
        ),
      const SectionSpec(
        id: 'metrics',
        title: 'Proven Velocity',
        description: 'Delivering unparalleled results across benchmarks and user engagements.',
        type: 'metrics',
      ),
      const SectionSpec(
        id: 'contact',
        title: 'Connect With Us',
        description: 'Reach our team to begin your deployment or consultation.',
        type: 'contact',
      ),
    ];

    return WebsiteSpecification(
      title: title,
      tagline: tagline,
      layoutType: layout,
      primaryColor: primary,
      secondaryColor: secondary,
      backgroundColor: bg,
      textColor: text,
      enable3DEffects: is3D,
      sections: sections,
      navigationLinks: [
        'Overview',
        if (is3D) '3D Showcase',
        'Metrics',
        'Contact',
      ],
    );
  }
}
