import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../API/feedback/feedback_service.dart';
import '../../models/user/user.dart';

@singleton
class FeedbackRepository {
  Future<void> send({
    required String title,
    required String text,
    required User user,
  }) async {
    final service = FeedbackService.create();
    final packageInfo = await PackageInfo.fromPlatform();

    String os, osVersion, model;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;

      os = 'android';
      osVersion = deviceInfo.version.release;
      model = deviceInfo.model;
    } else if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;

      os = 'ios';
      osVersion = deviceInfo.systemVersion;
      // iOS does not provide the direct human-readable iPhone model name, so
      // this will be in the format of e.g. [iPhone14,2] for [iPhone 13]. Some
      // manual translation will be required, implementing this in-app would
      // require maintaining a database of mappings.
      model = deviceInfo.utsname.machine;
    } else {
      throw UnsupportedError(
        'Unsupported platform: ${Platform.operatingSystem}',
      );
    }

    await service.feedback({
      'message': '$title\n\n$text',
      'user': {
        'id': user.uuid,
        'email_address': user.email,
        'given_name': user.firstName,
        'family_name': user.lastName,
        'client_id': user.client.id,
      },
      'application': {
        'id': packageInfo.packageName,
        'version': packageInfo.version,
        'os': os,
        'os_version': osVersion,
        'device_info': model,
      },
    });
  }
}
