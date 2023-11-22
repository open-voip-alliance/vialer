import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';

import 'operating_system_info.dart';

@singleton
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
