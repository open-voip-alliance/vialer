import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../commands/registrar.dart';

void main(List<String> arguments) {
  final runner = CommandRunner<void>(
    'vialer',
    'Useful command line utilities to help while developing Vialer.',
  );

  for (final command in commands) {
    runner.addCommand(command);
  }

  // ignore: argument_type_not_assignable_to_error_handler
  runner.run(arguments).catchError((Exception error) {
    if (error is! UsageException) throw error;
    stdout.write(error);
    exit(64);
  });
}

extension ValidateArguments on Command<void> {
  ArgResults get args => argResults!;
}
