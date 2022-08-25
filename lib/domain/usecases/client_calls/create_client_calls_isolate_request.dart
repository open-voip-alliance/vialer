import 'package:dartx/dartx.dart';

import '../../entities/system_user.dart';
import '../../repositories/database/client_calls.dart';
import '../../use_case.dart';
import '../get_latest_availability.dart';
import '../get_user.dart';
import '../get_voipgrid_base_url.dart';

class CreateClientCallsIsolateRequestUseCase extends UseCase {
  final _getUser = GetUserUseCase();
  final _getBaseUrl = GetVoipgridBaseUrlUseCase();
  late final _getLatestUserAvailability = GetLatestAvailabilityUseCase();

  Future<List<int>> get _usersPhoneAccounts async =>
      _getLatestUserAvailability().then(
        (availability) =>
            availability?.phoneAccounts
                .filter((phoneAccount) => phoneAccount.id != null)
                .map((phoneAccount) => phoneAccount.id!)
                .toList() ??
            [],
      );

  Future<ClientCallsIsolateRequest> call({
    required Map<DateTime, DateTime> dateRangesToQuery,
  }) async {
    return ClientCallsIsolateRequest(
      user: (await _getUser(latest: false))!,
      voipgridApiBaseUrl: await _getBaseUrl(),
      databasePath: (await getDatabaseDirectory()).path,
      dateRangesToQuery: dateRangesToQuery,
      userPhoneAccountIds: await _usersPhoneAccounts,
    );
  }
}

class ClientCallsIsolateRequest {
  final SystemUser user;
  final String voipgridApiBaseUrl;
  final String databasePath;
  final Map<DateTime, DateTime> dateRangesToQuery;
  final List<int> userPhoneAccountIds;

  const ClientCallsIsolateRequest({
    required this.user,
    required this.voipgridApiBaseUrl,
    required this.databasePath,
    required this.dateRangesToQuery,
    required this.userPhoneAccountIds,
  });
}
