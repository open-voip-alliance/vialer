import '../../../data/repositories/phone_numbers/phone_number_repository.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class DescribePhoneNumber extends UseCase {
  late final _phoneNumbers = dependencyLocator<PhoneNumberRepository>();

  Future<ValidationResult> call(String number) =>
      _phoneNumbers.validate(number);
}
