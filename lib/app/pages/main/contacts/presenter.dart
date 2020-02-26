import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/contact.dart';
import '../../../../domain/repositories/contact.dart';
import '../../../../domain/usecases/get_contacts.dart';

class ContactsPresenter extends Presenter {
  Function contactsOnNext;

  final GetContactsUseCase _getContactsUseCase;

  ContactsPresenter(ContactRepository contactRepository)
      : _getContactsUseCase = GetContactsUseCase(contactRepository);

  void getContacts() {
    _getContactsUseCase.execute(_GetContactsUseCaseObserver(this));
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
  void onError(dynamic e) {}

  @override
  void onNext(List<Contact> contacts) =>
      presenter.contactsOnNext(contacts);
}
