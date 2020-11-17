import 'package:flutter/widgets.dart';

import '../entities/category_info.dart';
import '../entities/category.dart';
import '../entities/setting_route.dart';

import '../resources/theme.dart';
import '../resources/localizations.dart';

extension CategoryMapper on Category {
  CategoryInfo toInfo(BuildContext context) {
    switch (this) {
      case Category.accountInfo:
        return CategoryInfo(
          item: this,
          order: 0,
          icon: VialerSans.user,
          title: context.msg.main.settings.list.info.title,
        );
      case Category.audio:
        return CategoryInfo(
          item: this,
          order: 1,
          icon: VialerSans.speaker,
          title: context.msg.main.settings.list.audio.title,
        );
      case Category.debug:
        return CategoryInfo(
          item: this,
          order: 3,
          icon: VialerSans.bug,
          title: context.msg.main.settings.list.debug.title,
        );
      case Category.advancedSettings:
        return CategoryInfo(
          item: this,
          order: 10,
          icon: VialerSans.bug,
          title: context.msg.main.settings.list.advancedSettings.title,
        );
      // Troubleshooting page
      case Category.troubleshootingCalling:
        return CategoryInfo(
          item: this,
          route: SettingRoute.troubleshooting,
          order: 0,
          icon: VialerSans.phone,
          title: context.msg.main.settings.list.advancedSettings.troubleshooting
              .list.calling.title,
        );
      case Category.troubleshootingAudio:
        return CategoryInfo(
          item: this,
          route: SettingRoute.troubleshooting,
          order: 1,
          icon: VialerSans.speaker,
          title: context.msg.main.settings.list.advancedSettings.troubleshooting
              .list.audio.title,
        );
      case Category.portalLinks:
        return CategoryInfo(
          item: this,
          order: 2,
          icon: VialerSans.voipCloud,
          title: context.msg.main.settings.list.portalLinks.title,
        );
      default:
        throw UnsupportedError('Vialer error: Unknown category');
    }
  }
}
