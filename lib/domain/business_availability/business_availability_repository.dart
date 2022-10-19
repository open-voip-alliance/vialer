import 'package:freezed_annotation/freezed_annotation.dart';

import '../user/user.dart';
import '../voicemail/voicemail_account.dart';
import 'business_availability_service.dart';
import 'temporary_redirect.dart';
import 'temporary_redirect_exception.dart';

part 'business_availability_repository.freezed.dart';
part 'business_availability_repository.g.dart';

class BusinessAvailabilityRepository {
  final BusinessAvailabilityService _service;

  BusinessAvailabilityRepository(this._service);

  Map<String, dynamic> _prepareRequestData(
    TemporaryRedirect temporaryRedirect,
  ) =>
      {
        'end': temporaryRedirect.endsAt.toString(),
        'destination': temporaryRedirect.destination,
      };

  Future<TemporaryRedirect?> getCurrentTemporaryRedirect({
    required User user,
  }) async {
    final response = await _service.getTemporaryRedirect(
      clientUuid: user.uuid,
    );

    if (!response.isSuccessful) {
      throw NoTemporaryRedirectSetupException();
    }

    final temporaryRedirectResponse = _TemporaryRedirectResponse.fromJson(
      response.body as Map<String, dynamic>,
    );

    //TODO: Replace the dummy data below with real data
    //TODO: from the list we will be storing locally
    final destination = const TemporaryRedirectDestination.voicemail(
      VoicemailAccount(
        id: 'Example Voicemail Id',
        name: 'Example Voicemail Name',
        description: 'Example Voicemail Details',
      ),
    );

    final endsAt = DateTime.tryParse(
      temporaryRedirectResponse.end,
    );

    if (endsAt == null) {
      throw NoTemporaryRedirectSetupException();
    }

    return TemporaryRedirect(
      id: temporaryRedirectResponse.id,
      endsAt: endsAt,
      destination: destination,
    );
  }

  Future<void> createTemporaryRedirect({
    required User user,
    required TemporaryRedirect temporaryRedirect,
  }) async {
    final requestData = _prepareRequestData(temporaryRedirect);

    final response = await _service.setTemporaryRedirect(
      user.uuid,
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
    final requestData = _prepareRequestData(temporaryRedirect);

    final response = await _service.updateTemporaryRedirect(
      user.uuid,
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
      user.uuid,
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
    required String end,
    required Map<String, dynamic> destinations,
  }) = __TemporaryRedirectResponse;

  factory _TemporaryRedirectResponse.fromJson(Map<String, Object?> json) =>
      _$_TemporaryRedirectResponseFromJson(json);
}
