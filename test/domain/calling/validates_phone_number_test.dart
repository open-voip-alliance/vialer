import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/domain/calling/validates_phone_number.dart';

void main() {
  expectsNumberToBeValid(
    'Accepts a valid Dutch mobile number',
    '+31640112000',
  );

  expectsNumberToBeValid(
    'Accepts a valid Belgian mobile number',
    '+32640112000',
  );

  expectsNumberToBeValid(
    'Accepts a valid German mobile number',
    '+49640112000',
  );

  expectsNumberToBeValid(
    'Accepts a valid French mobile number',
    '+33640112000',
  );

  expectsNumberToBeValid(
    'Accepts a valid UK mobile number',
    '+447700900077',
  );

  expectsNumberToBeInvalid(
    'Does not accept mobile number without country code',
    '0640112000',
  );

  expectsNumberToBeInvalid(
    'Does not accept short number',
    '123',
  );
}

void expectsNumberToBeValid(String description, String number) {
  test(description, () async {
    expect(await ValidatesPhoneNumber()(number), true);
  });
}

void expectsNumberToBeInvalid(String description, String number) {
  test(description, () async {
    expect(await ValidatesPhoneNumber()(number), false);
  });
}
