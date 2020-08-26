import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/caller.dart';

import '../../../../../domain/entities/contact.dart';

import '../../../../util/debug.dart';

import 'presenter.dart';

class ContactDetailsController extends Controller {
  final _presenter = ContactDetailsPresenter();

  List<Contact> contacts = [];

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

  Future<void> call(String destination) async {
    doIfNotDebug(() {
      Segment.track(eventName: 'call', properties: {'via': 'contact'});
    });

    getContext().bloc<CallerCubit>().call(destination);
  }

  void mail(String destination) {
    launch('mailto:$destination');
  }

  @override
  void initListeners() {
    _presenter.contactsOnNext = _onContactsUpdated;
  }
}
