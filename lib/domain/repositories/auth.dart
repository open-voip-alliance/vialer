import '../entities/system_user.dart';

abstract class AuthRepository {
  Future<bool> authenticate(String email, String password);

  Future<bool> isAuthenticated();

  SystemUser get currentUser;
}
