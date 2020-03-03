import '../../domain/repositories/auth.dart';

import 'services/voipgrid.dart';
import '../utils/storage.dart';
import '../../domain/entities/system_user.dart';

class DataAuthRepository extends AuthRepository {
  var _service = VoipGridService.create();

  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _apiTokenKey = 'api_token';

  SystemUser _currentUser;

  @override
  Future<bool> authenticate(String email, String password) async {
    final tokenResponse = await _service.getToken({
      _emailKey: email,
      _passwordKey: password,
    });

    final body = tokenResponse.body;

    if (body != null && body.containsKey(_apiTokenKey)) {
      final token = body[_apiTokenKey];

      final storage = await Storage.load();
      storage.apiToken = token;

      _service = VoipGridService.create(email: email, token: token);

      final systemUserResponse = await _service.getSystemUser();
      storage.systemUser = SystemUser.fromJson(systemUserResponse.body);

      _currentUser = storage.systemUser;

      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final storage = await Storage.load();

    return storage.apiToken != null;
  }

  @override
  Future<SystemUser> get currentUser async {
    if (_currentUser == null) {
      final storage = await Storage.load();

      _currentUser = storage.systemUser;
    }

    return _currentUser;
  }
}
