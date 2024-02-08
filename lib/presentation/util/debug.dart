import 'dart:async';

bool get inDebugMode {
  var debug = false;

  // Asserts are only run in debug mode, so only then will _debug be true.
  // ignore: prefer_asserts_with_message
  assert(debug = true);

  return debug;
}

Future<void> doIfNotDebug(FutureOr<void> Function() f) async =>
    !inDebugMode ? f() : null;
