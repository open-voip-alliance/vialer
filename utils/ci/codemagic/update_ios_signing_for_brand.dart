import 'dart:io';

/// This script replaces the iOS Team ID and Bundle ID in an Xcode project file.
/// The new values must be provided as command-line arguments.
///
/// Usage: dart update_ios_signing_for_brand.dart <iosTeamId> <iosBundleId>
void main(List<String> arguments) async {
  if (arguments.length < 2) {
    throw Exception(
      'Usage: dart replace_ios_teamid_bundleid.dart'
      ' <iosTeamId> <iosBundleId>',
    );
  }

  final iosTeamId = arguments[0];
  final iosBundleId = arguments[1];

  final filePaths = [
    'ios/Runner.xcodeproj/project.pbxproj',
    'ios/Runner/Runner.entitlements',
    'ios/CallDirectoryExtension/CallDirectoryExtension.entitlements',
  ];

  final replacements = {
    iosTeamId: [
      RegExp(r'(?<=DevelopmentTeam = )\w+'),
      RegExp(r'(?<=DEVELOPMENT_TEAM = )\w+'),
    ],
    iosBundleId: [
      RegExp(
        r'(?<=PRODUCT_BUNDLE_IDENTIFIER = )[\w.]+(?=\.CallDirectoryExtension;|;)',
      ),
      RegExp(r'(?<=<string>group.)[\w.]+(?=\.contacts</string>)'),
    ],
  };

  for (final filePath in filePaths) {
    final file = File(filePath);
    var contents = await file.readAsString();

    for (final replacement in replacements.entries) {
      contents = replaceCandidate(replacement, contents);
    }

    await file.writeAsString(contents);
  }
}

String appendExtensionIfNecessary(String? match) {
  const extension = '.CallDirectoryExtension';
  return (match?.endsWith(extension) ?? false) ? extension : '';
}

String replaceCandidate(
  MapEntry<String, List<RegExp>> replacement,
  String contents,
) {
  for (final candidate in replacement.value) {
    contents = contents.replaceAllMapped(
      candidate,
      (match) => replacement.key + appendExtensionIfNecessary(match[0]),
    );
  }
  return contents;
}
