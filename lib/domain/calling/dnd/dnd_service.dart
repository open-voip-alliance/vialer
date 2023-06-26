import 'package:chopper/chopper.dart' hide JsonConverter;

import '../../user/get_brand.dart';
import '../../util.dart';

part 'dnd_service.chopper.dart';

@ChopperApi()
abstract class DndService extends ChopperService {
  static DndService create() {
    final getBrand = GetBrand();
    final dndUrl = getBrand().dndServiceUrl.toString();

    return _$DndService(
      ChopperClient(
        baseUrl: Uri.parse(dndUrl),
        converter: JsonConverter(),
        interceptors: <RequestInterceptor>[
          const AuthorizationInterceptor(onlyModernAuth: true),
        ],
      ),
    );
  }

  @Get(path: 'clients/{clientUuid}/users/{userUuid}')
  Future<Response<Map<String, dynamic>>> getDndStatus({
    @Path() required String clientUuid,
    @Path() required String userUuid,
  });

  @Post(path: 'clients/{clientUuid}/users/{userUuid}')
  Future<Response<Map<String, dynamic>>> changeDndStatus(
    @Body() Map<String, dynamic> body, {
    @Path() required String clientUuid,
    @Path() required String userUuid,
  });
}
