import 'dart:io';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    throw Exception(
      'Usage: dart upgrade_flutter.dart <version number> <ticket id>',
    );
  }

  final versionNumber = arguments[0];
  final ticketId = arguments[1];

  if (await _hasChanges()) {
    throw Exception(
      'There are uncommitted or staged changes. '
      'Please commit or discard them before running this script.',
    );
  }
print('as');
  // await _runProcess('flutter', ['upgrade']);
  //
  // await _runProcess('git', ['checkout', 'develop']);
  // await _runProcess('git', ['pull', 'origin', 'develop']);
  //
  // final newBranchName = '$ticketId-upgrade-flutter-$versionNumber';
  // await _runProcess('git', ['checkout', '-b', newBranchName]);
  //
  // await _updateYaml('codemagic.yaml', versionNumber);
  // await _updateYaml('pubspec.yaml', versionNumber);
  //
  // await _runProcess('flutter', ['pub', 'get']);
  //
  // await _runProcess('git', [
  //   'add',
  //   'pubspec.lock',
  //   'pubspec.yaml',
  //   'codemagic.yaml',
  // ]);
  //
  // await _runProcess(
  //   'git',
  //   ['commit', '-m', 'Upgrade Flutter to version $versionNumber'],
  // );
  // await _runProcess('git', ['push', 'origin', newBranchName]);
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
