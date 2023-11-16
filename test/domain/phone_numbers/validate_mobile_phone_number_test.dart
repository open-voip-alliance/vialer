import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vialer/domain/phone_numbers/phone_number_repository.dart';
import 'package:vialer/domain/phone_numbers/phone_number_service.dart';
import 'package:vialer/domain/phone_numbers/validate_mobile_phone_number.dart';

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

  expectsNumberToBeValid(
    'Accepts a valid Belgian mobile number',
    '+32456194246',
  );

  expectsNumberToBeValid(
    'Accepts a valid German mobile number',
    '+4915134876966',
  );

  expectsNumberToBeValid(
    'Accepts a valid French mobile number',
    '+33640112000',
  );

  expectsNumberToBeValid(
    'Accepts a valid UK mobile number',
    '+447401123123',
  );

  expectsNumberToBeInvalid(
    'Does not accept short number',
    '123',
  );
}

void expectsNumberToBeValid(String description, String number) {
  test(description, () async {
    expect(await ValidateMobilePhoneNumber()(number), true);
  });
}

void expectsNumberToBeInvalid(String description, String number) {
  test(description, () async {
    expect(await ValidateMobilePhoneNumber()(number), false);
  });
}
