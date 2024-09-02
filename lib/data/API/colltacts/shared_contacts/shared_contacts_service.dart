import 'dart:async';

import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';

import '../../../../domain/usecases/user/get_brand.dart';
import '../../util.dart';

part 'shared_contacts_service.chopper.dart';

@ChopperApi()
@singleton
abstract class SharedContactsService extends ChopperService {
  @factoryMethod
  static SharedContactsService create() {
    final baseUrl = GetBrand()().sharedContactsUrl;
    final placeholder = _AddClientIdToRequestPath.placeholder;

    return _$SharedContactsService(
      ChopperClient(
        baseUrl: Uri.parse('${baseUrl}/clients/$placeholder/contacts'),
        converter: JsonConverter(),
        interceptors: [
          AuthorizationInterceptor(onlyModernAuth: true),
          ...globalInterceptors,
          _AddClientIdToRequestPath(),
          PreventAppendingTrailingSlashInterceptor(),
        ],
      ),
    );
  }

  @Get()
  Future<Response<Map<String, dynamic>>> getSharedContacts({
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

/// Add a client id to a request path, use the [placeholder] when creating
/// the service's base url.
class _AddClientIdToRequestPath implements RequestInterceptor {
  static const placeholder = 'client-uuid-placeholder';

  @override
  FutureOr<Request> onRequest(Request request) => request.copyWith(
        uri: Uri.parse(
          request.url.toString().replaceFirst(
                placeholder,
                GetLoggedInUserUseCase()().client.uuid,
              ),
        ),
      );
}
