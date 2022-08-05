import 'dart:async';

import 'package:chopper/chopper.dart' hide JsonConverter;

import '../../usecases/get_server_config.dart';
import 'util.dart';

part 'middleware.chopper.dart';

@ChopperApi(baseUrl: '/api/')
abstract class MiddlewareService extends ChopperService {
  static Future<MiddlewareService> create() async {
    final _getServerConfig = GetServerConfigUseCase();
    final _baseUrl = await _getServerConfig().then(
      (config) => config.middlewareUrl.toString(),
    );

    return _$MiddlewareService(
      ChopperClient(
        baseUrl: _baseUrl,
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(),
          UnauthorizedResponseInterceptor(),
        ],
      ),
    );
  }

  @Post(path: 'android-device/')
  Future<Response> postAndroidDevice({
    @Field() required String name,
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field('os_version') required String osVersion,
    @Field('client_version') required String clientVersion,
    @Field() required String app,
    @Field('app_startup_timestamp') String? appStartupTime,
  });

  @Delete(path: 'android-device/')
  Future<Response> deleteAndroidDevice({
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field() required String app,
  });

  @Post(path: 'apns-device/')
  Future<Response> postAppleDevice({
    @Field() required String name,
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field('os_version') required String osVersion,
    @Field('client_version') required String clientVersion,
    @Field() required String app,
    @Field('app_startup_timestamp') String? appStartupTime,
    @Field('push_profile') String pushProfile = 'once',
    @Field() required bool sandbox,
    @Field('remote_notification_token') required String remoteNotificationToken,
  });

  @Delete(path: 'apns-device/')
  Future<Response> deleteAppleDevice({
    @Field() required String token,
    @Field('sip_user_id') required String sipUserId,
    @Field() required String app,
  });

  @Post(path: 'call-response/')
  Future<Response> callResponse({
    @Field('unique_key') required String uniqueKey,
    @Field() required String available,
    @Field('message_start_time') required String messageStartTime,
    @Field('sip_user_id') required String sipUserId,
  });
}
