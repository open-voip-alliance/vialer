import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/domain/user/brand.dart';

import '../../onboarding/is_onboarded.dart';
import '../../use_case.dart';
import '../../user/get_brand.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/user.dart';

part 'get_web_socket_url.freezed.dart';

class GetWebSocketAuthentication extends UseCase {
  bool get _isOnboarded => IsOnboarded()();
  User get _user => GetLoggedInUserUseCase()();
  Brand get _brand => GetBrand()();

  /// Relations deploys their websockets with specific versions which allows
  /// new statuses and information to to be added while still allowing older
  /// clients to be supported.
  ///
  /// This version should only be upgraded when everything else has been
  /// updated to handle the updated payloads.
  static const version = 2;

  RelationsWebSocketAuthentication? call() => _isOnboarded
      ? RelationsWebSocketAuthentication(
          url: '${_brand.userAvailabilityWsUrl}/${_user.client.uuid}?'
              'version=v${version.toString()}',
          headers: {'Authorization': 'Bearer ${_user.token}'},
        )
      : null;
}

@freezed
class RelationsWebSocketAuthentication with _$RelationsWebSocketAuthentication {
  const factory RelationsWebSocketAuthentication({
    required String url,
    @Default({}) Map<String, dynamic> headers,
  }) = _RelationsWebSocketAuthentication;
}
