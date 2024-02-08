import 'package:vialer/app/util/pigeon.dart';
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
  late final _nativeSharedContacts = SharedContacts();

  Future<List<SharedContact>> call({
    bool forceSharedContactsRefresh = false,
  }) async {
    final cachedSharedContacts = _storage.sharedContacts;
    final sharedContacts =
        cachedSharedContacts.isEmpty || forceSharedContactsRefresh
            ? await _fetchSharedContacts()
            : cachedSharedContacts;

    _processNativeSharedContacts(sharedContacts);

    return sharedContacts;
  }

  /// Processes the native shared contacts by converting them into a list of [NativeSharedContact] objects
  /// and passing them to the [_nativeSharedContacts.processSharedContacts] method.
  ///
  /// The [sharedContacts] parameter is a list of [SharedContact] objects representing the shared contacts
  /// to be processed.
  void _processNativeSharedContacts(List<SharedContact> sharedContacts) {
    _nativeSharedContacts.processSharedContacts(
      sharedContacts
          .map(
            (contact) => NativeSharedContact(
              phoneNumbers: contact.phoneNumbers
                  .map(
                    (phoneNumber) => NativePhoneNumber(
                      phoneNumberFlat: phoneNumber.phoneNumberFlat,
                      phoneNumberWithoutCallingCode:
                          phoneNumber.withoutCallingCode,
                    ),
                  )
                  .toList(),
              displayName: contact.displayName,
            ),
          )
          .toList(),
    );
  }

  Future<List<SharedContact>> _fetchSharedContacts() async =>
      SynchronizedTask<List<SharedContact>>.of(this).run(
        () async => _storage.sharedContacts =
            await _sharedContactsRepository.getSharedContacts(_getUser()),
      );
}
