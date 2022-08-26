import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../repositories/metrics.dart';
import '../repositories/outgoing_numbers.dart';
import 'get_user.dart';

class SuppressOutgoingNumberUseCase with Loggable {
  final _metrics = dependencyLocator<MetricsRepository>();
  final _outgoingNumbers = dependencyLocator<OutgoingNumbersRepository>();
  final _getUser = GetUserUseCase();

  Future<bool> call() async {
    final user = await _getUser(latest: false);

    logger.info('Attempting to suppress the user\'s outgoing number');

    _metrics.track('suppress-outgoing-number');

    return _outgoingNumbers.suppressOutgoingNumber(
      user: user!,
    );
  }
}
