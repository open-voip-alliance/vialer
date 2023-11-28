import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/domain/authentication/validate_account.dart';

void main() {
  group('Account Validation', () {
    group('hasValidPasswordFormat', () {
      test('returns true for valid password format', () async {
        final password = 'Abc123!';
        final result = await ValidateAccount.hasValidPasswordFormat(password);
        expect(result, true);
      });

      test('returns false for password with less than 6 characters', () async {
        final password = 'Abc12';
        final result = await ValidateAccount.hasValidPasswordFormat(password);
        expect(result, false);
      });

      test('returns false for password without non-alphabetical character',
          () async {
        final password = 'Abcdefg';
        final result = await ValidateAccount.hasValidPasswordFormat(password);
        expect(result, false);
      });
    });

    group('hasValidEmailFormat', () {
      test('returns true for valid email format', () async {
        final email = 'test@example.com';
        final result = await ValidateAccount.hasValidEmailFormat(email);
        expect(result, true);
      });

      test('returns false for email without local part', () async {
        final email = '@example.com';
        final result = await ValidateAccount.hasValidEmailFormat(email);
        expect(result, false);
      });

      test('returns false for email without domain part', () async {
        final email = 'test@';
        final result = await ValidateAccount.hasValidEmailFormat(email);
        expect(result, false);
      });

      test('returns false for email without top-level domain part', () async {
        final email = 'test@example';
        final result = await ValidateAccount.hasValidEmailFormat(email);
        expect(result, false);
      });

      test('returns false for email with invalid characters', () async {
        final email = 'test@example!com';
        final result = await ValidateAccount.hasValidEmailFormat(email);
        expect(result, false);
      });
    });
  });
}
