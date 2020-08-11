import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/contact.dart';
import '../../../../domain/entities/permission_status.dart';

import '../../../../domain/repositories/contact.dart';
import '../../../../domain/repositories/permission.dart';

import 'presenter.dart';

class ContactsController extends Controller {
  final ContactsPresenter _presenter;

  bool _showSettingsDirections = false;

  bool get showSettingsDirections => _showSettingsDirections;

  Completer _completer;

  List<Contact> contacts = [];

  String searchTerm = '';

  ContactsController(
    ContactRepository contactRepository,
    PermissionRepository permissionRepository,
  ) : _presenter = ContactsPresenter(contactRepository, permissionRepository);

  bool _hasPermission = true;

  bool get hasPermission => _hasPermission;

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    _presenter.checkContactsPermission();
  }

  void onSearch(String searchTerm) {
    this.searchTerm = searchTerm.isEmpty ? '' : searchTerm;
    refreshUI();
  }

  void getContacts() => _presenter.getContacts();

  void askPermission() => _presenter.askPermission();

  Future<void> updateContacts() {
    _completer = Completer();

    getContacts();

    return _completer.future;
  }

  void _onContactsUpdated(List<Contact> contacts) {
    this.contacts = contacts;

    refreshUI();

    _completer?.complete();
  }

  void _onNoPermission() {
    _showSettingsDirections = true;
    _hasPermission = false;
    refreshUI();
  }

  void _onPermissionGranted() {
    _hasPermission = true;
    getContacts();
  }

  void _onCheckContactsPermissionNext(PermissionStatus status) {
    _showSettingsDirections = (status == PermissionStatus.permanentlyDenied) ||
        (Platform.isIOS && status == PermissionStatus.denied);
    _hasPermission = status == PermissionStatus.granted;

    if (_hasPermission) {
      getContacts();
    } else {
      refreshUI();
    }
  }

  @override
  void initListeners() {
    _presenter.contactsOnNext = _onContactsUpdated;
    _presenter.contactsOnNoPermission = _onNoPermission;
    _presenter.contactsOnPermissionGranted = _onPermissionGranted;
    _presenter.onCheckContactsPermissionNext = _onCheckContactsPermissionNext;
  }
}
