import 'dart:async';

import 'package:meta/meta.dart';
import 'package:chopper/chopper.dart' hide JsonConverter;

import 'util.dart';

part 'middleware.chopper.dart';

@ChopperApi(baseUrl: '/api/')
abstract class MiddlewareService extends ChopperService {
  static MiddlewareService create() {
    return _$MiddlewareService(
      ChopperClient(
        baseUrl: 'https://vialerpush.voipgrid.nl',
        converter: JsonConverter(),
        interceptors: [const AuthorizationInterceptor()],
      ),
    );
  }

  @Post(path: 'android-device/')
  Future<Response> postAndroidDevice({
    @required @Field() String name,
    @required @Field() String token,
    @required @Field('sip_user_id') String sipUserId,
    @required @Field('os_version') String osVersion,
    @required @Field('client_version') String clientVersion,
    @required @Field() String app,
  });

  @Delete(path: 'android-device/')
  Future<Response> deleteAndroidDevice({
    @required @Field() String token,
    @required @Field('sip_user_id') String sipUserId,
    @required @Field() String app,
  });

  @Post(path: 'call-response/')
  Future<Response> callResponse({
    @required @Field('unique_key') String uniqueKey,
    @required @Field() String available,
    @required @Field('message_start_time') String messageStartTime,
    @required @Field('sip_user_id') String sipUserId,
  });
}
