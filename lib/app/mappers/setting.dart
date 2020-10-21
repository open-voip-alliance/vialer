import 'package:flutter/widgets.dart';

import '../entities/category.dart';
import '../entities/setting_info.dart';

import '../../domain/entities/setting.dart';

import '../resources/localizations.dart';

extension SettingMapper on Setting {
  SettingInfo toInfo(BuildContext context) {
    if (this is RemoteLoggingSetting) {
      return SettingInfo(
        category: Category.debug,
        name: context.msg.main.settings.list.debug.remoteLogging.title,
        description:
            context.msg.main.settings.list.debug.remoteLogging.description,
        order: 0,
      );
    } else if (this is PhoneNumberSetting) {
      return SettingInfo(
        category: Category.info,
        name: context.msg.main.settings.list.info.phoneNumber.title,
        description:
            context.msg.main.settings.list.info.phoneNumber.description,
        order: 1,
      );
    } else {
      throw UnsupportedError('Vialer error, unknown setting');
    }
  }
}
