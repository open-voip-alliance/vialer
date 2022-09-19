import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../repositories/metrics.dart';
import '../repositories/outgoing_numbers.dart';
import '../repositories/storage.dart';
import 'get_user.dart';

class ChangeOutgoingNumberUseCase with Loggable {
  static const _maxRecents = 5;

  final _outgoingNumbers = dependencyLocator<OutgoingNumbersRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();
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

    // Store the last 5 recent and unique outgoing numbers for easy access.
    final clientRecentOutgoingNumbers =
        _storageRepository.clientRecentOutgoingNumbers;
    var numbers = [...clientRecentOutgoingNumbers.numbers]
      ..remove(number)
      ..insert(0, number);
    if (numbers.length > _maxRecents) {
      numbers.removeRange(_maxRecents - 1, numbers.length - 1);
    }
    _storageRepository.clientRecentOutgoingNumbers =
        clientRecentOutgoingNumbers.copyWith(numbers: numbers);

    return _outgoingNumbers.changeOutgoingNumber(
      user: user,
      number: number,
    );
  }
}
