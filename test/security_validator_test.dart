import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_ai/features/websites/services/security_validator.dart';

void main() {
  group('SecurityValidator Tests', () {
    test('Valid HTML passes security inspection', () {
      const validHtml = '''
<!DOCTYPE html>
<html>
<head><title>Test Site</title></head>
<body>
  <h1>Welcome</h1>
  <p>Safe content</p>
</body>
</html>
''';
      final result = SecurityValidator.validate(validHtml);
      expect(result.isValid, isTrue);
      expect(result.violations, isEmpty);
    });

    test('Detects forbidden window.Android or bridge call', () {
      const maliciousHtml = '''
<html>
<body>
  <script>
    window.Android.getSecrets();
  </script>
</body>
</html>
''';
      final result = SecurityValidator.validate(maliciousHtml);
      expect(result.isValid, isFalse);
      expect(
        result.violations.any(
          (v) => v.toLowerCase().contains('window.android'),
        ),
        isTrue,
      );
    });

    test('Detects intent: and file: access', () {
      const maliciousHtml = '''
<html>
<body>
  <a href="intent:#Intent;package=com.target;end">Click</a>
  <iframe src="file:///etc/passwd"></iframe>
</body>
</html>
''';
      final result = SecurityValidator.validate(maliciousHtml);
      expect(result.isValid, isFalse);
      expect(result.violations.any((v) => v.contains('intent:')), isTrue);
      expect(result.violations.any((v) => v.contains('file://')), isTrue);
    });

    test('Sanitizes javascript: protocol in href', () {
      const testHtml = '<a href="javascript:alert(1)">Click</a>';
      final result = SecurityValidator.validate(testHtml);
      expect(result.sanitizedHtml, contains('href="#safe-'));
    });
  });
}
