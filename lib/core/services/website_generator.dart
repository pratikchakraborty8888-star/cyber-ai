import '../config/app_config.dart';
import '../../features/websites/models/website_spec.dart';
import '../../features/websites/models/generated_website.dart';
import '../../features/websites/services/template_engine.dart';
import '../../features/websites/services/code_generator.dart';
import '../../features/websites/services/security_validator.dart';
import 'ai_service.dart';

class WebsiteGenerator {
  final AIService _aiService;

  WebsiteGenerator(this._aiService);

  /// Generates a complete website from natural-language instructions
  Future<GeneratedWebsite> generateFromPrompt({
    required String prompt,
    String? apiKey,
    String model = AppConfig.defaultGeminiModel,
  }) async {
    // 1. Generate or infer specification
    String jsonSpec = '';
    if (apiKey != null && apiKey.isNotEmpty) {
      jsonSpec = await _aiService.generateWebsiteSpec(
        userPrompt: prompt,
        model: model,
        apiKey: apiKey,
      );
    }

    final spec = TemplateEngine.inferSpecification(prompt, jsonSpec: jsonSpec);

    // 2. Generate CSS and Body HTML
    final css = CodeGenerator.generateCss(spec);
    final js = CodeGenerator.generateJs(spec);

    // 3. Validate and sanitize
    final fullHtml = CodeGenerator.generateFullHtml(spec);
    final validation = SecurityValidator.validate(fullHtml);

    return GeneratedWebsite(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: spec.title,
      prompt: prompt,
      createdAt: DateTime.now(),
      spec: spec,
      html: validation.sanitizedHtml,
      css: css,
      javascript: js,
    );
  }

  /// Refines an existing website with follow-up changes
  Future<GeneratedWebsite> refineWebsite({
    required GeneratedWebsite original,
    required String changeRequest,
    String? apiKey,
    String model = AppConfig.defaultGeminiModel,
  }) async {
    final lower = changeRequest.toLowerCase();

    // Check if the change is a palette or layout modification
    if (lower.contains('palette') ||
        lower.contains('color') ||
        lower.contains('minimal') ||
        lower.contains('darker')) {
      String newPrimary = original.spec.primaryColor;
      String newSecondary = original.spec.secondaryColor;
      String newBg = original.spec.backgroundColor;

      if (lower.contains('minimal')) {
        newPrimary = '#ffffff';
        newSecondary = '#94a3b8';
        newBg = '#000000';
      } else if (lower.contains('cyan') || lower.contains('cyber')) {
        newPrimary = '#00f0ff';
        newSecondary = '#8b5cf6';
        newBg = '#070b14';
      } else if (lower.contains('gold') || lower.contains('amber')) {
        newPrimary = '#f59e0b';
        newSecondary = '#ec4899';
      } else if (lower.contains('green')) {
        newPrimary = '#10b981';
        newSecondary = '#00f0ff';
      }

      final updatedSpec = WebsiteSpecification(
        title: original.spec.title,
        tagline: original.spec.tagline,
        layoutType: original.spec.layoutType,
        primaryColor: newPrimary,
        secondaryColor: newSecondary,
        backgroundColor: newBg,
        textColor: original.spec.textColor,
        enable3DEffects: lower.contains('3d')
            ? true
            : original.spec.enable3DEffects,
        sections: original.spec.sections,
        navigationLinks: original.spec.navigationLinks,
      );

      final fullHtml = CodeGenerator.generateFullHtml(updatedSpec);
      final validation = SecurityValidator.validate(fullHtml);

      return original.copyWith(
        spec: updatedSpec,
        html: validation.sanitizedHtml,
        css: CodeGenerator.generateCss(updatedSpec),
      );
    }

    // If API key is present, invoke AI refinement
    if (apiKey != null && apiKey.isNotEmpty) {
      final refinedHtml = await _aiService.refineWebsiteCode(
        originalHtml: original.fullDocument,
        changeRequest: changeRequest,
        model: model,
        apiKey: apiKey,
      );
      final validation = SecurityValidator.validate(refinedHtml);
      return original.copyWith(html: validation.sanitizedHtml);
    }

    // Default: append requested section to HTML
    final newSection =
        '''
<section class="section">
  <h2 class="section-title">Updated Feature: $changeRequest</h2>
  <p class="section-subtitle">Custom refinement integrated per your instructions.</p>
  <div class="card-tilt">
    <h3 class="card-title">Enhanced Component</h3>
    <p class="card-desc">Updated with your requested modification: "$changeRequest".</p>
  </div>
</section>
''';
    final updatedHtml = original.html.replaceAll(
      '</main>',
      '$newSection\n</main>',
    );
    final validation = SecurityValidator.validate(updatedHtml);

    return original.copyWith(html: validation.sanitizedHtml);
  }
}
