import '../../app/util/loggable.dart';
import '../entities/client_available_outgoing_numbers.dart';
import '../entities/system_user.dart';
import 'services/voipgrid.dart';

class OutgoingNumbersRepository with Loggable {
  final VoipgridService _service;

  OutgoingNumbersRepository(this._service);

  Future<ClientAvailableOutgoingNumbers> getOutgoingNumbersAvailableToClient({
    required SystemUser user,
  }) async =>
      ClientAvailableOutgoingNumbers(
        numbers: await _fetchAllAvailableNumbers(
          clientUuid: user.clientUuid!,
        ).distinct().toList(),
      );

  Future<bool> changeOutgoingNumber({
    required SystemUser user,
    required String number,
  }) async {
    final response = await _service.updateVoipAccount(
      user.clientId!.toString(),
      user.appAccountId!,
      {
        'outgoing_caller_identification': {
          'phone_number': number,
        },
      },
    );

    if (!response.isSuccessful) {
      logger.severe(
        'Unable to update outgoing mobile number: ${response.bodyString}',
      );
    }

    return response.isSuccessful;
  }

  Future<bool> suppressOutgoingNumber({
    required SystemUser user,
  }) =>
      changeOutgoingNumber(
        user: user,
        // The API expects us to use `suppress` formatted like this, despite
        // other APIs returning `suppressed` elsewhere.
        number: 'suppress',
      );

  /// The results we get from the API are paginated, this will go through each
  /// page and return a stream of numbers.
  Stream<String> _fetchAllAvailableNumbers({
    required String clientUuid,
    int page = 1,
  }) async* {
    final response = await _service.getClientBusinessNumbers(
      clientUuid: clientUuid,
      page: page,
    );

    final body = response.body;

    for (final number in (body['items'] as List<dynamic>)) {
      yield number as String;
    }

    final next = body['next'] as String?;

    if (next != null && next.isNotEmpty) {
      yield* _fetchAllAvailableNumbers(
        clientUuid: clientUuid,
        page: page + 1,
      );
    }
  }
}
