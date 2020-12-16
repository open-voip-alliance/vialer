import 'package:flutter_segment/flutter_segment.dart';

import '../../app/util/debug.dart';

class MetricsRepository {
  Future<void> identify(String userId) async {
    await doIfNotDebug(() async {
      await Segment.identify(userId: userId);
    });
  }

  Future<void> track(
    String eventName, [
    Map<String, dynamic> properties,
  ]) async {
    await doIfNotDebug(() async {
      await Segment.track(eventName: eventName, properties: properties);
    });
  }
}
