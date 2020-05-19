import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dialer/caller.dart';

import '../../../../../domain/entities/contact.dart';

import '../../../../../domain/repositories/contact.dart';
import '../../../../../domain/repositories/call.dart';
import '../../../../../domain/repositories/setting.dart';
import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/repositories/logging.dart';

import '../../../../util/debug.dart';

import 'presenter.dart';

class ContactDetailsController extends Controller with Caller {
  @override
  final CallRepository callRepository;

  @override
  final SettingRepository settingRepository;

  @override
  final LoggingRepository loggingRepository;

  final ContactDetailsPresenter _presenter;

  List<Contact> contacts = [];

  ContactDetailsController(
    ContactRepository contactRepository,
    this.callRepository,
    PermissionRepository permissionRepository,
    this.settingRepository,
    this.loggingRepository,
  ) : _presenter = ContactDetailsPresenter(
          contactRepository,
          callRepository,
          permissionRepository,
          settingRepository,
        );

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getContacts();
    executeGetSettingsUseCase();
  }

  void getContacts() {
    _presenter.getContacts();
  }

  void _onContactsUpdated(List<Contact> contacts) {
    this.contacts = contacts;

    refreshUI();
  }

  @override
  void call(String destination) {
    doIfNotDebug(() {
      Segment.track(eventName: 'call', properties: {'via': 'contact'});
    });
    super.call(destination);
  }

  void mail(String destination) {
    launch('mailto:$destination');
  }

  @override
  void initListeners() {
    _presenter.contactsOnNext = _onContactsUpdated;
    _presenter.callOnError = showException;
    _presenter.settingsOnNext = setSettings;
  }

  @override
  void executeCallUseCase(String destination) => _presenter.call(destination);

  @override
  void executeGetSettingsUseCase() => _presenter.getSettings();
}
