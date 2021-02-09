import '../../dependency_locator.dart';
import '../entities/phone_account.dart';
import '../repositories/auth.dart';
import '../repositories/phone_account.dart';
import '../repositories/storage.dart';
import '../use_case.dart';

class GetLatestAppAccountUseCase extends FutureUseCase<PhoneAccount> {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _phoneAccountRepository = dependencyLocator<PhoneAccountRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  Future<PhoneAccount> call() async {
    final phoneAccount = await _phoneAccountRepository.getLatestAppAccountById(
      _authRepository.currentUser.appAccountId,
    );

    _storageRepository.appAccount = phoneAccount;

    return phoneAccount;
  }
}
