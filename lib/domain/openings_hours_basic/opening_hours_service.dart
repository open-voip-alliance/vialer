import 'package:chopper/chopper.dart' hide JsonConverter;

import '../user/get_brand.dart';
import '../util.dart';

part 'opening_hours_service.chopper.dart';

@ChopperApi()
abstract class OpeningHoursService extends ChopperService {
  static OpeningHoursService create() {
    final brand = GetBrand()();
    final openingHoursBasicUrl = brand.openingHoursBasicUrl.toString();

    return _$OpeningHoursService(
      ChopperClient(
        baseUrl: Uri.parse(openingHoursBasicUrl),
        converter: JsonConverter(),
        interceptors: <RequestInterceptor>[
          const AuthorizationInterceptor(
            onlyModernAuth: true,
          ),
        ],
      ),
    );
  }

  @Get(path: '{clientUuid}/openinghours')
  Future<Response<Map<String, dynamic>>> getOpeningHoursModules({
    @Path() required String clientUuid,
  });
}
