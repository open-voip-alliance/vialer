// ignore_for_file: unnecessary_cast

import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/use_case.dart';
import 'package:vialer/domain/user/settings/settings.dart';

import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../user.dart';
import 'app_setting.dart';
import 'call_setting.dart';

/// Will preserve any settings found in [preserve] for future sessions, so when
/// the user logs back in.
///
/// This uses [StorageRepository] so `StorageRepository.clear()` must be called
/// *before* executing this.
class PreserveCrossSessionSettings extends UseCase with Loggable {
  final _storage = dependencyLocator<StorageRepository>();

  /// Must not include any user-specific settings, should almost always only be
  /// [bool] or otherwise very simple settings.
  ///
  /// For example, it should NOT store [CallSetting.outgoingNumber] as that is
  /// a setting only relevant to the currently logged-in user.
  static const preserve = [
    CallSetting.usePhoneRingtone,
    AppSetting.enableT9ContactSearch,
    AppSetting.remoteLogging,
    AppSetting.showCallsInNativeRecents,
    AppSetting.showClientCalls,
    AppSetting.showOnlineColleaguesOnly,
    AppSetting.showTroubleshooting,
  ];

  Future<void> call(User user) async {
    final preserved = Map.fromEntries(
      preserve.map((key) => MapEntry(
            key as SettingKey,
            user.settings.get(key as SettingKey),
          )),
    );

    logger.info(
      'Preserving [${preserve.map((e) => e.name).join(', ')}] for future login',
    );

    _storage.previousSessionSettings = preserved;
  }
}
