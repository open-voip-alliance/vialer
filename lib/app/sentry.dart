import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:sentry/sentry.dart';

Future<void> run(Function f, {@required String dsn}) async {
  final sentry = SentryClient(dsn: dsn);

  runZoned(
    f,
    onError: (error, stackTrace) => _capture(sentry, error, stackTrace),
  );

  FlutterError.onError = (details, {forceReport = false}) => _capture(
        sentry,
        details.exception,
        details.stack,
        always: () => FlutterError.dumpErrorToConsole(
          details,
          forceReport: forceReport,
        ),
      );
}

bool get _inDebugMode {
  var _debug = false;

  // Asserts are only run in debug mode, so only then will _debug be true.
  assert(_debug = true);

  return _debug;
}

Future<void> _capture(
  SentryClient client,
  dynamic error,
  StackTrace stackTrace, {
  Function always,
}) async {

  if (_inDebugMode) {
    return;
  }

  try {
    client.capture(
      event: Event(
        exception: error,
        stackTrace: stackTrace,
        contexts: await _contexts,
      ),
    );
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
  } else {
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

    print(info.name);
  }

  return Contexts(
    operatingSystem: os,
    device: device,
  );
}
