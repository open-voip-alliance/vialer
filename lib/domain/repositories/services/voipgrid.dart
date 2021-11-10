import 'dart:async';

import 'package:chopper/chopper.dart' hide JsonConverter;

import '../../usecases/get_voipgrid_base_url.dart';
import 'util.dart';

part 'voipgrid.chopper.dart';

@ChopperApi(baseUrl: '/api/')
abstract class VoipgridService extends ChopperService {
  static VoipgridService create() {
    final _getVoipgridBaseUrl = GetVoipgridBaseUrlUseCase();

    return _$VoipgridService(
      ChopperClient(
        baseUrl: _getVoipgridBaseUrl(),
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(
            forcedLegacyAuthPaths: [
              'v2/password',
            ],
          ),
          UnauthorizedResponseInterceptor(),
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
    @Query('per_page') int perPage = 20,
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

  @Put(path: 'mobile/profile/')
  Future<Response> updateMobileProfile(@Body() Map<String, dynamic> body);

  @Put(path: 'permission/mobile_number/')
  Future<Response> changeMobileNumber(@Body() Map<String, dynamic> body);
}
