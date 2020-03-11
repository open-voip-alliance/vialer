import '../../domain/repositories/auth.dart';
import '../../domain/repositories/storage.dart';

import 'services/voipgrid.dart';
import '../../domain/entities/system_user.dart';

class DataAuthRepository extends AuthRepository {
  final StorageRepository _storageRepository;

  DataAuthRepository(this._storageRepository);

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

      _storageRepository.apiToken = token;

      _service = VoipGridService.create(email: email, token: token);

      final systemUserResponse = await _service.getSystemUser();
      _storageRepository.systemUser = SystemUser.fromJson(
        systemUserResponse.body,
      );

      _currentUser = _storageRepository.systemUser;

      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _storageRepository.apiToken != null;
  }

  @override
  SystemUser get currentUser {
    _currentUser ??= _storageRepository.systemUser;

    return _currentUser;
  }
}
