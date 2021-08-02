import 'package:flutter/services.dart';

/// Controls the native behavior of the call screen. This is necessary as
/// Flutter relies on a single activity so we need to enable and disable
/// this additional behavior based on the state of the call.
class CallScreenBehavior {
  static const _channel = MethodChannel('com.voipgrid.vialer/callScreen');

  /// Forces the app to assume call screen behavior which will mean the call
  /// shows on the lock screen and will trigger the screen to turn on.
  static Future<void> enable() async =>
      _channel.invokeMethod('enableCallScreenBehavior');

  /// Disables the call screen behavior, making the app function in
  /// a "default" way.
  static Future<void> disable() async =>
      _channel.invokeMethod('disableCallScreenBehavior');
}
