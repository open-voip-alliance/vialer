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
          AuthorizationInterceptor(onlyModernAuth: false),
          ...globalInterceptors,
          HeadersInterceptor({'application': 'app'}),
        ],
      ),
    );
  }

  @Get()
  Future<Response<List<Map<String, dynamic>>>> getSharedContacts({
    @Query() int page = 1,
    @Query('per_page') int perPage = 500,
  });

  @Post()
  Future<Response<Map<String, dynamic>>> createSharedContact(
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '{sharedContactUuid}')
  Future<Response<Map<String, dynamic>>> deleteSharedContact(
    @Path() String sharedContactUuid,
  );

  @Put(path: '{sharedContactUuid}')
  Future<Response<Map<String, dynamic>>> updateSharedContact(
    @Path() String sharedContactUuid,
    @Body() Map<String, dynamic> body,
  );
}
