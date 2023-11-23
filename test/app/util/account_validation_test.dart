import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/app/util/account_validation.dart';

void main() {
  group('Account Validation', () {
    group('hasValidPasswordFormat', () {
      test('returns true for valid password format', () {
        final password = 'Abc123!';
        final result = hasValidPasswordFormat(password);
        expect(result, true);
      });

      test('returns false for password with less than 6 characters', () {
        final password = 'Abc12';
        final result = hasValidPasswordFormat(password);
        expect(result, false);
      });

      test('returns false for password without non-alphabetical character', () {
        final password = 'Abcdefg';
        final result = hasValidPasswordFormat(password);
        expect(result, false);
      });
    });

    group('hasValidEmailFormat', () {
      test('returns true for valid email format', () {
        final email = 'test@example.com';
        final result = hasValidEmailFormat(email);
        expect(result, true);
      });

      test('returns false for email without local part', () {
        final email = '@example.com';
        final result = hasValidEmailFormat(email);
        expect(result, false);
      });

      test('returns false for email without domain part', () {
        final email = 'test@';
        final result = hasValidEmailFormat(email);
        expect(result, false);
      });

      test('returns false for email without top-level domain part', () {
        final email = 'test@example';
        final result = hasValidEmailFormat(email);
        expect(result, false);
      });

      test('returns false for email with invalid characters', () {
        final email = 'test@example!com';
        final result = hasValidEmailFormat(email);
        expect(result, false);
      });
    });
  });
}
