import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/user/get_brand.dart';
import '../util.dart';

part 'phone_number_service.chopper.dart';

@ChopperApi()
@singleton
abstract class PhoneNumberService extends ChopperService {
  @factoryMethod
  static PhoneNumberService create() => createFromUri(
        Uri.parse(GetBrand()().phoneNumberValidationUrl.toString()),
      );

  static PhoneNumberService createFromUri(Uri uri) => _$PhoneNumberService(
        // This end-point does not require authentication.
        ChopperClient(
          baseUrl: uri,
          converter: JsonConverter(),
        ),
      );

  @Get(path: 'validate/{number}/')
  Future<Response<Map<String, dynamic>>> validate(
    @Path('number') String number,
  );
}
