// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartx/dartx.dart';

import 'ci/codemagic/prepare_release_notes.dart';

final brandsToGenerateFor = [
  'vialer',
  'voys',
  'verbonden',
  'annabel',
];

final validReleasePattern = RegExp(r'^v[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$');

/// A simple helper to generate the release notes template files for a specific
/// release.
///
/// If you are on a release branch the correct version will be automatically
/// picked up:
///
/// `dart utils/local/generate_release_notes_template.dart`
///
/// If you are not on a release branch you must specific a version:
///
/// `dart utils/generate_release_notes_template.dart v7.1.1`
Future<void> main(List<String> args) async {
  final release = await findReleaseName(args);

  if (!validReleasePattern.hasMatch(release)) {
    throw ArgumentError('$release does not look like a valid release,'
        ' expecting e.g. v7.1.1');
  }

  for (final fileName in localizationMap.keys) {
    for (final brand in brandsToGenerateFor) {
      final path = '$rawReleaseNotesPath/$release/$brand/$fileName';
      await File(path).create(recursive: true);
      print('Created $path');
    }
  }
}

Future<String> findReleaseName(List<String> args) async {
  final release = args.elementAtOrNull(0);

  if (release != null) return release;

  final branch = await currentGitBranch;

  if (!branch.startsWith('release/')) {
    throw ArgumentError(
      'No release has been provided and you are'
      ' not on a release branch e.g. release/v7.1.1',
    );
  }

  return branch.replaceFirst('release/', '').trim();
}

Future<String> get currentGitBranch async => Process.run(
      'git',
      [
        'rev-parse',
        '--abbrev-ref',
        'HEAD',
      ],
    ).then(
      (value) => value.stdout as String,
    );
