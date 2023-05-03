import '../../../util.dart';
import 'successful_login.dart';

Future<void> main() => performLoginTestWith(
      username: () => testUserWithoutAppAccount.email,
      password: () => testUserWithoutAppAccount.password,
    );
