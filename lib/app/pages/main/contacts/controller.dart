import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/contact.dart';
import '../../../../domain/entities/contact.dart';

import 'presenter.dart';

class ContactsController extends Controller {
  final ContactsPresenter _presenter;

  List<Contact> contacts = [];

  ContactsController(ContactRepository contactRepository)
      : _presenter = ContactsPresenter(contactRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getContacts();
  }

  void getContacts() {
    _presenter.getContacts();
  }

  void _onContactsUpdated(List<Contact> contacts) {
    this.contacts = contacts;

    refreshUI();
  }

  @override
  void initListeners() {
    _presenter.contactsOnNext = _onContactsUpdated;
  }
}
