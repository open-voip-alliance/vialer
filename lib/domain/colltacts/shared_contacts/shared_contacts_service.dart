import 'package:chopper/chopper.dart' hide JsonConverter;

import '../../user/get_brand.dart';
import '../../user/user.dart';
import '../../util.dart';

part 'shared_contacts_service.chopper.dart';

@ChopperApi()
abstract class SharedContactsService extends ChopperService {
  static SharedContactsService create() {
    final getBrand = GetBrand();
    final sharedContactsBaseUrl = getBrand().sharedContactsUrl.toString();

    return _$SharedContactsService(
      ChopperClient(
        baseUrl: Uri.parse(sharedContactsBaseUrl),
        converter: JsonConverter(),
        interceptors: const <RequestInterceptor>[
          AuthorizationInterceptor(
            onlyModernAuth: false,
          ),
        ],
      ),
    );
  }

  static SharedContactsService createInIsolate({
    required User user,
    required String baseUrl,
  }) {
    return _$SharedContactsService(
      ChopperClient(
        baseUrl: Uri.parse(baseUrl),
        converter: JsonConverter(),
        interceptors: <RequestInterceptor>[
          AuthorizationInterceptor(user: user),
        ],
      ),
    );
  }

  @Get(path: '')
  Future<Response<List<Map<String, dynamic>>>> getSharedContacts({
    @Header('Authorization') String? authorization,
    @Query() int page = 1,
    @Query('per_page') int perPage = 500,
  });
}
