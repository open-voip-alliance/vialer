import 'dart:io';

const codemagicYaml = 'codemagic.yaml';
const pubspecYaml = 'pubspec.yaml';
const pubspecLock = 'pubspec.lock';

/// Upgrades Flutter to a specified version, updates the 'codemagic.yaml' and
/// 'pubspec.yaml' files with the new Flutter version, creates a new git branch
/// with the specified name, commits the changes, and pushes the branch to the
/// remote repository.
///
/// The script requires two arguments: the first argument is the version number
/// of the Flutter SDK to upgrade to, and the second argument is the ticket ID
/// from Gitlab that the changes are related to.
///
/// Before running this script, make sure you have committed and pushed any
/// changes to the remote repository. The script will switch to the 'develop'
/// branch, pull the latest changes from the remote repository, create a new
/// branch with the specified name, and push the changes to the remote
/// repository on this new branch.
///
/// Only the 'pubspec.yaml', 'pubspec.lock', and 'codemagic.yaml' files will be
/// added to the git commit.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    throw Exception(
      'Usage: dart upgrade_flutter.dart <version number> <ticket id>',
    );
  }

  await _checkInCorrectDirectory();

  final versionNumber = arguments[0];
  final ticketId = arguments[1];

  if (await _hasChanges()) {
    throw Exception(
      'There are uncommitted or staged changes. '
      'Please commit or discard them before running this script.',
    );
  }

  await _runProcess('flutter', ['upgrade']);

  await _runProcess('git', ['checkout', 'develop']);
  await _runProcess('git', ['pull', 'origin', 'develop']);

  final newBranchName = '$ticketId-upgrade-flutter-$versionNumber';
  await _runProcess('git', ['checkout', '-b', newBranchName]);

  await _updateYaml(codemagicYaml, versionNumber);
  await _updateYaml(pubspecYaml, versionNumber);

  await _runProcess('flutter', ['pub', 'get']);

  await _runProcess('git', [
    'add',
    pubspecYaml,
    pubspecLock,
    codemagicYaml,
  ]);

  await _runProcess(
    'git',
    ['commit', '-m', 'Upgrade Flutter to version $versionNumber'],
  );
  await _runProcess('git', ['push', 'origin', newBranchName]);
}

Future<void> _updateYaml(String filePath, String value) async {
  final file = File(filePath);
  final key = 'flutter';

  if (!(await file.exists())) {
    throw Exception('File not found: $filePath');
  }

  final contents = await file.readAsString();
  final pattern = RegExp('$key\\s*:\\s*\\d+\\.\\d+\\.\\d+');
  final newContents = contents.replaceAll(pattern, '$key: $value');
  await file.writeAsString(newContents);
}

Future<bool> _hasChanges() async {
  final result = await Process.run('git', ['status', '--porcelain']);
  return result.stdout.toString().trim().isNotEmpty;
}

Future<void> _runProcess(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);

  if (result.exitCode != 0) {
    throw Exception(
      'Error running process: $executable ${arguments.join(' ')}\n'
      'Exit code: ${result.exitCode}\n'
      'Stderr: ${result.stderr}\n'
      'Stdout: ${result.stdout}\n',
    );
  }
}

Future<void> _checkInCorrectDirectory() async {
  final missingFiles = [
    pubspecYaml,
    pubspecLock,
    codemagicYaml,
  ].where((fileName) => !File(fileName).existsSync()).toList();

  if (missingFiles.isNotEmpty) {
    throw Exception(
      'This script must be run in the root of the project.',
    );
  }
}
