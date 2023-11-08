import 'package:vialer/domain/phone_numbers/phone_number_repository.dart';
import 'package:vialer/domain/phone_numbers/validate_phone_number.dart';
import 'package:vialer/domain/use_case.dart';

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
