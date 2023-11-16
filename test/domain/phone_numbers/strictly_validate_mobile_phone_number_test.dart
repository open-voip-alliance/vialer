
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vialer/domain/phone_numbers/phone_number_repository.dart';
import 'package:vialer/domain/phone_numbers/phone_number_service.dart';
import 'package:vialer/domain/phone_numbers/strictly_validate_mobile_phone_number.dart';

void main() {
  GetIt.instance
    ..registerSingleton(
      PhoneNumberRepository(
        PhoneNumberService.createFromUri(
          Uri.parse('https://phonenumbers.spindle.dev'),
        ),
      ),
    )
    ..allReady();

  expectsNumberToBeValid(
    'Accepts a valid Dutch mobile number',
    '+31640112000',
  );

  expectsNumberToBeInvalid(
    'Does not accept a mobile number with leading 0',
    '+310640112000',
  );

  expectsNumberToBeInvalid(
    'Does not accept numbers with spaces',
    '+31 6401 1200 0',
  );
}

void expectsNumberToBeValid(String description, String number) {
  test(description, () async {
    expect(await StrictlyValidateMobilePhoneNumber()(number), true);
  });
}

void expectsNumberToBeInvalid(String description, String number) {
  test(description, () async {
    expect(await StrictlyValidateMobilePhoneNumber()(number), false);
  });
}

