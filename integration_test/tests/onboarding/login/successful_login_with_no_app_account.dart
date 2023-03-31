import '../../../util.dart';
import 'successful_login.dart';

void main() => performLoginTestWith(
  username: () => testUserWithoutAppAccount.email,
  password: () => testUserWithoutAppAccount.password,
);