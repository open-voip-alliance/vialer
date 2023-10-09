import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'shared_contacts_repository.dart';

class CreateSharedContactUseCase extends UseCase {
  late final _sharedContactsRepository =
      dependencyLocator<SharedContactsRepository>();

  Future<void> call({
    required String firstName,
    required String lastName,
    required String company,
    required List<String>? phoneNumbers,
  }) {
    if (phoneNumbers == null) {
      return _sharedContactsRepository.createSharedContact(
        firstName,
        lastName,
        company,
      );
    } else {
      return _sharedContactsRepository.createSharedContact(
        firstName,
        lastName,
        company,
        phoneNumbers,
      );
    }
  }
}
