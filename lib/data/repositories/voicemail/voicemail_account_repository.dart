import 'package:injectable/injectable.dart';

import '../../../presentation/util/loggable.dart';
import '../../API/voipgrid/voipgrid_service.dart';
import '../../models/user/client.dart';
import '../../models/voicemail/voicemail_account.dart';
import '../../models/voipgrid/voipgrid_api_resource_collector.dart';

@singleton
class VoicemailAccountsRepository with Loggable {
  VoicemailAccountsRepository(this._service);

  final VoipgridService _service;
  final VoipgridApiResourceCollector apiResourceCollector =
      VoipgridApiResourceCollector();

  Future<List<VoicemailAccount>> getVoicemailAccounts(Client client) async =>
      apiResourceCollector.collect(
        requester: (page) => _service.getVoicemailAccounts(
          client.id.toString(),
          page: page,
        ),
        deserializer: VoicemailAccount.fromJson,
      );
}
