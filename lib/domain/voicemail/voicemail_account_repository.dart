import '../../app/util/loggable.dart';
import '../user/user.dart';
import '../voipgrid/voipgrid_api_resource_collector.dart';
import '../voipgrid/voipgrid_service.dart';
import 'voicemail_account.dart';

class VoicemailAccountsRepository with Loggable {
  final VoipgridService _service;
  final VoipgridApiResourceCollector apiResourceCollector =
      VoipgridApiResourceCollector();

  VoicemailAccountsRepository(this._service);

  Future<List<VoicemailAccount>> getVoicemailAccounts({
    required User user,
  }) async {
    final client = user.client;

    if (client == null) {
      logger.warning('Unable to fetch client voicemails as client is null');
      return [];
    }

    return apiResourceCollector.collect(
      requester: (page) => _service.getVoicemailAccounts(
        client.id.toString(),
        page: page,
      ),
      deserializer: VoicemailAccount.fromJson,
    );
  }
}
