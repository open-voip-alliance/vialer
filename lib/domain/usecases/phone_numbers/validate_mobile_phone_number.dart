import 'package:vialer/domain/usecases/phone_numbers/validate_phone_number.dart';
import 'package:vialer/domain/usecases/use_case.dart';

import '../../../data/repositories/phone_numbers/phone_number_repository.dart';

class ValidateMobilePhoneNumber extends UseCase {
  Future<bool> call(
    String number, {
    bool strict = false,
  }) =>
      ValidatePhoneNumber()(
        number,
        validTypes: [PhoneNumberType.mobile],
        strict: strict,
      );
}
