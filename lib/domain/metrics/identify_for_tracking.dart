// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:recase/recase.dart';
import 'package:vialer/app/util/pigeon.dart';
import 'package:vialer/domain/user/settings/app_setting.dart';

import '../../../dependency_locator.dart';
import '../colltacts/colltact_tab.dart';
import '../legacy/storage.dart';
import '../relations/colleagues/colleague.dart';
import '../use_case.dart';
import '../user/client.dart';
import '../user/get_brand.dart';
import '../user/get_logged_in_user.dart';
import '../user/settings/call_setting.dart';
import '../user/settings/settings.dart';
import '../user/user.dart';
import 'metrics.dart';

class IdentifyForTrackingUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _storage = dependencyLocator<StorageRepository>();
  final _getBrand = GetBrand();
  final _getUser = GetLoggedInUserUseCase();

  /// Add an artificial delay so we know that the user has been properly
  /// identified before sending other events.
  static const _artificialDelay = Duration(seconds: 2);

  Future<void> call() async {
    final user = _getUser();

    return _metricsRepository.identify(
      user,
      <String, dynamic>{
        'brand': _getBrand().identifier,
        ...await _platformIdentifyProperties(),
        ...user.toIdentifyProperties(),
        ...user.client.toIdentifyProperties(),
        ..._storage.grantedVoipgridPermissions.toIdentifyProperties(),
        ..._storage.colleagues.toIdentifyProperties(),
        ..._storage.currentColltactTab.toIdentifyProperties(),
        ..._storage.doNotShowOutgoingNumberSelectorOrNull
            .toIdentifyProperties(),
      },
    ).then((_) => Future.delayed(_artificialDelay));
  }

  Future<Map<String, dynamic>> _platformIdentifyProperties() async => {
        if (Platform.isAndroid)
          'google-play-services-available': await _isPlayServicesAvailable,
      };
}

late final _isPlayServicesAvailable = GooglePlayServices().isAvailable();

extension on User {
  Map<String, dynamic> toIdentifyProperties() {
    final properties = <String, dynamic>{};

    final settingsToInclude = [
      ...AppSetting.values,
      ...CallSetting.values,
    ];

    for (final i in settingsToInclude) {
      final key = i as SettingKey<Object>;

      // For now we only care about bool settings, but can be expanded in the
      // future.
      if (key.valueType == bool) {
        properties[key.asPropertyKey] = settings.get(key);
      }
    }

    return properties;
  }
}

extension on List<String> {
  Map<String, dynamic> toIdentifyProperties() => {
        for (final permission in this) 'voipgrid-permission-$permission': true,
      };
}

extension on List<Colleague> {
  Map<String, dynamic> toIdentifyProperties() {
    final result =
        partition((colleague) => colleague is UnconnectedVoipAccount);

    return <String, dynamic>{
      'number_of_colleagues': result[1].length,
      'number_of_unconnected_voip_accounts': result[0].length,
    };
  }
}

extension on ColltactTab? {
  Map<String, dynamic> toIdentifyProperties() => this != null
      ? <String, dynamic>{
          'colltact-tab': this!.name,
        }
      : const <String, dynamic>{};
}

extension on SettingKey {
  String get asPropertyKey {
    // We don't care about the generic argument, just the base type.
    final type = runtimeType.toString().replaceAll(RegExp('<.+>'), '');

    return '$type-$name'.paramCase;
  }
}

extension on Client {
  Map<String, dynamic> toIdentifyProperties() => <String, dynamic>{
        'outgoing-numbers-amount': outgoingNumbers.length,
      };
}

extension on bool? {
  Map<String, dynamic> toIdentifyProperties() => <String, dynamic>{
        if (this != null) 'do-not-show-outgoing-number-prompt': this,
      };
}
