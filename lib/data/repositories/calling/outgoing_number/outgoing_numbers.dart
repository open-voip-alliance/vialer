import 'package:injectable/injectable.dart';

import '../../../../presentation/util/automatic_retry.dart';
import '../../../../presentation/util/loggable.dart';
import '../../../API/voipgrid/voipgrid_service.dart';
import '../../../models/calling/outgoing_number/outgoing_number.dart';
import '../../../models/user/client.dart';
import '../../../models/user/user.dart';

@singleton
class OutgoingNumbersRepository with Loggable {
  OutgoingNumbersRepository(this._service);

  final VoipgridService _service;
  final outgoingNumberRetry = AutomaticRetry.http('Change Outgoing Number');

  Future<Iterable<OutgoingNumber>> getOutgoingNumbersAvailableToClient(
    Client client,
  ) =>
      _fetchAllAvailableNumbers(
        clientUuid: client.uuid,
      ).distinct().toList();

  Future<bool> changeOutgoingNumber({
    required User user,
    required String number,
  }) async {
    try {
      await outgoingNumberRetry.run(() async {
        final response = await _service.updateVoipAccount(
          user.client.id.toString(),
          user.appAccountId!,
          {
            'outgoing_caller_identification': {
              'phone_number': number,
            },
          },
        );

        if (!response.isSuccessful) {
          logFailedResponse(response);
          return AutomaticRetryTaskOutput.fail(response);
        }

        return AutomaticRetryTaskOutput.success(response);
      });

      return true;
    } on AutomaticRetryMaximumAttemptsReached {
      return false;
    }
  }

  Future<bool> suppressOutgoingNumber({
    required User user,
  }) =>
      changeOutgoingNumber(
        user: user,
        // The API expects us to use `suppress` formatted like this, despite
        // other APIs returning `suppressed` elsewhere.
        number: 'suppress',
      );

  /// The results we get from the API are paginated, this will go through each
  /// page and return a stream of numbers.
  Stream<OutgoingNumber> _fetchAllAvailableNumbers({
    required String clientUuid,
    int page = 1,
  }) async* {
    final response = await _service.getClientBusinessNumbers(
      clientUuid: clientUuid,
      page: page,
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Fetch Outgoing Numbers');
      return;
    }

    final body = response.body!;

    for (final item in body['items'] as List<dynamic>) {
      yield OutgoingNumber.unsuppressed(
        item['number'] as String,
        description: item['description'] as String,
      );
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
