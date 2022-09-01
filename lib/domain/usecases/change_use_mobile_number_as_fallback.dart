import '../../dependency_locator.dart';
import '../repositories/auth.dart';
import '../use_case.dart';
import 'get_user.dart';

class ChangeUseMobileNumberAsFallbackUseCase extends UseCase {
  final _getUser = GetUserUseCase();
  final _authRepository = dependencyLocator<AuthRepository>();

  Future<bool> call({required bool enable}) async {
    final user = (await _getUser(latest: false))!;

    return await _authRepository.setUseMobileNumberAsFallback(
      user,
      enable: enable,
    );
  }
}
