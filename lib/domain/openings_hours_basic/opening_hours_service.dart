import 'package:chopper/chopper.dart' hide JsonConverter;

import '../user/get_brand.dart';
import '../util.dart';

part 'opening_hours_service.chopper.dart';

@ChopperApi()
abstract class OpeningHoursService extends ChopperService {
  static OpeningHoursService create() {
    final _getBrand = GetBrand();
    final _openingHoursBasicUrl = _getBrand().openingHoursBasicUrl.toString();

    return _$OpeningHoursService(
      ChopperClient(
        baseUrl: _openingHoursBasicUrl,
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(
            onlyModernAuth: true,
          ),
        ],
      ),
    );
  }

  @Get(path: '{clientUuid}/openinghours')
  Future<Response> getOpeningHoursModules({
    @Path() required String clientUuid,
  });
}
