import 'dart:developer';

import 'package:flutter_segment/flutter_segment.dart';
import 'package:logging/logging.dart';
import 'package:recase/recase.dart';

import '../user/settings/call_setting.dart';
import '../user/settings/settings.dart';
import '../user/user.dart';

abstract class MetricsRepository {
  Future<void> initialize(String? key);

  Future<void> identify(
    User user, [
    Map<String, dynamic>? properties,
  ]);

  Future<void> track(
    String eventName, [
    Map<String, dynamic>? properties,
  ]);

  Future<void> trackSettingChange<T extends Object>(
    SettingKey<T> key,
    T value,
  ) async {
    if (!key.shouldTrack) return;

    await track(
      key.toMetricKey(),
      key.toMetricProperties(value),
    );
  }
}

/// Used in debug environments to just log events to the console for debugging
/// purposes.
class ConsoleLoggingMetricsRepository extends MetricsRepository {
  @override
  Future<void> initialize(String? key) async {
    _log('Console logging metrics have been initialized');

    if (key != null && key.isNotEmpty) {
      _log(
        'Key provided but will be ignored as events are only console logged.',
        level: Level.WARNING,
      );
    }
  }

  @override
  Future<void> identify(
    User user, [
    Map<String, dynamic>? properties,
  ]) =>
      _log('Identified [${user.uuid}]: $properties');

  @override
  Future<void> track(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) =>
      _log('[$eventName]: $properties');

  Future<void> _log(String message, {Level? level}) async {
    // Using log() rather than Logger as this provides nice formatting
    // for the console.
    log(
      message,
      name: 'Metrics',
      level: level?.value ?? 0,
    );
  }
}

class SegmentMetricsRepository extends MetricsRepository {
  @override
  Future<void> initialize(String? key) async {
    assert(
      key != null && key.isNotEmpty,
      'Unable to initialize Segment without a valid key.',
    );

    Segment.config(
      options: SegmentConfig(
        writeKey: key ?? '',
        trackApplicationLifecycleEvents: false,
      ),
    );

    Segment.setContext({
      'ip': '0.0.0.0',
      'device': {
        'id': '',
        'advertisingId': '',
        'token': '',
      },
    });
  }

  @override
  Future<void> identify(
    User user, [
    Map<String, dynamic>? properties,
  ]) async =>
      await Segment.identify(
        userId: user.uuid,
        traits: properties,
      );

  @override
  Future<void> track(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) =>
      Segment.track(eventName: eventName, properties: properties);
}

extension _SettingMetrics<T extends Object> on SettingKey<T> {
  /// Whether or not the content of this setting is PII (Personally Identifiable
  /// Information). This will determine whether or not this setting should
  /// be stored off this device.
  ///
  /// Setting this to `true` still results in an event to be tracked but not the
  /// data stored within.
  bool get isPii => const [
        CallSetting.outgoingNumber,
        CallSetting.mobileNumber,
        CallSetting.availability,
      ].contains(this);

  /// Whether changing this setting should result in an event being sent
  /// to metrics.
  ///
  /// This should usually only be set
  /// to `false` if it is being tracked elsewhere.
  // Put keys in the array that should NOT be tracked.
  bool get shouldTrack => !const [CallSetting.availability].contains(this);

  String toMetricKey() => ReCase(name).snakeCase;

  /// The setting formatted as properties to submit to metrics.
  Map<String, T> toMetricProperties(T value) {
    if (isPii) {
      return const {};
    }

    final key = value is bool ? 'enabled' : 'value';
    return {key: value};
  }
}
