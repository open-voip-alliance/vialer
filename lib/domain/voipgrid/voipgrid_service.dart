import 'dart:async';

import 'package:chopper/chopper.dart' hide JsonConverter;

import '../user/user.dart';
import '../util.dart';
import 'get_voipgrid_base_url.dart';

part 'voipgrid_service.chopper.dart';

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

  static VoipgridService createInIsolate({
    required User user,
    required String baseUrl,
  }) {
    return _$VoipgridService(
      ChopperClient(
        baseUrl: baseUrl,
        converter: JsonConverter(),
        interceptors: [
          AuthorizationInterceptor(user: user),
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

  @Get(path: 'v2/vialer/middlewares/')
  Future<Response> getMiddleware();

  @Get(path: 'cdr/record/')
  Future<Response> getClientCalls({
    @Query('limit') int limit = 20,
    @Query('offset') int offset = 0,
    @Query('call_date__gt') String? from,
    @Query('call_date__lt') String? to,
  });

  @Get(path: 'v2/clients/{clientId}/users/{userId}')
  Future<Response> getUserSettings({
    @Path() required String clientId,
    @Path() required String userId,
  });

  @Patch(path: 'v2/clients/{clientId}/users/{userId}')
  Future<Response> updateUserSettings({
    @Path() required String clientId,
    @Path() required String userId,
    @Body() required Map<String, dynamic> body,
  });

  @Get(path: 'v2/clients/{clientUuid}/callerid_numbers')
  Future<Response> getClientBusinessNumbers({
    @Path() required String clientUuid,
    @Query('page') int page = 1,
    @Query('per_page') int perPage = 500,
  });

  @Patch(path: 'v2/clients/{clientId}/voip_accounts/{voipAccountId}')
  Future<Response> updateVoipAccount(
    @Path() String clientId,
    @Path() String voipAccountId,
    @Body() Map<String, dynamic> data,
  );

  @Get(path: 'v2/clients/{clientId}/voicemails')
  Future<Response> getVoicemailAccounts(
    @Path() String clientId, {
    @Query() int page = 1,
    @Query('per_page') int perPage = 500,
  });

  @Get(path: 'v2/users/auth-context')
  Future<Response> getVoipgridPermissions();

  @Get(path: 'v2/clients/{clientId}/users')
  Future<Response> getUsers(
    @Path() String clientId, {
    @Query() int page = 1,
    @Query('per_page') int perPage = 500,
  });

  @Get(
    path:
        'v2/clients/{clientId}/voip_accounts?filter_accounts=without_connected_users',
  )
  Future<Response> getUnconnectedVoipAccounts(
    @Path() String clientId, {
    @Query() int page = 1,
    @Query('per_page') int perPage = 500,
  });
}
