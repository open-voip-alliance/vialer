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
          const AuthorizationInterceptor(
            onlyModernAuth: true,
          ),
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

  @Get(path: '{clientUuid}/temporary-redirect')
  Future<Response> getTemporaryRedirect({
    @Path() required String clientUuid,
  });

  @Post(path: '{clientUuid}/temporary-redirect')
  Future<Response> setTemporaryRedirect(
    @Path() String clientUuid,
    @Body() Map<String, dynamic> body,
  );

  @Put(path: '{clientUuid}/temporary-redirect/{temporaryRedirectId}')
  Future<Response> updateTemporaryRedirect(
    @Path() String clientUuid,
    @Path() String temporaryRedirectId,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '{clientUuid}/temporary-redirect/{temporaryRedirectId}')
  Future<Response> deleteTemporaryRedirect(
    @Path() String clientUuid,
    @Path() String temporaryRedirectId,
  );
}
