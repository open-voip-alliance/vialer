import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_locator.config.dart';
import 'presentation/util/debug.dart';

final dependencyLocator = GetIt.instance;

@InjectableInit()
Future<void> initializeDependencies() => dependencyLocator
    .initBasedOnEnvironment()
    .then((getIt) => getIt.allReady());

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
  Future<GetIt> initBasedOnEnvironment() =>
      init(environment: inDebugMode ? debug.name : noDebug.name);
}
