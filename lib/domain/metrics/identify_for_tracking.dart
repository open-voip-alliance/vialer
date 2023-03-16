import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:recase/recase.dart';

import '../../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';
import '../user/get_brand.dart';
import '../user/get_logged_in_user.dart';
import '../user/settings/settings.dart';
import '../user/user.dart';
import '../user_availability/colleagues/colleague.dart';
import 'metrics.dart';

class IdentifyForTrackingUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _getBrand = GetBrand();
  final _getUser = GetLoggedInUserUseCase();

  /// Add an artificial delay so we know that the user has been properly
  /// identified before sending other events.
  static const _artificialDelay = Duration(seconds: 2);

  Future<void> call() async {
    final user = _getUser();

    return await _metricsRepository.identify(
      user,
      {
        'brand': _getBrand().identifier,
        ...user.toIdentifyProperties(),
        ..._storageRepository.grantedVoipgridPermissions.toIdentifyProperties(),
        ..._storageRepository.colleagues.toIdentifyProperties(),
      },
    ).then((_) => Future.delayed(_artificialDelay));
  }
}

extension on User {
  Map<String, dynamic> toIdentifyProperties() {
    final properties = <String, dynamic>{};

    for (final a in settings.entries) {
      // For now we only care about bool settings, but can be expanded in the
      // future.
      if (a.value is bool) {
        properties[a.key.asPropertyKey] = a.value;
      }
    }

    return properties;
  }
}

extension on List<String> {
  Map<String, dynamic> toIdentifyProperties() => {
        'granted-voipgrid-permissions': this,
      };
}

extension on List<Colleague> {
  Map<String, dynamic> toIdentifyProperties() {
    final result =
        partition((colleague) => colleague is UnconnectedVoipAccount);

    return {
      'number_of_colleagues': result[1].length,
      'number_of_unconnected_voip_accounts': result[0].length,
    };
  }
}

extension on SettingKey {
  String get asPropertyKey {
    // We don't care about the generic argument, just the base type.
    final type = runtimeType.toString().replaceAll(RegExp(r'<.+>'), '');

    return '$type-$name'.paramCase;
  }
}
