import 'package:vialer/domain/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class ValidatePassword extends UseCase {
  /// Validate if the password is valid according the VG format:
  /// at least 6 characters and 1 non-alphabetical character.
  Future<bool> call(String password) async =>
      password.length >= 6 && RegExp('[^A-z]+').hasMatch(password);
}
