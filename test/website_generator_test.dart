import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_ai/features/websites/models/website_spec.dart';
import 'package:cyber_ai/features/websites/services/template_engine.dart';
import 'package:cyber_ai/features/websites/services/code_generator.dart';

void main() {
  group('Website Studio Generator Tests', () {
    test('Infers ecommerce layout for sneaker store brief', () {
      final spec = TemplateEngine.inferSpecification(
        'Build a 3D sneaker store',
      );
      expect(spec.layoutType, LayoutType.ecommerce);
      expect(spec.enable3DEffects, isTrue);
      expect(spec.title, contains('AERO VORTEX'));
    });

    test('Infers portfolio layout for photographer brief', () {
      final spec = TemplateEngine.inferSpecification(
        'Create a cinematic portfolio for a photographer',
      );
      expect(spec.layoutType, LayoutType.portfolio);
      expect(spec.title, contains('VISUALS'));
    });

    test('Infers saas layout for cloud enterprise brief', () {
      final spec = TemplateEngine.inferSpecification(
        'Create a modern SaaS landing page',
      );
      expect(spec.layoutType, LayoutType.saas);
    });

    test('Generates complete HTML with 3D CSS and responsive viewport', () {
      final spec = TemplateEngine.inferSpecification(
        'Build a 3D sneaker store',
      );
      final fullHtml = CodeGenerator.generateFullHtml(spec);

      expect(fullHtml, contains('<!DOCTYPE html>'));
      expect(fullHtml, contains('<meta name="viewport"'));
      expect(fullHtml, contains('perspective: 1200px'));
      expect(fullHtml, contains('card-tilt'));
      expect(fullHtml, contains('<script>'));
    });
  });
}
