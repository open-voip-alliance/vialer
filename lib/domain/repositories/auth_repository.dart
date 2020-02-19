abstract class AuthRepository {
  Future<bool> authenticate(String email, String password);

  Future<bool> isAuthenticated();
}
