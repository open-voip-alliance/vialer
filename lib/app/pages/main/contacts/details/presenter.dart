import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/repositories/contact.dart';
import '../../../../../domain/repositories/call.dart';
import '../../../../../domain/repositories/setting.dart';

import '../../../../../domain/usecases/get_contacts.dart';
import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/get_settings.dart';

class ContactDetailsPresenter extends Presenter {
  Function contactsOnNext;

  Function callOnError;

  Function settingsOnNext;

  final GetContactsUseCase _getContacts;
  final CallUseCase _call;
  final GetSettingsUseCase _getSettings;

  ContactDetailsPresenter(
    ContactRepository contactRepository,
    CallRepository callRepository,
    PermissionRepository permissionRepository,
    SettingRepository settingRepository,
  )   : _getContacts = GetContactsUseCase(
          contactRepository,
          permissionRepository,
        ),
        _call = CallUseCase(callRepository),
        _getSettings = GetSettingsUseCase(
          settingRepository,
        );

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
