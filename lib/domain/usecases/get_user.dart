import '../../dependency_locator.dart';
import '../entities/system_user.dart';
import '../repositories/auth.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetUserUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();

  Future<SystemUser?> call({required bool latest}) async {
    if (!latest) {
      return _storageRepository.systemUser;
    }

    var user = await _authRepository.getUserUsingStoredCredentials();
    user = user.copyWith(token: _storageRepository.systemUser?.token);

    _storageRepository.systemUser = user;

    return user;
  }
}
