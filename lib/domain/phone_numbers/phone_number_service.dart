import 'package:chopper/chopper.dart' hide JsonConverter;
import 'package:injectable/injectable.dart';

import '../user/get_brand.dart';
import '../util.dart';

part 'phone_number_service.chopper.dart';

@ChopperApi()
@singleton
abstract class PhoneNumberService extends ChopperService {
  @factoryMethod
  static PhoneNumberService create({Uri? uri}) => _$PhoneNumberService(
        // This end-point does not require authentication.
        ChopperClient(
          baseUrl: uri ??
              Uri.parse(GetBrand()().phoneNumberValidationUrl.toString()),
          converter: JsonConverter(),
        ),
      );

  @Get(path: 'validate/{number}/')
  Future<Response<Map<String, dynamic>>> validate(
    @Path('number') String number,
  );
}
