import '../../app/util/loggable.dart';
import '../user/client.dart';
import '../voipgrid/voipgrid_api_resource_collector.dart';
import '../voipgrid/voipgrid_service.dart';
import 'voicemail_account.dart';

class VoicemailAccountsRepository with Loggable {
  VoicemailAccountsRepository(this._service);

  final VoipgridService _service;
  final VoipgridApiResourceCollector apiResourceCollector =
      VoipgridApiResourceCollector();

  VoicemailAccountsRepository(this._service);

  Future<List<VoicemailAccount>> getVoicemailAccounts(Client client) async =>
      apiResourceCollector.collect(
        requester: (page) => _service.getVoicemailAccounts(
          client.id.toString(),
          page: page,
        ),
        deserializer: VoicemailAccount.fromJson,
      );
}
