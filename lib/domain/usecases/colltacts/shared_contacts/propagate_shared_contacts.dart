import 'package:injectable/injectable.dart';
import 'package:vialer/domain/usecases/use_case.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../presentation/util/pigeon.dart';

@injectable
class PropagateSharedContacts extends UseCase with Loggable {
  final SharedContacts _nativeSharedContacts;
  final VoipRepository _voipRepository;
  final GetLoggedInUserUseCase _getUser;

  PropagateSharedContacts(
    this._nativeSharedContacts,
    this._voipRepository,
    this._getUser,
  );

  Future<void> call(
    Iterable<SharedContact> previous,
    Iterable<SharedContact> current,
  ) {
    logger.info(
      'Propagating shared contact changes to native, previous has '
      '[${previous.length}], current has [${current.length}].',
    );
    _processNativeSharedContacts(current);
    return _voipRepository.refreshPreferences(_getUser());
  }

  /// Processes the native shared contacts by converting them into a list of
  /// [NativeSharedContact] objects and passing them to the
  /// [_nativeSharedContacts.processSharedContacts] method.
  ///
  /// The [sharedContacts] parameter is a list of [SharedContact] objects
  /// representing the shared contacts to be processed.
  void _processNativeSharedContacts(Iterable<SharedContact> sharedContacts) {
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
}
