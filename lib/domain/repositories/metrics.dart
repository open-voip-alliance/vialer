import 'dart:developer';

import 'package:flutter_segment/flutter_segment.dart';
import 'package:logging/logging.dart';

abstract class MetricsRepository {
  Future<void> initialize(String? key);

  Future<void> identify(
    String userId,
    String brandIdentifier,
  );

  Future<void> track(
    String eventName, [
    Map<String, dynamic>? properties,
  ]);
}

/// Used in debug environments to just log events to the console for debugging
/// purposes.
class ConsoleLoggingMetricsRepository implements MetricsRepository {
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
    String userId,
    String brandIdentifier,
  ) =>
      _log('Identified $userId from brand $brandIdentifier');

  @override
  Future<void> track(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) =>
      _log('$eventName: $properties');

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

class SegmentMetricsRepository implements MetricsRepository {
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
    String userId,
    String brandIdentifier,
  ) async =>
      await Segment.identify(
        userId: userId,
        traits: {
          'brand': brandIdentifier,
        },
      );

  @override
  Future<void> track(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) =>
      Segment.track(eventName: eventName, properties: properties);
}
