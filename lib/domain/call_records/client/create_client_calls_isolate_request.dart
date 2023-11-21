import '../../../dependency_locator.dart';
import '../../calling/voip/destination.dart';
import '../../legacy/storage.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/user.dart';
import '../../voipgrid/get_voipgrid_base_url.dart';
import 'database/client_calls.dart';

class CreateClientCallsIsolateRequestUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetLoggedInUserUseCase();
  final _getBaseUrl = GetVoipgridBaseUrlUseCase();

  List<int> get _usersPhoneAccounts {
    final destinations = _storageRepository.availableDestinations;

    return destinations
        .whereType<PhoneAccount>()
        .map((phoneAccount) => phoneAccount.id)
        .toList();
  }

  Future<ClientCallsIsolateRequest> call({
    required Map<DateTime, DateTime> dateRangesToQuery,
  }) async {
    return ClientCallsIsolateRequest(
      user: _getUser(),
      voipgridApiBaseUrl: _getBaseUrl(),
      databasePath: (await ClientCallsDatabase.databaseFile).path,
      dateRangesToQuery: dateRangesToQuery,
      userPhoneAccountIds: _usersPhoneAccounts,
    );
  }
}

class ClientCallsIsolateRequest {
  const ClientCallsIsolateRequest({
    required this.user,
    required this.voipgridApiBaseUrl,
    required this.databasePath,
    required this.dateRangesToQuery,
    required this.userPhoneAccountIds,
  });

  final User user;
  final String voipgridApiBaseUrl;
  final String databasePath;
  final Map<DateTime, DateTime> dateRangesToQuery;
  final List<int> userPhoneAccountIds;
}
