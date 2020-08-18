import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/no_permission.dart';
import '../../../../domain/entities/permission.dart';
import '../../../../domain/entities/permission_status.dart';

import '../../../../domain/usecases/get_contacts.dart';
import '../../../../domain/usecases/get_permission_status.dart';
import '../../../../domain/usecases/onboarding/request_permission.dart';

class ContactsPresenter extends Presenter {
  Function contactsOnNext;
  Function contactsOnNoPermission;
  Function contactsOnPermissionGranted;
  Function onCheckContactsPermissionNext;

  final _getContacts = GetContactsUseCase();
  final _getPermissionStatus = RequestPermissionUseCase();
  final _requestPermission = GetPermissionStatusUseCase();

  void getContacts() {
    _getContacts().then(
      contactsOnNext,
      onError: (e) {
        if (e is NoPermission) {
          contactsOnNoPermission();
        }
      },
    );
  }

  void checkContactsPermission() =>
      _getPermissionStatus(permission: Permission.contacts)
          .then(onCheckContactsPermissionNext);

  void askPermission() {
    _requestPermission(permission: Permission.contacts).then(
      (status) {
        if (status == PermissionStatus.granted) {
          contactsOnPermissionGranted();
        } else {
          contactsOnNoPermission();
        }
      },
    );
  }

  @override
  void dispose() {}
}
