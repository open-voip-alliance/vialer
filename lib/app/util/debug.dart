import 'dart:async';

bool get inDebugMode {
  var _debug = false;

  // Asserts are only run in debug mode, so only then will _debug be true.
  assert(_debug = true);

  return _debug;
}

Future<void> doIfNotDebug(FutureOr Function() f) async =>
    !inDebugMode ? f() : null;
