import 'dart:async';

import 'package:chopper/chopper.dart' hide JsonConverter;
import 'util.dart';

part 'voipgrid.chopper.dart';

@ChopperApi(baseUrl: '/api/')
abstract class VoipgridService extends ChopperService {
  static VoipgridService create() {
    return _$VoipgridService(
      ChopperClient(
        baseUrl: 'https://partner.voipgrid.nl',
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(
            forcedLegacyAuthPaths: [
              'v2/password',
            ],
          ),
        ],
      ),
    );
  }

  @Post(path: 'permission/apitoken/')
  Future<Response> getToken(@Body() Map<String, dynamic> body);

  @Get(path: 'permission/systemuser/profile/')
  Future<Response> getSystemUser({
    @Header('Authorization') String? authorization,
  });

  @Get(path: 'cdr/record/personalized/')
  Future<Response> getPersonalCalls({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @Query('call_date__gt') required String from,
    @Query('call_date__lt') required String to,
  });

  @Get(path: 'v2/callthrough')
  Future<Response> callthrough({
    @Query('destination') required String destination,
  });

  @Put(path: 'v2/password')
  Future<Response> password(@Body() Map<String, dynamic> body);

  @Get(path: 'autologin/token/')
  Future<Response> getAutoLoginToken();

  @Get(path: 'userdestination/')
  Future<Response> getAvailability();

  @Put(path: 'selecteduserdestination/{id}/')
  Future<Response> setAvailability(
    @Path() String id,
    @Body() Map<String, dynamic> body,
  );

  @Get(path: 'phoneaccount/basic/phoneaccount/{id}/')
  Future<Response> getPhoneAccount(@Path() String id);

  @Get(path: 'mobile/profile/')
  Future<Response> getMobileProfile();
}
