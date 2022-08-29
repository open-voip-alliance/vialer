import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../repositories/metrics.dart';
import '../repositories/outgoing_numbers.dart';
import 'get_user.dart';

class ChangeOutgoingNumberUseCase with Loggable {
  final _outgoingNumbers = dependencyLocator<OutgoingNumbersRepository>();
  final _metrics = dependencyLocator<MetricsRepository>();
  final _getUser = GetUserUseCase();

  Future<bool> call({required String number}) async {
    final user = (await _getUser(latest: false))!;

    if (!user.canChangeOutgoingCli) {
      logger.warning('Unable to update outgoing number, no client_uuid');
      return false;
    }

    logger.info('Changing the user\'s outgoing number');

    _metrics.track('change-outgoing-number');

    return _outgoingNumbers.changeOutgoingNumber(
      user: user,
      number: number,
    );
  }
}
