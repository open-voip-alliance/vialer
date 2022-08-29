import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/client_available_outgoing_numbers.dart';
import '../entities/setting.dart';
import '../repositories/outgoing_numbers.dart';
import '../use_case.dart';
import 'change_setting.dart';
import 'get_user.dart';

class GetClientOutgoingNumbersUseCase extends UseCase with Loggable {
  final _businessNumbersRepository =
      dependencyLocator<OutgoingNumbersRepository>();
  final _getUser = GetUserUseCase();
  final _changeSetting = ChangeSettingUseCase();

  Future<ClientAvailableOutgoingNumbers> call() async {
    final user = (await _getUser(latest: false))!;

    if (!user.canChangeOutgoingCli) {
      logger.warning('Unable to get client outgoing numbers as no client_uuid');
      return const ClientAvailableOutgoingNumbers(numbers: []);
    }

    final numbers =
        await _businessNumbersRepository.getOutgoingNumbersAvailableToClient(
      user: user,
    );

    await _changeSetting(
      setting: ClientOutgoingNumbersSetting(numbers),
      remote: false,
    );

    return numbers;
  }
}
