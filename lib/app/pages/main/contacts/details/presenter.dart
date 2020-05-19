import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/repositories/contact.dart';
import '../../../../../domain/repositories/call.dart';
import '../../../../../domain/repositories/setting.dart';

import '../../../../../domain/usecases/get_contacts.dart';
import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/get_settings.dart';

import '../../util/observer.dart';

class ContactDetailsPresenter extends Presenter {
  Function contactsOnNext;

  Function callOnError;

  Function settingsOnNext;

  final GetContactsUseCase _getContactsUseCase;
  final CallUseCase _callUseCase;
  final GetSettingsUseCase _getSettingsUseCase;

  ContactDetailsPresenter(
    ContactRepository contactRepository,
    CallRepository callRepository,
    PermissionRepository permissionRepository,
    SettingRepository settingRepository,
  )   : _getContactsUseCase = GetContactsUseCase(
          contactRepository,
          permissionRepository,
        ),
        _callUseCase = CallUseCase(callRepository),
        _getSettingsUseCase = GetSettingsUseCase(
          settingRepository,
        );

  void getContacts() {
    _getContactsUseCase.execute(
      Watcher(
        onNext: contactsOnNext,
      ),
    );
  }

  void call(String destination) {
    _callUseCase.execute(
      Watcher(
        onError: (e) => callOnError(e),
      ),
      CallUseCaseParams(destination),
    );
  }

  void getSettings() {
    _getSettingsUseCase.execute(
      Watcher(
        onNext: settingsOnNext,
      ),
    );
  }

  @override
  void dispose() {
    _getContactsUseCase.dispose();
  }
}
