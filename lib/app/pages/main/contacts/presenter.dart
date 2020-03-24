import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/no_permission.dart';
import '../../../../domain/entities/permission.dart';
import '../../../../domain/entities/contact.dart';

import '../../../../domain/repositories/contact.dart';
import '../../../../domain/repositories/permission.dart';

import '../../../../domain/usecases/get_contacts.dart';
import '../../../../domain/usecases/onboarding/request_permission.dart';

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
    _getContactsUseCase.execute(_GetContactsUseCaseObserver(this));
  }

  void askPermission() {
    _requestPermissionUseCase.execute(
      _RequestPermissionUseCaseObserver(this),
      RequestPermissionUseCaseParams(Permission.contacts),
    );
  }

  @override
  void dispose() {
    _getContactsUseCase.dispose();
  }
}

class _GetContactsUseCaseObserver extends Observer<List<Contact>> {
  final ContactsPresenter presenter;

  _GetContactsUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {
    if (e is NoPermission) {
      presenter.contactsOnNoPermission();
    }
  }

  @override
  void onNext(List<Contact> contacts) => presenter.contactsOnNext(contacts);
}

class _RequestPermissionUseCaseObserver extends Observer<bool> {
  final ContactsPresenter presenter;

  _RequestPermissionUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(bool granted) {
    if (granted) {
      presenter.contactsOnPermissionGranted();
    }
  }
}
