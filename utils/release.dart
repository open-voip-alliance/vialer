// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartx/dartx.dart';

import 'generate_release_notes_template.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    throw Exception(
      'Usage: dart release.dart <version number>',
    );
  }

  final version = arguments.version;

  stdout.writeln('🚨  Releasing version [$version]  🚨');
  _sleep();

  await _checkOnReleaseBranch(version);
  _success('On correct release branch [${await currentGitBranch}]');
  _sleep();

  await _pullLatest(version);
  _success('Fetched latest from [${await currentGitBranch}]');
  _sleep();

  final releaseNotes = await _checkReleaseNotesExist(version);

  _success('Release notes found');
  stdout.writeln(releaseNotes);
  stdout.writeln('');
  stdout.writeln('');
  _sleep();

  _info('Do you want to continue this release?');
  _info(
    'Starting this release will trigger builds on Codemagic and cause '
    'them to be submitted for review on the Play/App Store',
  );
  _info('Type "release" to continue...');

  if (stdin.readLineSync() != "release") {
    _error('Release cancelled');
  }

  await _tagRelease(version);
  _success('Release tag [v$version] created successfully');
  _sleep();

  await _pushTags(version);
  _success('Release tag pushed to Gitlab');
  _finish('Release has been started successfully');
  _finish('Builds will now begin shortly: https://codemagic.io/builds');
  _finish('#vialer_mobile_releases for further updates');
}

Future<String> _checkReleaseNotesExist(String version) async {
  final file = File('release_notes/v$version/vialer/english.txt');
  final dutchFile = File('release_notes/v$version/vialer/dutch.txt');

  if (!file.existsSync()) {
    _error('Did not find release notes at path [${file.path}]');
  }

  if (dutchFile.existsSync()) {
    _error(
      'We only support English release notes, '
      '[${dutchFile.path}] should be deleted',
    );
  }

  final content = file.readAsStringSync();

  if (content.isBlank) {
    _error('Found release notes but they appear to be empty');
  }

  return content;
}

Future<void> _checkOnReleaseBranch(String version) async {
  final currentBranch = await currentGitBranch;
  final expected = 'release/v$version';

  if (currentBranch != expected) {
    _error(
      'Not on the correct branch for this release, on [$currentBranch] should'
      ' be [$expected]',
    );
  }
}

void _info(String message) => stdout.writeln('‼️ $message');

void _finish(String message) => stdout.writeln('🎉 $message');

void _success(String message) => stdout.writeln('✅  $message');

void _error(String message) {
  stderr.writeln('❌  $message');
  exit(1);
}

void _sleep({Duration? duration = null}) =>
    sleep(duration ?? const Duration(seconds: 1));

extension on List<String> {
  String get version {
    var argument = first;

    if (argument.startsWith('v')) {
      argument = argument.slice(1);
    }

    validateReleaseVersion('v$argument');

    return argument;
  }
}

Future<void> _pullLatest(String version) => Process.run(
      'git',
      ['pull', 'origin', 'release/v$version'],
    );

Future<void> _tagRelease(String version) async {
  final result = await Process.run(
    'git',
    ['tag', '-a', 'v$version', '-m', '"v$version"'],
  );

  if (result.exitCode != 0) {
    _error('Unable to create release tag: ${result.stderr}');
  }
}

Future<void> _pushTags(String version) async {
  final result = await Process.run(
    'git',
    ['push', 'origin', 'v$version'],
  );

  if (result.exitCode != 0) {
    _error('Unable to push release tag: ${result.stderr}');
  }
}
