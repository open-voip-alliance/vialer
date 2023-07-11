import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const pListPath = 'ios/Runner/Info-Release.plist';
const envPath = '.env';
const pubspecPath = 'pubspec.yaml';
const sentryVersionFilePath = 'SENTRY_VERSION';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption(
      'type',
      help: 'The type of version to set, one of: [${Type.arguments}]',
    );

  final args = argParser.parse(arguments);

  if (args['type'] == null) throw Exception(argParser.usage);

  if (!(await _isInCorrectDirectory())) {
    throw Exception('This must be run in the root project directory.');
  }

  final type = Type.fromString(args['type'] as String);
  final version = await _getMostRecentGitTag();

  await _updateCfBundleVersionForIos(version);
  await _updateVersionInPubspecYaml(_buildVersionDisplayName(type, version));
  await _updateEnvironmentFile({
    'TAG': version,
    if (type == Type.mergeRequest) 'MERGE_REQUEST': _mergeRequestId,
    if (const [
      Type.other,
      Type.mergeRequest,
    ].contains(type))
      'BRANCH': _escapedBranch,
  });

  await _createFileContainingSentryVersion(type, version);
}

String get _mergeRequestId => Platform.environment['GITLAB_MERGE_REQUEST_IID']!;

String get _escapedBranch =>
    Platform.environment['FCI_BRANCH']!.replaceAll('/', '-');

String get _buildNumber => Platform.environment['BUILD_NR']!;

String get _bundleId => Platform.environment['BUNDLE_ID']!;

Future<bool> _isInCorrectDirectory() => File(envPath).exists();

Future<void> _createFileContainingSentryVersion(
  Type type,
  String version,
) async =>
    File(sentryVersionFilePath).writeAsString(
      _buildVersionForSentry(
        type,
        version,
      ),
    );

Future<void> _updateEnvironmentFile(Map<String, String> replacements) async {
  final envFile = File(envPath);
  final content = await envFile.readAsString();
  final split = const LineSplitter().convert(content);

  for (final key in replacements.keys) {
    split.removeWhere((element) => element.startsWith('$key='));
  }

  replacements.forEach(
    (key, value) => split.add('$key=$value'),
  );
  await envFile.writeAsString(split.join('\n'));
}

Future<void> _updateCfBundleVersionForIos(String version) async =>
    _updateFileContents(
      pListPath,
      find: r'<string>$(FLUTTER_BUILD_NAME)</string>',
      '<string>${version.split('-').first}</string>',
    );

Future<void> _updateVersionInPubspecYaml(String version) async =>
    _updateFileContents(
      pubspecPath,
      pattern: RegExp('^version:.*', multiLine: true),
      'version: $version',
    );

String _buildVersionDisplayName(Type type, String version) {
  switch (type) {
    case Type.appStore:
      return version;
    case Type.mergeRequest:
      return '$version-MR.$_mergeRequestId-$_escapedBranch';
    case Type.other:
      return '$version-$_escapedBranch';
  }
}

String _buildVersionForSentry(Type type, String version) {
  switch (type) {
    case Type.appStore:
      return '$_bundleId@$version+$_buildNumber';
    case Type.mergeRequest:
    case Type.other:
      return '$_bundleId@$version-$_escapedBranch+$_buildNumber';
  }
}

Future<void> _updateFileContents(
  String filename,
  String replace, {
  Pattern? pattern,
  String? find,
}) async {
  final file = File(filename);
  final content = await file.readAsString();
  await file.writeAsString(
    content.replaceFirst(
      pattern ?? find!,
      replace,
    ),
  );
}

Future<String> _getMostRecentGitTag() => Process.run('git', [
      'describe',
      '--tags',
      '--abbrev=0',
      '--match',
      'v*',
    ]).then((value) => value.stdout.toString().trim().replaceFirst('v', ''));

enum Type {
  appStore,
  mergeRequest,
  other;

  static String get arguments => values.map((e) => e.name).join('|');

  static Type fromString(String type) =>
      values.firstWhere((element) => element.name == type);
}
