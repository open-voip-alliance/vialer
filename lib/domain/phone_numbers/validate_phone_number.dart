import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/phone_numbers/phone_number_repository.dart';
import 'package:vialer/domain/use_case.dart';

/// Validate a phone number.
///
/// Provide [validTypes] to make sure the phone number is (for example) a
/// mobile number.
class ValidatePhoneNumber extends UseCase {
  late final _phoneNumbers = dependencyLocator<PhoneNumberRepository>();

  Future<bool> call(
    String number, [
    Iterable<PhoneNumberType> validTypes = const [],
  ]) async {
    final result = await _phoneNumbers.validate(number);

    if (result is! ValidPhoneNumberResult) return false;

    if (validTypes.isEmpty) return true;

    return validTypes.contains(result.type);
  }
}
