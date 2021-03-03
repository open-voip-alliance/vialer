import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';

import '../dependency_locator.dart';
import '../domain/repositories/env.dart';
import '../domain/usecases/get_user.dart';
import 'util/debug.dart';

Future<void> run(void Function() f) async {
  final dsn = await dependencyLocator.get<EnvRepository>().sentryDsn;

  if (dsn == null || dsn.isEmpty) {
    f();
    return;
  }

  final sentry = SentryClient(dsn: dsn);

  FlutterError.onError = (details) => _capture(
        sentry,
        details.exception,
        details.stack,
        always: () => FlutterError.dumpErrorToConsole(details),
      );

  runZoned(
    f,
    onError: (error, stackTrace) =>
        _capture(sentry, error, stackTrace as StackTrace),
  );
}

Future<void> _capture(
  SentryClient client,
  dynamic error,
  StackTrace stackTrace, {
  Function always,
}) async {
  final getUser = GetUserUseCase();

  try {
    final user = await getUser(latest: false);

    doIfNotDebug(() async {
      client.capture(
        event: Event(
          exception: error,
          stackTrace: stackTrace,
          contexts: await _contexts,
          userContext: user != null ? User(id: user.uuid) : null,
        ),
      );
    });
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    print('Sending report to sentry.io failed: $e');
    print('Original error: $error');
  } finally {
    always();
  }
}

Future<Contexts> get _contexts async {
  final plugin = DeviceInfoPlugin();

  OperatingSystem os;
  Device device;

  if (Platform.isAndroid) {
    final info = await plugin.androidInfo;

    os = OperatingSystem(
      name: 'Android',
      version: info.version.release,
      build: info.version.sdkInt.toString(),
    );

    device = Device(
      brand: info.brand,
      manufacturer: info.manufacturer,
      model: info.model,
      simulator: !info.isPhysicalDevice,
    );
  } else if (Platform.isIOS) {
    final info = await plugin.iosInfo;

    os = OperatingSystem(
      name: 'iOS',
      version: info.systemVersion,
    );

    device = Device(
      family: info.model,
      model: info.utsname.machine,
      simulator: !info.isPhysicalDevice,
    );
  }

  return Contexts(
    operatingSystem: os,
    device: device,
  );
}
