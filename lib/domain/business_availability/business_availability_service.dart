import 'package:chopper/chopper.dart' hide JsonConverter;

import '../user/get_brand.dart';
import '../user/user.dart';
import '../util.dart';

part 'business_availability_service.chopper.dart';

@ChopperApi()
abstract class BusinessAvailabilityService extends ChopperService {
  static BusinessAvailabilityService create() {
    final _getBrand = GetBrand();
    final _businessAvailabilityBaseUrl =
        _getBrand.call().businessAvailabilityUrl.toString();

    return _$BusinessAvailabilityService(
      ChopperClient(
        baseUrl: _businessAvailabilityBaseUrl,
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(),
          UnauthorizedResponseInterceptor(),
        ],
      ),
    );
  }

  static BusinessAvailabilityService createInIsolate({
    required User user,
    required String baseUrl,
  }) {
    return _$BusinessAvailabilityService(
      ChopperClient(
        baseUrl: baseUrl,
        converter: JsonConverter(),
        interceptors: [
          AuthorizationInterceptor(user: user),
        ],
      ),
    );
  }

  @Get(path: '{client_uuid}/temporary-redirect')
  Future<Response> getTemporaryRedirect({
    @Path() String clientUuid,
  });

  @Post(path: '{client_uuid}/temporary-redirect')
  Future<Response> setTemporaryRedirect(
    @Path() String clientUuid,
    @Body() Map<String, dynamic> body,
  );

  @Put(path: '{client_uuid}/temporary-redirect/{temporary_redirect_id}')
  Future<Response> updateTemporaryRedirect(
    @Path() String clientUuid,
    @Path() String temporaryRedirectId,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '{client_uuid}/temporary-redirect/{temporary_redirect_id}')
  Future<Response> deleteTemporaryRedirect(
    @Path() String clientUuid,
    @Path() String temporaryRedirectId,
  );
}
