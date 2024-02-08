import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/usecases/use_case.dart';

import '../../../data/repositories/phone_numbers/phone_number_repository.dart';

/// Validate a phone number.
///
/// Provide [validTypes] to make sure the phone number is (for example) a
/// mobile number.
///
/// Set [strict] to TRUE to require that the input matches the flat validated
/// number. This will mean that the user must enter the number in an accepted
/// format, we won't assume it will be reformatted for them.
class ValidatePhoneNumber extends UseCase {
  late final _phoneNumbers = dependencyLocator<PhoneNumberRepository>();

  Future<bool> call(
    String number, {
    Iterable<PhoneNumberType> validTypes = const [],
    bool strict = false,
  }) async {
    final result = await _phoneNumbers.validate(number);

    if (result is! ValidPhoneNumberResult) return false;

    if (validTypes.isEmpty) return true;

    final isValid = validTypes.contains(result.type);

    if (!strict) return isValid;

    return _performStrictValidation(number, result);
  }

  bool _performStrictValidation(String number, ValidPhoneNumberResult result) =>
      [
        result.flat == number,
        result.pretty == number,
      ].any((result) => result);
}
