import 'package:chopper/chopper.dart';

part 'voipgrid_service.chopper.dart';

@ChopperApi()
abstract class VoipGridService extends ChopperService {
  static VoipGridService create([ChopperClient client]) =>
      _$VoipGridService(client);

  @Post(path: 'api/permission/apitoken/')
  Future<Response> getToken(@Body() Map<String, dynamic> body);

  @Get(path: 'api/permission/systemuser/profile/')
  Future<Response> getSystemUser();
}
