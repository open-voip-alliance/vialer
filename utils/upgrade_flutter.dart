import 'dart:io';

/// Upgrades Flutter to a specified version, updates the 'codemagic.yaml' and
/// 'pubspec.yaml' files with the new Flutter version, creates a new git branch
/// with the specified name, commits the changes, and pushes the branch to the
/// remote repository.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    throw Exception(
      'Usage: dart upgrade_flutter.dart <version number> <ticket id>',
    );
  }

  final versionNumber = arguments[0];
  final ticketId = arguments[1];

  await Process.run('flutter', ['upgrade']);

  await Process.run('git', ['checkout', 'develop']);
  await Process.run('git', ['pull', 'origin', 'develop']);

  final newBranchName = '$ticketId-upgrade-flutter-$versionNumber';
  await Process.run('git', ['checkout', '-b', newBranchName]);

  await updateYaml('codemagic.yaml', versionNumber);
  await updateYaml('pubspec.yaml', versionNumber);

  await Process.run('flutter', ['pub', 'get']);
  await Process.run('git', ['add', '.']);
  await Process.run(
    'git',
    ['commit', '-m', 'Upgrade Flutter to version $versionNumber'],
  );
  await Process.run('git', ['push', 'origin', newBranchName]);
}

Future<void> updateYaml(String filePath, String value) async {
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
