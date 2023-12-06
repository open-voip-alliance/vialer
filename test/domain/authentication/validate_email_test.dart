import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/domain/authentication/validate_email.dart';

void main() {
  final _validateEmail = ValidateEmail();

  group('hasValidEmailFormat', () {
    test('returns true for valid email format', () async {
      final email = 'test@example.com';
      final result = await _validateEmail(email);
      expect(result, true);
    });

    test('returns false for email without local part', () async {
      final email = '@example.com';
      final result = await _validateEmail(email);
      expect(result, false);
    });

    test('returns false for email without domain part', () async {
      final email = 'test@';
      final result = await _validateEmail(email);
      expect(result, false);
    });

    test('returns false for email without top-level domain part', () async {
      final email = 'test@example';
      final result = await _validateEmail(email);
      expect(result, false);
    });

    test('returns false for email with invalid characters', () async {
      final email = 'test@example!com';
      final result = await _validateEmail(email);
      expect(result, false);
    });
  });
}
