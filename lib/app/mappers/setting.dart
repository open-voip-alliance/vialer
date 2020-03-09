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
        name: context.msg.main.settings.list.debug.remoteLogging,
      );
    } else {
      throw UnsupportedError('Unknown setting');
    }
  }
}