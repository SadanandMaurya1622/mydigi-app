import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/main.dart' as launcher;
import 'package:image/image.dart' as img;

// Run from the repository root with: dart run tool/generate_app_icons.dart
Future<void> main() async {
  final source = img.decodePng(
    File('assets/branding/app_icon.png').readAsBytesSync(),
  );
  if (source == null || source.width != source.height) {
    throw StateError('The app icon must be a square PNG.');
  }

  final generated = Directory('.dart_tool/app_icons')
    ..createSync(recursive: true);
  final background = img.ColorRgb8(5, 38, 169);

  img.Image opaqueCanvas() => img.fill(
    img.Image(width: source.width, height: source.height, numChannels: 3),
    color: background,
  );

  // Composite before generating iOS sizes: flutter_launcher_icons 0.14.4
  // blends partially transparent pixels with incorrect background channels.
  final opaque = img.compositeImage(opaqueCanvas(), source);
  File('${generated.path}/opaque.png').writeAsBytesSync(img.encodePng(opaque));

  // Keep the logo inside the web maskable icon's safe circle.
  final webArtwork = img.copyResize(
    source,
    width: (source.width * 0.9).round(),
    interpolation: img.Interpolation.average,
  );
  final web = img.compositeImage(
    opaqueCanvas(),
    webArtwork,
    dstX: (source.width - webArtwork.width) ~/ 2,
    dstY: (source.height - webArtwork.height) ~/ 2,
  );
  File('${generated.path}/web.png').writeAsBytesSync(img.encodePng(web));

  // Version 0.14.4 also replaces this unrelated boolean setting with AppIcon.
  // Preserve its original values while allowing icon-related project changes.
  final project = File('ios/Runner.xcodeproj/project.pbxproj');
  final setting = RegExp(
    r'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = [^;]+;',
  );
  final originalSettings = setting
      .allMatches(project.readAsStringSync())
      .map((match) => match.group(0)!)
      .toList();
  try {
    await launcher.createIconsFromArguments([]);
  } finally {
    var index = 0;
    final contents = project.readAsStringSync();
    if (setting.allMatches(contents).length != originalSettings.length) {
      throw StateError('The Xcode asset settings changed unexpectedly.');
    }
    project.writeAsStringSync(
      contents.replaceAllMapped(setting, (_) => originalSettings[index++]),
    );
  }

  // Keep generated metadata readable and terminated with a newline.
  for (final path in [
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
    'web/manifest.json',
  ]) {
    final file = File(path);
    final indent = path.startsWith('ios/') ? '  ' : '    ';
    file.writeAsStringSync(
      '${JsonEncoder.withIndent(indent).convert(jsonDecode(file.readAsStringSync()))}\n',
    );
  }
}
