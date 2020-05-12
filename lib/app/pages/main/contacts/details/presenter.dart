import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/repositories/contact.dart';
import '../../../../../domain/repositories/call.dart';

import '../../../../../domain/usecases/get_contacts.dart';
import '../../../../../domain/usecases/call.dart';

import '../../util/observer.dart';

class ContactDetailsPresenter extends Presenter {
  Function contactsOnNext;

  Function callOnError;

  final GetContactsUseCase _getContactsUseCase;
  final CallUseCase _callUseCase;

  ContactDetailsPresenter(
    ContactRepository contactRepository,
    CallRepository callRepository,
    PermissionRepository permissionRepository,
  )   : _getContactsUseCase = GetContactsUseCase(
          contactRepository,
          permissionRepository,
        ),
        _callUseCase = CallUseCase(callRepository);

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

  @override
  void dispose() {
    _getContactsUseCase.dispose();
  }
}
