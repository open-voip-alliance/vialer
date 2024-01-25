import '../../../../../dependency_locator.dart';
import '../../../../repositories/calling/outgoing_number/outgoing_numbers.dart';
import '../../client.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientAvailableOutgoingNumbers extends ClientRefreshTaskPerformer {
  const RefreshClientAvailableOutgoingNumbers();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final outgoingNumbers = await dependencyLocator<OutgoingNumbersRepository>()
        .getOutgoingNumbersAvailableToClient(client);

    return (Client client) => client.copyWith(
          outgoingNumbers: () => outgoingNumbers,
        );
  }
}
