import '../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../data/repositories/colltacts/shared_contacts/shared_contacts_repository.dart';
import '../../../../data/repositories/legacy/storage.dart';
import '../../../../dependency_locator.dart';
import '../../../../presentation/util/synchronized_task.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';

class GetSharedContactsUseCase extends UseCase {
  late final _sharedContactsRepository =
      dependencyLocator<SharedContactsRepository>();
  late final _getUser = GetLoggedInUserUseCase();
  late final _storage = dependencyLocator<StorageRepository>();

  Future<List<SharedContact>> call({
    bool forceSharedContactsRefresh = false,
  }) async {
    final cachedSharedContacts = _storage.sharedContacts;

    return cachedSharedContacts.isEmpty || forceSharedContactsRefresh
        ? await _fetchSharedContacts()
        : cachedSharedContacts;
  }

  Future<List<SharedContact>> _fetchSharedContacts() async =>
      SynchronizedTask<List<SharedContact>>.of(this).run(
        () async => _storage.sharedContacts =
            await _sharedContactsRepository.getSharedContacts(_getUser()),
      );
}
