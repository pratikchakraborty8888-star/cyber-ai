class SecurityValidationResult {
  final bool isValid;
  final List<String> warnings;
  final List<String> violations;
  final String sanitizedHtml;

  const SecurityValidationResult({
    required this.isValid,
    required this.warnings,
    required this.violations,
    required this.sanitizedHtml,
  });
}

class SecurityValidator {
  static const List<String> _forbiddenPatterns = [
    '<applet',
    '<object',
    '<embed',
    'javascript:android',
    'intent:',
    'content://',
    'file://',
    'chrome://',
    'content-security-policy',
    'document.cookie',
    'window.android',
    'cyberbridge',
  ];

  /// Validates generated HTML content for malicious patterns and security leaks
  static SecurityValidationResult validate(String rawHtml) {
    final violations = <String>[];
    final warnings = <String>[];
    var sanitized = rawHtml;

    final lower = rawHtml.toLowerCase();

    for (final pattern in _forbiddenPatterns) {
      if (lower.contains(pattern)) {
        violations.add('Forbidden security pattern detected: "$pattern"');
      }
    }

    // Check for inline event handlers trying to access Android bridge
    if (lower.contains('onclick="android') ||
        lower.contains('onclick="window.')) {
      warnings.add('Potentially risky inline event handlers detected.');
    }

    // Sanitize any dangerous protocol prefixes in hrefs
    sanitized = sanitized.replaceAll(
      RegExp(
        r"""href\s*=\s*["'](javascript|intent|file):""",
        caseSensitive: false,
      ),
      'href="#safe-',
    );

    // Remove any unauthorized external font/script links if they attempt unauthorized protocols
    sanitized = sanitized.replaceAll(
      RegExp(r'http://', caseSensitive: false),
      'https://',
    );

    return SecurityValidationResult(
      isValid: violations.isEmpty,
      warnings: warnings,
      violations: violations,
      sanitizedHtml: sanitized,
    );
  }
}
