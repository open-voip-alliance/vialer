import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/contact.dart';
import '../../../../domain/repositories/permission.dart';
import '../../../../domain/entities/contact.dart';

import 'presenter.dart';

class ContactsController extends Controller {
  final ContactsPresenter _presenter;

  List<Contact> contacts = [];

  ContactsController(
    ContactRepository contactRepository,
    PermissionRepository permissionRepository,
  ) : _presenter = ContactsPresenter(contactRepository, permissionRepository);

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getContacts();
  }

  void getContacts() => _presenter.getContacts();

  void askPermission() => _presenter.askPermission();

  void _onContactsUpdated(List<Contact> contacts) {
    this.contacts = contacts;

    refreshUI();
  }

  void _onNoPermission() {
    _hasPermission = false;
    refreshUI();
  }

  void _onPermissionGranted() {
    _hasPermission = true;
    getContacts();
  }

  @override
  void initListeners() {
    _presenter.contactsOnNext = _onContactsUpdated;
    _presenter.contactsOnNoPermission = _onNoPermission;
    _presenter.contactsOnPermissionGranted = _onPermissionGranted;
  }
}
