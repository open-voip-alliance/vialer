import 'dart:async';

import 'package:recase/recase.dart';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_brand.dart';
import '../user/get_logged_in_user.dart';
import '../user/user.dart';
import 'metrics.dart';

class IdentifyForTrackingUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
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
        properties[a.key.name.paramCase] = a.value;
      }
    }

    return properties;
  }
}
