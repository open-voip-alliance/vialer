import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../../bin/vialer_cli.dart';

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
class UpgradeFlutter extends Command<void> {
  UpgradeFlutter() {
    argParser
      ..addOption(
        'version',
        mandatory: true,
        help: 'The Flutter version that should be upgraded to',
        valueHelp: '3.16.0',
      )
      ..addOption(
        'ticket-id',
        mandatory: true,
        help: 'The Gitlab ticket that will be used for branch and commit names',
        valueHelp: '1345',
      );
  }

  @override
  final category = 'flutter';

  @override
  final name = 'flutter-upgrade';

  @override
  final description = 'Upgrade Flutter then pushes an appropriately named '
      'branch';

  @override
  final invocation = 'flutter-upgrade --version=3.16.0 --ticket-id=1345';

  Future<void> run() async {
    await _checkInCorrectDirectory();

    final versionNumber = args['version'].toString();
    final ticketId = args['ticket-id'].toString();

    if (await _hasChanges()) {
      throw Exception(
        '❌ There are uncommitted or staged changes. '
        'Please commit or discard them before running this script.',
      );
    }

    print('🆙 Upgrading flutter');
    await _runProcess('flutter', ['upgrade']);

    print('⚙️ Checking out develop branch');
    await _runProcess('git', ['checkout', 'develop']);

    print('⚙️ Pulling develop');
    await _runProcess('git', ['pull', 'origin', 'develop']);

    print('⚙️ Creating branch');
    final newBranchName = '$ticketId-upgrade-flutter-$versionNumber';
    await _runProcess('git', ['checkout', '-b', newBranchName]);

    print('⚙️ Updating files');
    await _updateYaml(codemagicYaml, versionNumber);
    await _updateYaml(pubspecYaml, versionNumber);

    print('🆙 Upgrading packages');
    await _runProcess('flutter', ['pub', 'get']);

    print('⚙️ Adding files to git');
    await _runProcess('git', [
      'add',
      pubspecYaml,
      pubspecLock,
      codemagicYaml,
    ]);

    print('⚙️ Comminting files to git');
    await _runProcess(
      'git',
      ['commit', '-m', 'chore(flutter): upgrade to version $versionNumber'],
    );

    print('⚙️ Pushing files');
    await _runProcess('git', ['push', 'origin', newBranchName]);

    print('🙌 Finished upgrading to Flutter $versionNumber, '
        'you can create the MR on gitlab');
  }

  Future<void> _updateYaml(String filePath, String value) async {
    final file = File(filePath);
    const key = 'flutter';

    if (!(await file.exists())) {
      throw Exception('❌ File not found: $filePath');
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
        '❌ Error running process: $executable ${arguments.join(' ')}\n'
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
        '❌ This script must be run in the root of the project.',
      );
    }
  }
}
