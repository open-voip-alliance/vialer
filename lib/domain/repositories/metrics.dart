// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_segment/flutter_segment.dart';

import '../../app/util/debug.dart';

class MetricsRepository {
  MetricsRepository() {
    // Ensure some sensitive tracking stuff is always redacted.
    doIfNotDebug(() {
      Segment.setContext({
        'ip': '0.0.0.0',
        'device': {
          'id': '',
          'advertisingId': '',
          'token': '',
        },
      });
    });
  }

  Future<void> identify(String userId, String brandIdentifier) async {
    await doIfNotDebug(() async {
      await Segment.identify(
        userId: userId,
        traits: {
          'brand': brandIdentifier,
        },
      );
    });
  }

  Future<void> track(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) async {
    await doIfNotDebug(() async {
      await Segment.track(eventName: eventName, properties: properties);
    });
  }
}
