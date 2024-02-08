import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../presentation/util/loggable.dart';
import '../../API/business_availability/business_availability_service.dart';
import '../../models/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../models/business_availability/temporary_redirect/temporary_redirect_exception.dart';
import '../../models/user/client.dart';
import '../../models/user/user.dart';
import '../../models/voicemail/voicemail_account.dart';

part 'business_availability_repository.freezed.dart';
part 'business_availability_repository.g.dart';

@injectable
class BusinessAvailabilityRepository with Loggable {
  BusinessAvailabilityRepository(this._service);

  final BusinessAvailabilityService _service;

  Future<TemporaryRedirect?> getCurrentTemporaryRedirect({
    required User user,
  }) async {
    final response = await _service.getTemporaryRedirect(
      clientUuid: user.client.uuid,
    );

    if (!response.isSuccessful || response.body!['id'] == null) {
      return null;
    }

    final temporaryRedirectResponse = _TemporaryRedirectResponse.fromJson(
      response.body!,
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
class _TemporaryRedirectResponse with _$TemporaryRedirectResponse {
  const factory _TemporaryRedirectResponse({
    required String id,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime end,
    required Map<String, dynamic> destination,
  }) = __TemporaryRedirectResponse;

  factory _TemporaryRedirectResponse.fromJson(Map<String, Object?> json) =>
      _$TemporaryRedirectResponseFromJson(json);
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
  Map<String, dynamic> asRequestData() {
    final destination = this.destination;

    if (destination is! Voicemail) {
      throw UnableToRedirectToUnknownDestination();
    }

    final voicemail = destination.voicemailAccount;

    return {
      // Has to be UTC, because we need a time-zone aware string,
      // and `toIso8601String` only adds time-zone information
      // with UTC DateTimes.
      'end': endsAt.toUtc().toIso8601String(),
      'destination': {
        'type': 'VOICEMAIL',
        'id': voicemail.id,
        if (voicemail.uuid.isNotBlank) 'uuid': voicemail.uuid,
      },
    };
  }
}
