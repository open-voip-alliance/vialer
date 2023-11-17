import 'package:args/command_runner.dart';

import 'flutter/upgrade.dart';

/// A listing of all available commands in vialer_cli, it must be registered
/// here to be available.
///
/// If you make a change to this list or to any command within it, you must run
/// `dart pub global activate --source path vialer_cli`
/// to be able ot use it again.
final commands = <Command>[
  UpgradeFlutter(),
];
