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

  @Get(path: 'v2/call/personalized/')
  Future<Response> getPersonalCalls({
    @Query('answered') bool? answered,
    @Query('timezone') String? timezone,
    @Query('from.type') String? fromType,
    @Query('to.type') String? toType,
    @Query('page') int pageNumber = 1,
    @Query('per_page') int perPage = 50,
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

  @Put(path: 'permission/mobile_number/')
  Future<Response> changeMobileNumber(@Body() Map<String, dynamic> body);
}
