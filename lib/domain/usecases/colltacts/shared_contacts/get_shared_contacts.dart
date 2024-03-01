import 'package:injectable/injectable.dart';
import 'package:vialer/domain/usecases/colltacts/shared_contacts/propagate_shared_contacts.dart';

import '../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../data/repositories/colltacts/shared_contacts/shared_contacts_repository.dart';
import '../../../../data/repositories/legacy/storage.dart';
import '../../../../presentation/util/synchronized_task.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';

@injectable
class GetSharedContactsUseCase extends UseCase {
  final SharedContactsRepository _sharedContactsRepository;
  final StorageRepository _storage;
  final GetLoggedInUserUseCase _getUser;
  final PropagateSharedContacts _propagateSharedContacts;

  GetSharedContactsUseCase(
    this._sharedContactsRepository,
    this._storage,
    this._getUser,
    this._propagateSharedContacts,
  );

  Future<List<SharedContact>> call({
    bool forceSharedContactsRefresh = false,
  }) async {
    final cachedSharedContacts = _storage.sharedContacts;
    final sharedContacts =
        cachedSharedContacts.isEmpty || forceSharedContactsRefresh
            ? await _fetchSharedContacts()
            : cachedSharedContacts;

    if (cachedSharedContacts != sharedContacts) {
      _propagateSharedContacts(cachedSharedContacts, sharedContacts);
    }

    return sharedContacts;
  }

  Future<List<SharedContact>> _fetchSharedContacts() async =>
      SynchronizedTask<List<SharedContact>>.of(this).run(
        () async => _storage.sharedContacts =
            await _sharedContactsRepository.getSharedContacts(_getUser()),
      );
}
