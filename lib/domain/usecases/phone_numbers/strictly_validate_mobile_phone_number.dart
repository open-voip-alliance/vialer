import 'package:vialer/domain/usecases/phone_numbers/validate_mobile_phone_number.dart';
import 'package:vialer/domain/usecases/use_case.dart';

/// Validates a mobile phone number ensuring a valid format is provided. See
/// more information in [ValidatePhoneNumber].
class StrictlyValidateMobilePhoneNumber extends UseCase {
  Future<bool> call(String number) => ValidateMobilePhoneNumber()(
        number,
        strict: true,
      );
}
