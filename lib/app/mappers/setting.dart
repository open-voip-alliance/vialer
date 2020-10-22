import 'package:flutter/widgets.dart';

import '../entities/category.dart';
import '../entities/setting_info.dart';

import '../../domain/entities/setting.dart';

import '../resources/localizations.dart';

extension SettingMapper on Setting {
  SettingInfo toInfo(BuildContext context) {
    if (this is RemoteLoggingSetting) {
      return SettingInfo(
        order: 0,
        category: Category.debug,
        name: context.msg.main.settings.list.debug.remoteLogging.title,
        description:
            context.msg.main.settings.list.debug.remoteLogging.description,
      );
    } else if (this is PhoneNumberSetting) {
      return SettingInfo(
        order: 1,
        category: Category.accountInfo,
        name: context.msg.main.settings.list.info.phoneNumber.title,
        description:
            context.msg.main.settings.list.info.phoneNumber.description,
      );
    } else {
      throw UnsupportedError('Vialer error: Unknown setting: $this');
    }
  }
}
