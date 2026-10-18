import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/generated_website.dart';

class ZipExporter {
  /// Packages the website files into a ZIP archive and saves to downloads/documents
  static Future<File> exportToZip(GeneratedWebsite website) async {
    final archive = Archive();

    // 1. Add index.html
    final htmlBytes = utf8.encode(website.fullDocument);
    archive.addFile(ArchiveFile('index.html', htmlBytes.length, htmlBytes));

    // 2. Add styles.css
    final cssBytes = utf8.encode(website.css);
    archive.addFile(ArchiveFile('styles.css', cssBytes.length, cssBytes));

    // 3. Add script.js
    final jsBytes = utf8.encode(website.javascript);
    archive.addFile(ArchiveFile('script.js', jsBytes.length, jsBytes));

    // 4. Add README.md
    final readme =
        '''# ${website.spec.title}
${website.spec.tagline}

Generated autonomously by Cyber AI Website Studio on ${website.createdAt.toIso8601String()}.

## Project Structure
- `index.html`: Main document with responsive layout and 3D transforms.
- `styles.css`: CSS3 styling, custom properties, and glassmorphic card tilt effects.
- `script.js`: Interactive JavaScript controls.

## How to Run
Simply open `index.html` in any modern web browser or deploy directly to Netlify, Vercel, or GitHub Pages.
''';
    final readmeBytes = utf8.encode(readme);
    archive.addFile(ArchiveFile('README.md', readmeBytes.length, readmeBytes));

    // Encode archive
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    if (zipData == null) {
      throw Exception('Failed to generate ZIP archive.');
    }

    // Save to local storage
    final dir = await getApplicationDocumentsDirectory();
    final sanitizedName = website.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9_\-]'),
      '_',
    );
    final filePath = '${dir.path}/${sanitizedName}_export.zip';
    final file = File(filePath);
    await file.writeAsBytes(zipData);

    return file;
  }
}
