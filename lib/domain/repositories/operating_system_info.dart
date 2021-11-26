import 'dart:io';

import 'package:device_info/device_info.dart';
import '../entities/operating_system_info.dart';

class OperatingSystemInfoRepository {
  Future<OperatingSystemInfo> getOperatingSystemInfo() async {
    return OperatingSystemInfo(
      version: Platform.isAndroid
          ? await DeviceInfoPlugin().androidInfo.then((i) => i.version.release)
          // TODO: iOS: Check if this is the format of the version we want.
          : await DeviceInfoPlugin().iosInfo.then((i) => i.systemVersion),
    );
  }
}
