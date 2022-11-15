import 'dart:async';

import '../use_case.dart';

/// Any use case that edits the user should mix this in, and use
/// [editUser] for the complete operation that will eventually modify the
/// user.
mixin SynchronizedUserEditor {
  static var _completer = Completer<void>();

  /// Safely edit the user, will wait if the user is already being
  /// edited.
  Future<T> editUser<T>(FutureOr<T> Function() block) async {
    if (!_completer.isCompleted) {
      await _completer.future;
    }

    _completer = Completer();
    final result = await block();
    _completer.complete();
    return result;
  }
}
