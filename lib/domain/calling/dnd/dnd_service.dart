import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../../user/get_brand.dart';
import '../../util.dart';

part 'dnd_service.chopper.dart';

@ChopperApi()
@singleton
abstract class DndService extends ChopperService {
  @factoryMethod
  static DndService create() {
    final brand = GetBrand()();
    final dndUrl = brand.dndServiceUrl.toString();

    return _$DndService(
      ChopperClient(
        baseUrl: Uri.parse(dndUrl),
        converter: JsonConverter(),
        interceptors: [
          const AuthorizationInterceptor(onlyModernAuth: true),
          ...globalInterceptors,
        ],
      ),
    );
  }

  @Get(path: 'clients/{clientUuid}/users/{userUuid}/status')
  Future<Response<Map<String, dynamic>>> getDndStatus({
    @Path() required String clientUuid,
    @Path() required String userUuid,
  });

  @Post(path: 'clients/{clientUuid}/users/{userUuid}/status')
  Future<Response<Map<String, dynamic>>> changeDndStatus(
    @Body() Map<String, dynamic> body, {
    @Path() required String clientUuid,
    @Path() required String userUuid,
  });
}
