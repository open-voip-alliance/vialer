import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'app/util/debug.dart';

import 'dependency_locator.config.dart';

final dependencyLocator = GetIt.instance;

@InjectableInit()
Future<void> initializeDependencies() =>
    dependencyLocator.initBasedOnEnvironment().allReady();

/// You may sometimes want to load certain instances in debug, if so just
/// annotate the class with @debug.
///
/// It is probably expected that there is an equivalent class to load when
/// not in debug, then annotate with @noDebug.
///
/// @debug/@noDebug does not translate to development and production.
///
/// See [MetricsRepository] for an example.
const debug = Environment('debug');
const noDebug = Environment('noDebug');

extension on GetIt {
  GetIt initBasedOnEnvironment() =>
      init(environment: inDebugMode ? debug.name : noDebug.name);
}
