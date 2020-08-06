import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/no_permission.dart';
import '../../../../domain/entities/permission.dart';
import '../../../../domain/entities/permission_status.dart';

import '../../../../domain/repositories/contact.dart';
import '../../../../domain/repositories/permission.dart';

import '../../../../domain/usecases/get_contacts.dart';
import '../../../../domain/usecases/onboarding/request_permission.dart';

import '../util/observer.dart';

class ContactsPresenter extends Presenter {
  Function contactsOnNext;
  Function contactsOnNoPermission;
  Function contactsOnPermissionGranted;

  final GetContactsUseCase _getContactsUseCase;
  final RequestPermissionUseCase _requestPermissionUseCase;

  ContactsPresenter(
    ContactRepository contactRepository,
    PermissionRepository permissionRepository,
  )   : _getContactsUseCase = GetContactsUseCase(
          contactRepository,
          permissionRepository,
        ),
        _requestPermissionUseCase = RequestPermissionUseCase(
          permissionRepository,
        );

  void getContacts() {
    _getContactsUseCase.execute(
      Watcher(
        onNext: contactsOnNext,
        onError: (e) {
          if (e is NoPermission) {
            contactsOnNoPermission();
          }
        },
      ),
    );
  }

  void askPermission() {
    _requestPermissionUseCase.execute(
      Watcher(
        onNext: (status) {
          if (status == PermissionStatus.granted) {
            contactsOnPermissionGranted();
          }
        },
      ),
      RequestPermissionUseCaseParams(Permission.contacts),
    );
  }

  @override
  void dispose() {
    _getContactsUseCase.dispose();
  }
}
