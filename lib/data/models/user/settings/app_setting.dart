import 'dart:io';

import 'package:vialer/data/models/user/settings/settings.dart';

enum AppSetting<T extends Object> with SettingKey<T> {
  remoteLogging<bool>(),
  showDialerConfirmPopup<bool>(),
  showSurveys<bool>(),
  showCallsInNativeRecents<bool>(),
  showTroubleshooting<bool>(),
  showClientCalls<bool>(),
  showOnlineColleaguesOnly<bool>(),
  enableT9ContactSearch<bool>(),
  hasUnreadFeatureAnnouncements<bool>(),
  enableAdvancedVoipLogging<bool>();

  static Map<AppSetting, Object?> get defaultValues => Map.fromEntries(
        AppSetting.values.map((e) => MapEntry(e, e._defaultValue)),
      );

  Object? get _defaultValue => switch (this) {
        AppSetting.remoteLogging => false,
        AppSetting.showDialerConfirmPopup => true,
        AppSetting.showSurveys => true,
        AppSetting.showCallsInNativeRecents => true,
        AppSetting.showTroubleshooting => false,
        AppSetting.showClientCalls => false,
        AppSetting.showOnlineColleaguesOnly => true,
        AppSetting.enableT9ContactSearch => Platform.isAndroid,
        AppSetting.hasUnreadFeatureAnnouncements => false,
        AppSetting.enableAdvancedVoipLogging => false,
      };
}
