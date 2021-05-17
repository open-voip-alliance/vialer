import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import '../entities/system_user.dart';

import 'services/feedback.dart';

class FeedbackRepository {
  Future<void> send({
    required String title,
    required String text,
    required SystemUser user,
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
      model = deviceInfo.model;
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
      },
      'application': {
        'id': packageInfo.packageName,
        'version': packageInfo.version,
        'os': os,
        'os_version': osVersion,
        'device_info': model,
      }
    });
  }
}
