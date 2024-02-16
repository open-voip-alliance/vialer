import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/domain/usecases/authentication/validate_password.dart';

void main() {
  final _validatePassword = ValidatePassword();

  group('hasValidPasswordFormat', () {
    test('returns true for valid password format', () async {
      final password = 'Abc123!';
      final result = await _validatePassword(password);
      expect(result, true);
    });

    test('returns false for password with less than 6 characters', () async {
      final password = 'Abc12';
      final result = await _validatePassword(password);
      expect(result, false);
    });

    test('returns false for password without non-alphabetical character',
        () async {
      final password = 'Abcdefg';
      final result = await _validatePassword(password);
      expect(result, false);
    });
  });
}
