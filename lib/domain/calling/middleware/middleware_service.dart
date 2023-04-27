import 'dart:async';

import 'package:chopper/chopper.dart' hide JsonConverter;

import '../../user/get_stored_user.dart';
import '../../util.dart';
import '../../voipgrid/client_voip_config.dart';

part 'middleware_service.chopper.dart';

@ChopperApi(baseUrl: '/api/')
abstract class MiddlewareService extends ChopperService {
  static Future<MiddlewareService> create() async {
    final voipConfig =
        GetStoredUserUseCase()()?.client.voip ?? ClientVoipConfig.fallback();

    return _$MiddlewareService(
      ChopperClient(
        baseUrl: voipConfig.middlewareUrl.toString(),
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(),
          UnauthorizedResponseInterceptor(),
        ],
      ),
    );
  }

  @Post(path: 'android-device/')
  Future<Response<String>> postAndroidDevice({
    @Field() required String name,
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field('os_version') required String osVersion,
    @Field('client_version') required String clientVersion,
    @Field() required String app,
    @Field('app_startup_timestamp') String? appStartupTime,
    @Field('dnd') bool dnd = false,
  });

  @Delete(path: 'android-device/')
  Future<Response<Map<String, dynamic>>> deleteAndroidDevice({
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field() required String app,
  });

  @Post(path: 'apns-device/')
  Future<Response<String>> postAppleDevice({
    @Field() required String name,
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field('os_version') required String osVersion,
    @Field('client_version') required String clientVersion,
    @Field() required String app,
    @Field() required bool sandbox,
    @Field('remote_notification_token') required String remoteNotificationToken,
    @Field('app_startup_timestamp') String? appStartupTime,
    @Field('push_profile') String pushProfile = 'once',
    @Field('dnd') bool dnd = false,
  });

  @Delete(path: 'apns-device/')
  Future<Response<Map<String, dynamic>>> deleteAppleDevice({
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field() required String app,
  });

  @Post(path: 'call-response/')
  Future<Response<Map<String, dynamic>>> callResponse({
    @Field('unique_key') required String uniqueKey,
    @Field() required String available,
    @Field('message_start_time') required String messageStartTime,
    @Field('sip_user_id') required String sipUserId,
  });
}
