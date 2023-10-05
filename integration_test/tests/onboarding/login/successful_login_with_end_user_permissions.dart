import '../../../util.dart';
import 'successful_login.dart';

Future<void> main() => performLoginTestWith(
      username: () => testUserWithEndUserPermissions.email,
      password: () => testUserWithEndUserPermissions.password,
    );
