import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/contact.dart';

import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/repositories/contact.dart';
import '../../../../../domain/repositories/call.dart';

import '../../../../../domain/usecases/get_contacts.dart';
import '../../../../../domain/usecases/call.dart';

class ContactDetailsPresenter extends Presenter {
  Function contactsOnNext;

  Function callOnError;

  final GetContactsUseCase _getContactsUseCase;
  final CallUseCase _callUseCase;

  ContactDetailsPresenter(
    ContactRepository contactRepository,
    CallRepository callRepository,
    PermissionRepository permissionRepository,
  )   : _getContactsUseCase = GetContactsUseCase(
          contactRepository,
          permissionRepository,
        ),
        _callUseCase = CallUseCase(callRepository);

  void getContacts() {
    _getContactsUseCase.execute(_GetContactsUseCaseObserver(this));
  }

  void call(String destination) {
    _callUseCase.execute(
      _CallUseCaseObserver(this),
      CallUseCaseParams(destination),
    );
  }

  @override
  void dispose() {
    _getContactsUseCase.dispose();
  }
}

class _GetContactsUseCaseObserver extends Observer<List<Contact>> {
  final ContactDetailsPresenter presenter;

  _GetContactsUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(List<Contact> contacts) => presenter.contactsOnNext(contacts);
}

class _CallUseCaseObserver extends Observer<void> {
  final ContactDetailsPresenter presenter;

  _CallUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) => presenter.callOnError(e);

  @override
  void onNext(_) {}
}
