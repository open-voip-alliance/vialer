import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../../../../domain/usecases/user/get_brand.dart';
import '../../util.dart';

part 'shared_contacts_service.chopper.dart';

@ChopperApi()
@singleton
abstract class SharedContactsService extends ChopperService {
  @factoryMethod
  static SharedContactsService create() {
    final getBrand = GetBrand();
    final sharedContactsBaseUrl = getBrand().sharedContactsUrl.toString();

    return _$SharedContactsService(
      ChopperClient(
        baseUrl: Uri.parse(sharedContactsBaseUrl),
        converter: JsonConverter(),
        interceptors: [
          AuthorizationInterceptor(onlyModernAuth: true),
          ...globalInterceptors,
        ],
      ),
    );
  }

  @Get(path: 'clients/{clientId}/contacts')
  Future<Response<Map<String, dynamic>>> getSharedContacts(
    @Path() String clientId, {
    @Query() int page = 1,
    @Query('per_page') int perPage = 500,
  });

  @Post(path: 'clients/{clientId}/contacts')
  Future<Response<Map<String, dynamic>>> createSharedContact(
    @Path() String clientId,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: 'clients/{clientId}/contacts/{sharedContactUuid}')
  Future<Response<Map<String, dynamic>>> deleteSharedContact(
    @Path() String clientId,
    @Path() String sharedContactUuid,
  );

  @Put(path: 'clients/{clientId}/contacts/{sharedContactUuid}')
  Future<Response<Map<String, dynamic>>> updateSharedContact(
    @Path() String clientId,
    @Path() String sharedContactUuid,
    @Body() Map<String, dynamic> body,
  );
}
