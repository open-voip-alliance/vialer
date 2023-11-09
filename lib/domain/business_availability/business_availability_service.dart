import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../user/get_brand.dart';
import '../user/user.dart';
import '../util.dart';

part 'business_availability_service.chopper.dart';

@ChopperApi()
@singleton
abstract class BusinessAvailabilityService extends ChopperService {
  @factoryMethod
  static BusinessAvailabilityService create() {
    final brand = GetBrand()();
    final businessAvailabilityBaseUrl =
        brand.businessAvailabilityUrl.toString();

    return _$BusinessAvailabilityService(
      ChopperClient(
        baseUrl: Uri.parse(businessAvailabilityBaseUrl),
        converter: JsonConverter(),
        interceptors: const <RequestInterceptor>[
          AuthorizationInterceptor(
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
        baseUrl: Uri.parse(baseUrl),
        converter: JsonConverter(),
        interceptors: <RequestInterceptor>[
          AuthorizationInterceptor(user: user),
        ],
      ),
    );
  }

  @Get(path: '{clientUuid}/temporary-redirect')
  Future<Response<Map<String, dynamic>>> getTemporaryRedirect({
    @Path() required String clientUuid,
  });

  @Post(path: '{clientUuid}/temporary-redirect')
  Future<Response<Map<String, dynamic>>> setTemporaryRedirect(
    @Path() String clientUuid,
    @Body() Map<String, dynamic> body,
  );

  @Put(path: '{clientUuid}/temporary-redirect/{temporaryRedirectId}')
  Future<Response<Map<String, dynamic>>> updateTemporaryRedirect(
    @Path() String clientUuid,
    @Path() String temporaryRedirectId,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '{clientUuid}/temporary-redirect/{temporaryRedirectId}')
  Future<Response<Map<String, dynamic>>> deleteTemporaryRedirect(
    @Path() String clientUuid,
    @Path() String temporaryRedirectId,
  );
}
