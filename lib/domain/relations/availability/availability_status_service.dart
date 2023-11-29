import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../../user/get_brand.dart';
import '../../util.dart';

part 'availability_status_service.chopper.dart';

@ChopperApi()
@singleton
abstract class UserAvailabilityService extends ChopperService {
  @factoryMethod
  static UserAvailabilityService create() {
    final brand = GetBrand()();

    return _$UserAvailabilityService(
      ChopperClient(
        baseUrl: brand.availabilityServiceUrl,
        converter: JsonConverter(),
        interceptors: <RequestInterceptor>[
          const AuthorizationInterceptor(onlyModernAuth: true),
        ],
      ),
    );
  }

  @Get(path: 'clients/{clientUuid}/users/{userUuid}/status')
  Future<Response<Map<String, dynamic>>> getAvailabilityStatus({
    @Path() required String clientUuid,
    @Path() required String userUuid,
  });

  @Post(path: 'clients/{clientUuid}/users/{userUuid}/status')
  Future<Response<Map<String, dynamic>>> changeAvailabilityStatus(
    @Body() Map<String, dynamic> body, {
    @Path() required String clientUuid,
    @Path() required String userUuid,
  });
}
