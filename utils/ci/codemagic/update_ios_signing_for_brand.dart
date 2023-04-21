import 'dart:io';

/// This script replaces the iOS Team ID and Bundle ID in an Xcode project file.
/// The new values must be provided as command-line arguments.
///
/// Usage: dart update_ios_signing_for_brand.dart <iosTeamId> <iosBundleId>
void main(List<String> arguments) {
  if (arguments.length < 2) {
    throw ArgumentError(
      'Usage: dart replace_ios_teamid_bundleid.dart'
      ' <iosTeamId> <iosBundleId>',
    );
  }

  final iosTeamId = arguments[0];
  final iosBundleId = arguments[1];

  final filePath = 'ios/Runner.xcodeproj/project.pbxproj';
  final replacements = {
    iosTeamId: [
      RegExp(r'(?<=DevelopmentTeam = )\w+'),
      RegExp(r'(?<=DEVELOPMENT_TEAM = )\w+'),
    ],
    iosBundleId: [
      RegExp(r'(?<=PRODUCT_BUNDLE_IDENTIFIER = )[\w.]+(?=;)'),
    ]
  };

  var file = File(filePath);
  var contents = file.readAsStringSync();

  for (var replacement in replacements.entries) {
    for (var candidate in replacement.value) {
      contents = contents.replaceAllMapped(
        candidate,
        (match) => '${replacement.key}',
      );
    }
  }

  file.writeAsStringSync(contents);
}
