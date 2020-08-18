import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dialer/caller.dart';

import '../../../../../domain/entities/contact.dart';

import '../../../../util/debug.dart';

import 'presenter.dart';

class ContactDetailsController extends Controller with Caller {
  final _presenter = ContactDetailsPresenter();

  List<Contact> contacts = [];

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
  Future<void> call(String destination) async {
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
