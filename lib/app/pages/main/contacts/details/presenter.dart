import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/usecases/get_contacts.dart';
import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/get_settings.dart';

class ContactDetailsPresenter extends Presenter {
  Function contactsOnNext;

  Function callOnError;

  Function settingsOnNext;

  final _getContacts = GetContactsUseCase();
  final _call = CallUseCase();
  final _getSettings = GetSettingsUseCase();

  void getContacts() {
    _getContacts().then(contactsOnNext);
  }

  void call(String destination) {
    _call(destination: destination).catchError(callOnError);
  }

  void getSettings() {
    _getSettings().then(settingsOnNext);
  }

  @override
  void dispose() {}
}
