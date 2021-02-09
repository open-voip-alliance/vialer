import '../../dependency_locator.dart';
import '../entities/phone_account.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'get_latest_app_account.dart';

class GetCurrentAppAccountUseCase extends FutureUseCase<PhoneAccount> {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _getLatestPhoneAccount = GetLatestAppAccountUseCase();

  /// Gets the currently saved app account. If it's null, it's fetched
  /// from the API.
  @override
  Future<PhoneAccount> call() async {
    var phoneAccount = _storageRepository.appAccount;

    if (phoneAccount == null) {
      phoneAccount = await _getLatestPhoneAccount();
    }

    return phoneAccount;
  }
}
