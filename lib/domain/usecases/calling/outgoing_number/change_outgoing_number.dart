import 'dart:async';
import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:vialer/data/models/user/refresh/user_refresh_task.dart';
import 'package:vialer/domain/usecases/use_case.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';
import 'package:vialer/domain/usecases/user/refresh/refresh_user.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../data/models/calling/outgoing_number/outgoing_number.dart';
import '../../../../data/models/user/user.dart';
import '../../../../data/repositories/calling/outgoing_number/outgoing_numbers.dart';
import '../../../../data/repositories/legacy/storage.dart';
import '../../../../dependency_locator.dart';

/// This is a use-case rather than via settings because we want to provide the
/// lowest possible response time as the user will be delayed while this is
/// completing - and we also want the smallest number of API requests to
/// completely minimize the possibility of any rate-limiting.
class ChangeOutgoingNumber extends UseCase with Loggable {
  late final _outgoingNumbersRepository =
      dependencyLocator<OutgoingNumbersRepository>();
  late final _refreshUser = RefreshUser();
  User get _user => GetLoggedInUserUseCase()();
  late final _storageRepository = dependencyLocator<StorageRepository>();

  static const _maxRecents = 5;

  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<bool> call(
    OutgoingNumber value, {
    bool refreshUser = false,
    bool resetDoNotAskAgain = false,
  }) async {
    if (value is SuppressedOutgoingNumber) {
      logger.info("Attempting to suppress the user's outgoing number");

      _metricsRepository.track('outgoing-number-suppressed');

      final result =
          await _outgoingNumbersRepository.suppressOutgoingNumber(user: _user);

      conditionallyRefresh(refreshUser);

      return result;
    }

    logger.info("Changing the user's outgoing number");

    _metricsRepository.track('outgoing-number-changed');

    final number = (value as UnsuppressedOutgoingNumber).number;

    // Store the last recent and unique outgoing numbers for easy access.
    final recentOutgoingNumbers = _storageRepository.recentOutgoingNumbers
        .prependElement(value)
        .distinct();

    _storageRepository.recentOutgoingNumbers = recentOutgoingNumbers.slice(
      0,
      min(recentOutgoingNumbers.length - 1, _maxRecents - 1),
    );

    final result = await _outgoingNumbersRepository.changeOutgoingNumber(
      user: _user,
      number: number,
    );

    if (resetDoNotAskAgain) {
      _storageRepository.doNotShowOutgoingNumberSelector = false;
    }

    conditionallyRefresh(refreshUser);

    return result;
  }

  void conditionallyRefresh(bool shouldRefresh) {
    if (shouldRefresh) {
      unawaited(_refreshUser(tasksToPerform: [UserRefreshTask.userCore]));
    }
  }
}
