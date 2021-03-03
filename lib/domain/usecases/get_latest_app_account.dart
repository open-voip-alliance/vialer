import '../../dependency_locator.dart';
import '../entities/phone_account.dart';
import '../repositories/phone_account.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'get_user.dart';

class GetLatestAppAccountUseCase extends FutureUseCase<PhoneAccount> {
  final _phoneAccountRepository = dependencyLocator<PhoneAccountRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetUserUseCase();

  @override
  Future<PhoneAccount> call() async {
    final user = await _getUser(latest: false);

    final phoneAccount = await _phoneAccountRepository.getLatestAppAccountById(
      user.appAccountId,
    );

    _storageRepository.appAccount = phoneAccount;

    return phoneAccount;
  }
}
