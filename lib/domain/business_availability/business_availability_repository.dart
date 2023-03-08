import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../app/util/loggable.dart';
import '../user/client.dart';
import '../user/user.dart';
import '../voicemail/voicemail_account.dart';
import 'business_availability_service.dart';
import 'temporary_redirect/temporary_redirect.dart';
import 'temporary_redirect/temporary_redirect_exception.dart';

part 'business_availability_repository.freezed.dart';
part 'business_availability_repository.g.dart';

class BusinessAvailabilityRepository with Loggable {
  final BusinessAvailabilityService _service;

  BusinessAvailabilityRepository(this._service);

  Future<TemporaryRedirect?> getCurrentTemporaryRedirect({
    required User user,
  }) async {
    final response = await _service.getTemporaryRedirect(
      clientUuid: user.client.uuid,
    );

    if (!response.isSuccessful || response.body['id'] == null) {
      return null;
    }

    final temporaryRedirectResponse = _TemporaryRedirectResponse.fromJson(
      response.body as Map<String, dynamic>,
    );

    final voicemail = temporaryRedirectResponse.voicemailAccount(user.client);

    return TemporaryRedirect(
      id: temporaryRedirectResponse.id,
      endsAt: temporaryRedirectResponse.end,
      destination: voicemail != null
          ? TemporaryRedirectDestination.voicemail(voicemail)
          : const TemporaryRedirectDestination.unknown(),
    );
  }

  Future<void> createTemporaryRedirect({
    required User user,
    required TemporaryRedirect temporaryRedirect,
  }) async {
    final requestData = temporaryRedirect.asRequestData();

    final response = await _service.setTemporaryRedirect(
      user.client.uuid,
      requestData,
    );

    if (!response.isSuccessful) {
      throw NoTemporaryRedirectSetupException();
    }
  }

  Future<void> updateTemporaryRedirect({
    required User user,
    required TemporaryRedirect temporaryRedirect,
  }) async {
    final requestData = temporaryRedirect.asRequestData();

    final response = await _service.updateTemporaryRedirect(
      user.client.uuid,
      temporaryRedirect.id.toString(),
      requestData,
    );

    if (!response.isSuccessful) {
      throw NoTemporaryRedirectSetupException();
    }
  }

  Future<void> cancelTemporaryRedirect({
    required User user,
    required TemporaryRedirect temporaryRedirect,
  }) async {
    final response = await _service.deleteTemporaryRedirect(
      user.client.uuid,
      temporaryRedirect.id.toString(),
    );

    if (!response.isSuccessful) {
      throw NoTemporaryRedirectSetupException();
    }
  }
}

@freezed
class _TemporaryRedirectResponse with _$_TemporaryRedirectResponse {
  const factory _TemporaryRedirectResponse({
    required String id,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime end,
    required Map<String, dynamic> destination,
  }) = __TemporaryRedirectResponse;

  factory _TemporaryRedirectResponse.fromJson(Map<String, Object?> json) =>
      _$_TemporaryRedirectResponseFromJson(json);
}

DateTime _dateTimeFromJson(String datetime) => DateTime.parse(datetime);

extension on Client {
  VoicemailAccount? findVoicemailAccount(String id) =>
      voicemailAccounts.firstWhereOrNull((voicemail) => voicemail.id == id);
}

extension on _TemporaryRedirectResponse {
  VoicemailAccount? voicemailAccount(Client client) =>
      client.findVoicemailAccount(
        (destination['id'] as int).toString(),
      );
}

extension on TemporaryRedirect {
  Map<String, dynamic> asRequestData() => {
        'end': endsAt.toString(),
        'destination': {
          'type': 'VOICEMAIL',
          'id': destination.map(
            voicemail: (destination) => destination.voicemailAccount.id,
            unknown: (_) => throw UnableToRedirectToUnknownDestination(),
          ),
        },
      };
}
