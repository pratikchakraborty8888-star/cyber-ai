import 'website_spec.dart';

class GeneratedWebsite {
  final String id;
  final String name;
  final String prompt;
  final DateTime createdAt;
  final WebsiteSpecification spec;
  final String html;
  final String css;
  final String javascript;

  const GeneratedWebsite({
    required this.id,
    required this.name,
    required this.prompt,
    required this.createdAt,
    required this.spec,
    required this.html,
    required this.css,
    required this.javascript,
  });

  String get fullDocument {
    // If html already contains complete <!DOCTYPE html>, return it
    if (html.contains('<!DOCTYPE html>') || html.contains('<html')) {
      return html;
    }
    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${spec.title}</title>
  <style>
$css
  </style>
</head>
<body>
$html
<script>
$javascript
</script>
</body>
</html>''';
  }

  GeneratedWebsite copyWith({
    String? id,
    String? name,
    String? prompt,
    DateTime? createdAt,
    WebsiteSpecification? spec,
    String? html,
    String? css,
    String? javascript,
  }) {
    return GeneratedWebsite(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
      createdAt: createdAt ?? this.createdAt,
      spec: spec ?? this.spec,
      html: html ?? this.html,
      css: css ?? this.css,
      javascript: javascript ?? this.javascript,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prompt': prompt,
      'createdAt': createdAt.toIso8601String(),
      'spec': spec.toJson(),
      'html': html,
      'css': css,
      'javascript': javascript,
    };
  }

  factory GeneratedWebsite.fromJson(Map<String, dynamic> json) {
    return GeneratedWebsite(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Cyber AI Website',
      prompt: json['prompt'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      spec: WebsiteSpecification.fromJson(
        json['spec'] as Map<String, dynamic>? ?? {},
      ),
      html: json['html'] as String? ?? '',
      css: json['css'] as String? ?? '',
      javascript: json['javascript'] as String? ?? '',
    );
  }
}
