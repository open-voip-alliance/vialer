import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/phone_numbers/phone_number_repository.dart';
import 'package:vialer/domain/use_case.dart';

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

    return strict ? result.flat == number : isValid;
  }
}
