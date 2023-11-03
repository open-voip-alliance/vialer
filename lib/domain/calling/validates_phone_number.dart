import 'package:vialer/domain/use_case.dart';

class ValidatesPhoneNumber extends UseCase {
  Future<bool> call(String number) async =>
      number.startsWith('+') &&
      !number.startsWith('+0') &&
      number.length >= 12 &&
      number.length <= 13;
}
