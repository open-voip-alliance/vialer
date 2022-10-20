import '../../app/util/loggable.dart';
import '../entities/user.dart';
import '../entities/voicemail.dart';
import 'services/voipgrid.dart';
import 'voipgrid_api_resource_collector.dart';

class VoicemailRepository with Loggable {
  final VoipgridService _service;
  final VoipgridApiResourceCollector apiResourceCollector =
      VoipgridApiResourceCollector();

  VoicemailRepository(this._service);

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
