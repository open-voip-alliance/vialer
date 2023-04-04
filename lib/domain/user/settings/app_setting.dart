import 'dart:io';

import 'settings.dart';

enum AppSetting<T extends Object> with SettingKey<T> {
  remoteLogging<bool>(),
  showDialerConfirmPopup<bool>(),
  showSurveys<bool>(),
  showCallsInNativeRecents<bool>(),
  showTroubleshooting<bool>(),
  showClientCalls<bool>(),
  showOnlineColleaguesOnly<bool>(),
  enableT9ContactSearch<bool>();

  static Map<AppSetting, bool> defaultValues = {
    AppSetting.remoteLogging: false,
    AppSetting.showDialerConfirmPopup: true,
    AppSetting.showSurveys: true,
    AppSetting.showCallsInNativeRecents: true,
    AppSetting.showTroubleshooting: false,
    AppSetting.showClientCalls: false,
    AppSetting.showOnlineColleaguesOnly: true,
    AppSetting.enableT9ContactSearch: Platform.isAndroid,
  };
}
