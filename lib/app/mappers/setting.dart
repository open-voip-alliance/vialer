import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../entities/category.dart';
import '../entities/setting_info.dart';

import '../../domain/entities/brand.dart';
import '../../domain/entities/setting.dart';

import '../resources/localizations.dart';

extension SettingMapper on Setting {
  /// If this return null, the setting is not meant to be displayed.
  SettingInfo toInfo(BuildContext context) {
    if (this is PhoneNumberSetting) {
      return SettingInfo(
        item: this,
        order: 0,
        category: Category.accountInfo,
        name: context.msg.main.settings.list.info.phoneNumber.title,
        description:
            context.msg.main.settings.list.info.phoneNumber.description,
      );
    } else if (this is UsePhoneRingtoneSetting) {
      return SettingInfo(
        item: this,
        order: 1,
        category: Category.audio,
        name: context.msg.main.settings.list.audio.usePhoneRingtone.title,
        description:
            context.msg.main.settings.list.audio.usePhoneRingtone.description(
          Provider.of<Brand>(context, listen: false).appName,
        ),
      );
    } else if (this is RemoteLoggingSetting) {
      return SettingInfo(
        item: this,
        order: 2,
        category: Category.debug,
        name: context.msg.main.settings.list.debug.remoteLogging.title,
        description:
            context.msg.main.settings.list.debug.remoteLogging.description,
      );
      // Troubleshooting page starts here, so order resets.
    } else if (this is UseEncryptionSetting) {
      return SettingInfo(
        item: this,
        order: 0,
        category: Category.troubleshootingCalling,
        name: context.msg.main.settings.list.advancedSettings.troubleshooting
            .list.calling.useEncryption,
      );
    } else if (this is AudioCodecSetting) {
      return SettingInfo(
        item: this,
        order: 1,
        category: Category.troubleshootingAudio,
        name: context.msg.main.settings.list.advancedSettings.troubleshooting
            .list.audio.audioCodec,
      );
    } else {
      return null;
    }
  }
}
