// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> args) async {
  final operations = args[0];
  final checkGeneration = operations.contains('g');
  final checkFormatting = operations.contains('f');
  final checkAnalysis = operations.contains('a');
  final checkBranch = operations.contains('b');

  final generateOnError = args.elementAtOrNull(1) == '--generate-on-error';

  // Just to make beneath code more readable.
  final extraArg = generateOnError;

  final diffFilesResult = await Process.run(
    'git',
    [
      'diff',
      '--name-only',
      // If we have ref arguments, use those for the diff. Otherwise use staged
      // files for the diff. If --generate-on-error is enabled it moves
      // the arguments up by 1.
      if (args.length > (extraArg ? 2 : 1)) ...[
        args[(extraArg ? 2 : 1)], // Previous head
        args[(extraArg ? 3 : 2)], // Current head
      ] else
        '--cached',
    ],
  );

  final changedFiles = (diffFilesResult.stdout as String)
      .split('\n')
      .where((s) => s.isNotEmpty)
      .toList();

  if (checkBranch) {
    await _checkBranch();
  }

  if (checkFormatting) {
    await _checkFormattingIfNeeded(changedFiles);
  }

  if (checkAnalysis) {
    await _checkAnalysisIfNeeded(changedFiles);
  }

  if (checkGeneration) {
    await _runGenerationIfNeeded(changedFiles, generateOnError);
  }
}

Future<void> _writeAndExitIfNotZero(
  Process process, {
  required String messageOnFail,
}) async {
  // We need to do it like this instead of waiting on process.exitCode, because
  // that doesn't work.
  final exitCompleter = Completer<int>();
  process.stdout.listen(
    stdout.add,
    onDone: () async => exitCompleter.complete(await process.exitCode),
  );

  final exitCode = await exitCompleter.future;

  if (exitCode != 0) {
    print(messageOnFail);
    exit(exitCode);
  }
}

Future<void> _checkBranch() async {
  final revParseResult = await Process.run(
    'git',
    ['rev-parse', '--abbrev-ref', 'HEAD'],
  );

  final branch = (revParseResult.stdout as String).trim();

  if (!RegExp(r'^[0-9]+\-[a-z0-9\-]+$').hasMatch(branch)) {
    print(
      'Your branch will be rejected. '
      'You should rename your branch to a valid name '
      '(e.g.: 123-short-description) and try again.',
    );
    print('Rename your branch with:\tgit branch -m 123-new-name');
    exit(1);
  }
}

Future<void> _checkFormattingIfNeeded(Iterable<String> files) async {
  final hasDartFileChanges = files.any((s) => s.endsWith('.dart'));

  if (!hasDartFileChanges) {
    return;
  }

  // We only want to check Dart files,
  // excluding generated and third party files.
  final filesToCheck = await Directory.current
      .list(recursive: true)
      .map((e) => path.relative(e.path))
      .where(
        (path) =>
            path.endsWith('.dart') &&
            !path.endsWith('.i18n.dart') &&
            !path.endsWith('.g.dart') &&
            !path.endsWith('.chopper.dart') &&
            !path.endsWith('/pigeon.dart') &&
            !path.startsWith('ios') &&
            !path.startsWith('.dart_tool'),
      )
      .toList();

  final process = await Process.start(
    'dart',
    [
      'format',
      '-o',
      'none',
      '--fix',
      '--set-exit-if-changed',
      ...filesToCheck,
    ],
  );

  await _writeAndExitIfNotZero(
    process,
    messageOnFail: 'The above files need to be formatted.',
  );
}

Future<void> _checkAnalysisIfNeeded(Iterable<String> files) async {
  final hasDartFileChanges = files.any((s) => s.endsWith('.dart'));

  if (!hasDartFileChanges) {
    return;
  }

  final process = await Process.start('dart', _analyze);

  await _writeAndExitIfNotZero(
    process,
    messageOnFail: 'Analysis has failed.',
  );
}

Future<void> _runGenerationIfNeeded(
  Iterable<String> files,
  bool runOnError, {
  bool firstTry = true,
}) async {
  if (runOnError) {
    print('Checking if we should run code generation..');
    final analyzeResult = await Process.start('dart', _analyze);
    final analyzeExitCode = await analyzeResult.exitCode;

    if (analyzeExitCode == 0) {
      print('No code generation needed!');
      return;
      // .packages file is possibly outdated, run flutter pub get.
    } else if (firstTry && analyzeExitCode != 0) {
      final pubGet = await Process.start('flutter', ['pub', 'get']);
      await pubGet.exitCode;

      // Try again.
      await _runGenerationIfNeeded(files, runOnError, firstTry: false);
    } else {
      print('Check failed. Please run the generation command yourself.');
      return;
    }
  } else {
    final hasGenerationChanges = files.any(
      (s) =>
          s.endsWith('i18n.yaml') ||
          s.endsWith('lib/domain/repositories/db/database.dart') ||
          s.endsWith('pigeon/scheme.dart') ||
          s.contains(
            RegExp(r'lib\/domain\/repositories\/services\/[A-z]+.dart'),
          ),
    );

    if (!hasGenerationChanges) {
      return;
    }
  }

  final buildProcess = await Process.start(
    'flutter',
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
  );

  await _writeAndExitIfNotZero(
    buildProcess,
    messageOnFail: 'File generation has failed.',
  );

  final pigeonProcess = await Process.start(
    'flutter',
    [
      'pub',
      'run',
      'pigeon',
      '--input',
      'utils/pigeon/scheme.dart',
      '--dart_out',
      'lib/app/util/pigeon.dart',
      '--objc_header_out',
      'ios/Runner/pigeon.h',
      '--objc_source_out',
      'ios/Runner/pigeon.m',
      '--java_out',
      'android/app/src/main/java/com/voipgrid/vialer/Pigeon.java',
      '--java_package',
      'com.voipgrid.vialer',
    ],
  );

  await _writeAndExitIfNotZero(
    pigeonProcess,
    messageOnFail: 'Pigeon has failed.',
  );
}

const _analyze = [
  'analyze',
  '--fatal-infos',
  '--fatal-warnings',
];
