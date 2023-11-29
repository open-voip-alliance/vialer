import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../user/get_brand.dart';
import '../util.dart';

part 'opening_hours_service.chopper.dart';

@ChopperApi()
@injectable
abstract class OpeningHoursService extends ChopperService {
  @factoryMethod
  static OpeningHoursService create() {
    final brand = GetBrand()();
    final openingHoursBasicUrl = brand.openingHoursBasicUrl.toString();

    return _$OpeningHoursService(
      ChopperClient(
        baseUrl: Uri.parse(openingHoursBasicUrl),
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(onlyModernAuth: true),
          ...globalInterceptors,
        ],
      ),
    );
  }

  @Get(path: '{clientUuid}/openinghours')
  Future<Response<Map<String, dynamic>>> getOpeningHoursModules({
    @Path() required String clientUuid,
  });
}
