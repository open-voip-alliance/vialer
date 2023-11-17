import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../commands/registrar.dart';

void main(List<String> arguments) {
  final runner = CommandRunner(
    'vialer',
    'Useful command line utilities to help while developing Vialer.',
  );

  for (final command in commands) {
    runner.addCommand(command);
  }

  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    stdout.write(error);
    exit(64);
  });
}

extension ValidateArguments on Command {
  ArgResults get args => argResults!;
}
